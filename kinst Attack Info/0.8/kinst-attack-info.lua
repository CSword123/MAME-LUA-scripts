-- ver 0.8, 2/1/2025
-- Code by CSword123
-- Special Thanks: Abystus, jedpossum
cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
s = manager.machine.screens[":screen"]
rend = manager.machine.render
cont = manager.machine.render.ui_container
--currFrameCount = s:frame_number()
--prevFrameCount = currFrameCount - 1
game = emu.romname("kinst", "kinst2")
--for k,v in pairs(manager:machine().devices) do print(k) end
local P1LastHP = 120
local P2LastHP = 120
local opponentCurrentHealth = 120
local p1Damage = 0
local p2Damage = 0
local p1ComboDamage = 0
local p2ComboDamage = 0
local comboCount = 0
local p1LastComboCount = 0
local p2LastComboCount = 0
local p1Startup = 0
local p2Startup = 0
local p1FrameData = (0 .. "/" .. 0 .. "/" .. 0)
local p2FrameData = (0 .. "/" .. 0 .. "/" .. 0)
--[[local lastP1Input = 0xFFFF
local readP1Input = 0x0000
local lastP1InputIcon = nil
local heightValue = 220
local numSlots = 16
local p1InputHist = {}
]]
--[[
function loadIcons()
  
  local neutralbmp = emu.bitmap_argb32.load(io.open("MAME-LUA-scripts/icons/neutral.png", 'rb'):read('*a'))
  neutralTex = rend:texture_alloc(neutralbmp)
  print(rend.valid)
  local upbmp = emu.bitmap_argb32.load(io.open("MAME-LUA-scripts/icons/up.png", 'rb'):read('*a'))
  upTex = rend:texture_alloc(upbmp)
 --local upright = s:load_bitmap("icons/upright.png")
 --local right = s:load_bitmap("icons/right.png")
 --local downright = s:load_bitmap("icons/downright.png")
 --local down = s:load_bitmap("icons/down.png")
 --local downleft = s:load_bitmap("icons/downleft.png")
 --local left = s:load_bitmap("icons/left.png")
 -- Check if the image was loaded successfully
end
]]

function getPlayerState(game, player)
  local readState = 0x00
  if game == "kinst" then
    if player == 1 then
      readState = mem:readv_u8(0x8808BC2C)
    elseif player == 2 then
      readState = mem:readv_u8(0x8808BD2C)
    end
  elseif game == "kinst2" then
    if player == 1 then
      readState = mem:readv_u8(0x887FC0DC)
    elseif player == 2 then
      readState = mem:readv_u8(0x887FC1DC)
    end
  end
  local playerState = ""
  if readState == 0x00 then
    playerState = "Neutral"
  elseif readState == 0x01 then
    playerState = "Crouch"
  elseif readState == 0x02 then
    playerState = "Jump"
  elseif readState == 0x04 then
    playerState = "Stand"
  elseif readState == 0x05 then
    playerState = "Low Attack"
  elseif readState == 0x06 then
    playerState = "Attack"
  elseif readState == 0x07 then
    playerState = "Low Special"
  elseif readState == 0x0C then
    playerState = "Standing Block"
  elseif readState == 0x0D then
    playerState = "Crouching Block"
  elseif readState == 0x14 then
    playerState = "Hurt"
  elseif readState == 0x44 or readState == 0x45 or readState == 0x46 then
    playerState = "Blocked Hit"
  elseif readState == 0xC4 or 0xC5 or 0xC6 then
    playerState = "Hit"
  else
    playerState = ""
  end
return playerState  

end
function calculatePlayer1Damage()
  if opponentCurrentHealth ~= P2LastHP then
    if P2LastHP > opponentCurrentHealth then 
      p1Damage = P2LastHP - opponentCurrentHealth
    else
      p1Damage = 0
    end
    P2LastHP = opponentCurrentHealth
  end
  return p1Damage
end

function calculatePlayer2Damage()
  if opponentCurrentHealth ~= P1LastHP then
    if P1LastHP > opponentCurrentHealth then 
      p2Damage = P1LastHP - opponentCurrentHealth
    else
      p2Damage = 0
    end
    P1LastHP = opponentCurrentHealth
  end
  return p2Damage
end
function getPlayerDamage(game, player)
  local playerDamage = 0
  if game == "kinst" then
    if player == 1 then
      opponentCurrentHealth = mem:readv_u8(0x8808BD55)
      playerDamage = calculatePlayer1Damage()
    elseif player == 2 then
      opponentCurrentHealth = mem:readv_u8(0x8808BC55)
      playerDamage = calculatePlayer2Damage()
      
    end
  elseif game == "kinst2" then
    if player == 1 then
      opponentCurrentHealth = mem:readv_u8(0x887FC205)
      playerDamage = calculatePlayer1Damage()
    elseif player == 2 then
      opponentCurrentHealth = mem:readv_u8(0x887FC105)
      playerDamage = calculatePlayer2Damage()
    end
  end
  
  return playerDamage
end

function calculatePlayer1ComboDamage()
  if comboCount == 1 and p1LastComboCount == 0 then
    -- New combo started
    p1ComboDamage = p1Damage
  elseif comboCount > p1LastComboCount then
    -- Increment combo damage only if combo count increased
    p1ComboDamage = p1ComboDamage + p1Damage
  elseif comboCount == 0 and p1LastComboCount > 0 then
    -- Combo ended
  end
  p1LastComboCount = comboCount
  return p1ComboDamage
end

function calculatePlayer2ComboDamage()
  if comboCount == 1 and p2LastComboCount == 0  then
    p2ComboDamage = p2Damage
  elseif comboCount > p2LastComboCount then
    p2ComboDamage = p2ComboDamage + p2Damage
  elseif comboCount == 0 and p2LastComboCount > 0 then
    -- Combo ended
  end
  p2LastComboCount = comboCount
  return p2ComboDamage
end

function getPlayerComboDamage(game, player)
  local comboDamage = 0
  if game == "kinst" then
    if player == 1 then
      comboCount = mem:readv_u8(0x8808BC8D)
      comboDamage = calculatePlayer1ComboDamage()
    elseif player == 2 then
      comboCount = mem:readv_u8(0x8808BD8D)
      comboDamage = calculatePlayer2ComboDamage()
    end
  elseif game == "kinst2" then
    if player == 1 then
      comboCount = mem:readv_u8(0x887FC13D)
      comboDamage = calculatePlayer1ComboDamage()
    elseif player == 2 then
      comboCount = mem:readv_u8(0x887FC23D)
      comboDamage = calculatePlayer2ComboDamage()
    end
  end
  return comboDamage
end

function getPlayerStun(player) 
  local playerStun = 0
    if player == 1 then
      playerStun = mem:readv_u16(0x8808BC92)
    elseif player == 2 then
      playerStun = mem:readv_u16(0x8808BD92)
    end
  --else if g == "kinst2" then
    --p2Stun = mem:read_log_u16()
return playerStun

end

function getPlayerPower(player)
  local playerPower = 0
  if player == 1 then
    playerPower = mem:readv_u8(0x887FBEB4)
  elseif player == 2 then
    playerPower = mem:readv_u8(0x887FBFB4)
  end
  
  return playerPower
end
  
function getPlayerHeight(game, player)
  local playerHeight = 0
  if game == "kinst" then
    if player == 1 then
      playerHeight = mem:readv_i16(0x8808BC0D)
    elseif player == 2 then
      playerHeight = mem:readv_i16(0x8808BD0D)
    end
  elseif game == "kinst2" then  
    if player == 1 then
      playerHeight = mem:readv_i16(0x887FC0BD)
    elseif player == 2 then
      mem:readv_i16(0x887FC1BD)
    end
  end
   
  return playerHeight
end

function getPlayerTwoInOne(game, player)
  local answer = "No"
  if game == "kinst" then
    if player == 1 then
      comboCount = mem:readv_u8(0x8808BC8D) 
    elseif player == 2 then
      comboCount = mem:readv_u8(0x8808BD8D)
    end
  elseif game == "kinst2" then
    if player == 1 then
      comboCount = mem:readv_u8(0x887FC13D)
    elseif player == 2 then
      comboCount = mem:readv_u8(0x887FC23D)
    end
  end
  local didPlayerGetTwoInOne = false
  if comboCount == 2 then
    didPlayerGetTwoInOne = true
  else
    didPlayerGetTwoInOne = false
  end
  if didPlayerGetTwoInOne == true then
    answer = "Yes"
  else
    answer = "No"
  end
  return answer
end

function getPlayerFrameData(game, player)
  local playerFrameData = (0 .. "/" .. 0 .. "/" .. 0)
  if game == "kinst" then
    if player == 1 then
      p1Startup = mem:readv_u8(0x8808BCC3)
      p1Active = 0
      p1Recovery = 0
      p1FrameData = (p1Startup .. "/" .. p1Active .. "/" .. p1Recovery)
      playerFrameData = p1FrameData
    elseif player == 2 then
      p2Startup = mem:readv_u8(0x8808BDC3)
      p2Active = 0
      p2Recovery = 0
      p2FrameData = (p2Startup .. "/" .. p2Active .. "/" .. p2Recovery)
      playerFrameData = p2FrameData
    end
  end
    
  return playerFrameData
end
--[[
function getP1LastInput(game)
  
  if game == "kinst" then
    readP1Input = mem:read_u16(0x10000080)
    return readP1Input
  end
end

function getLastInputIcon(input)

    if input == 0xFFFF then
      lastP1InputIcon = neutralTex
    elseif input == 0xFFBF then
      lastP1InputIcon = upTex
    end
  return lastP1InputIcon
end
function addP1InputIcon(input)
    -- if current input has changed, scroll last input(s) upward and continue to display it, then display new input in bottom
    if input ~= lastP1Input then
        table.insert(p1InputHist, lastP1InputIcon)
        lastP1Input = input
    end
    if #p1InputHist > numSlots then
        table.remove(p1InputHist, 1)
    end
end
]]

function resetData()
  p1ComboDamage = 0
  p2ComboDamage = 0
end

 function draw_hud() 
  if game == "kinst" then
    if mem:readv_u8(0x8808BD01) ~= 0x00 then
      --kinst Player 1 info
      s:draw_box(24, 24, 144, 84,  0xff000000, 0x80660066)
      s:draw_text(30, 26, "Damage: " .. getPlayerDamage("kinst", 1))
      s:draw_text(30, 34, "Combo Damage: " .. getPlayerComboDamage("kinst", 1))
      s:draw_text(30, 42, "Stun: " .. getPlayerStun(1))
      s:draw_text(30, 50, "Frames: " .. getPlayerFrameData("kinst", 1))
      s:draw_text(30, 58, "Two-in-One: " .. getPlayerTwoInOne("kinst", 1))
      s:draw_text(30, 66, "Height: " .. getPlayerHeight("kinst", 1))
      s:draw_text(30, 74, "Player State: " .. getPlayerState("kinst", 1))
      --kinst Player 2 info
      s:draw_box(176, 24, 296, 84,  0xff000000, 0x80660066)
      s:draw_text(182, 26, "Damage: " .. getPlayerDamage("kinst", 2))
      s:draw_text(182, 34, "Combo Damage: " .. getPlayerComboDamage("kinst", 2))
      s:draw_text(182, 42, "Stun: " .. getPlayerStun(2))
      s:draw_text(182, 50, "Frames: " .. getPlayerFrameData("kinst", 2))
      s:draw_text(182, 58, "Two-in-One: " .. getPlayerTwoInOne("kinst", 2))
      s:draw_text(182, 66, "Height: " .. getPlayerHeight("kinst", 2))
      s:draw_text(182, 74, "Player State: " .. getPlayerState("kinst", 2))
    else  
      resetData()
    end
  elseif game == "kinst2" then
    if mem:readv_u8(0x887FC1B1) ~= 0x00 then
      --kinst2 Player 1 info
      s:draw_box(20, 30, 140, 86, 0xffff0000, 0x80660066)
      s:draw_text(25, 32, "Damage: " .. getPlayerDamage("kinst2", 1))
      s:draw_text(25, 40, "Combo Damage: " .. getPlayerComboDamage("kinst2", 1))
      s:draw_text(25, 48, "Power: " .. getPlayerPower(1))
      s:draw_text(25, 56, "Two-in-One: " .. getPlayerTwoInOne("kinst2", 1))
      s:draw_text(25, 64, "Height: " .. getPlayerHeight("kinst2", 1))
      s:draw_text(25, 72, "Player State: " .. getPlayerState("kinst2", 1))
      --kinst2 Player 2 info
      s:draw_box(180, 30, 300, 86,  0xffff0000, 0x80660066)
      s:draw_text(185, 32, "Damage: " .. getPlayerDamage("kinst2", 2))
      s:draw_text(185, 40, "Combo Damage: " ..getPlayerComboDamage("kinst2", 2))
      s:draw_text(185, 48, "Power: " .. getPlayerPower(2))
      s:draw_text(185, 56, "Two-in-One: " .. getPlayerTwoInOne("kinst2", 2))
      s:draw_text(185, 64, "Height: " .. getPlayerHeight("kinst2", 2))
      s:draw_text(185, 72, "Player State: " .. getPlayerState("kinst2", 2))
    else
      resetData()
    end
  end  
end
--[[
function drawP1InputHistory()
  if game == "kinst" then
    if mem:readv_u8(0x8808BD01) ~= 0x00 then
    -- Read input data for player 1 and player 2
      local p1Input = getP1LastInput("kinst")
    --local p2_input = get_player_input(2)
      local p1InputIcon = getLastInputIcon(p1Input)
      -- Add input name string to the buffer
      addP1InputIcon(p1InputName)
   
   -- addInput(2, p2_input)
      -- Display input history on the screen
      for i, entry in ipairs(p1InputHist) do
        local y = heightValue - (8 * i)
        cont:draw_quad(p1InputHist[i], 2, y, 1, 1, 0xff000000)
        --s.frame_number
      end
    end
  end
end
]]    
  

--loadIcons()
--emu.register_frame(prevFrame, "frame")
 -- emu.register_frame_done(tick, "frame")
emu.register_frame_done(draw_hud, "frame")
--emu.register_frame_done(drawP1InputHistory, "frame")
