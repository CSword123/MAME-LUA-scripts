-- ver 0.3, 7/5/2018
-- code by CSword123
-- Special Thanks: Abystus, jedpossum
cpu = manager:machine().devices[":maincpu"];
mem = cpu.spaces["program"];
s = manager:machine().screens[":screen"];
--currFrameCount = s:frame_number();
--prevFrameCount = currFrameCount - 1;
game = emu.romname("kinst", "kinst2");

--for k,v in pairs(manager:machine().devices) do print(k) end

local p1State, p2State = "";
local isP1Hurt, isP2Hurt = false;
local p1Damage, p2Damage = 0;
local p1Stun, p2Stun = 0;
local p1Power, p2Power = 0;
local readState = 0x00;
local MAX_HEALTH = 120;
local p2NextHealth = 0;
local p1CurrentHealth, p2CurrentHealth = 0;
local p1Height, p2Height = 0;
local p1Startup, p2Startup = 0;
local p1Active, p2Active = 0;
local p1Recovery, p2Recovery = 0;
local p1FrameData, p2FrameData = 0;

function tick() 

 
  
  updateP2State = getP2State(game);
  updateP2Damage = getP2Damage(game);
  updateP2Stun = getP2Stun(game);
 
 --print("curr Health: " .. updateP2Damage .. " curr Frame Count: " .. currFrameCount);
 --print("curr Health: " .. updateP2Damage .. " curr Stun: " .. updateP2Stun .. " curr State: " .. updateP2State);
  print("Trade Priority? " .. mem:read_log_u8(0x8808BCB8));
end  

--function prevFrame(p2currentHealth)
  
 
 --print("prev Health: " .. p2CurrentHealth .. " prev Frame Count: " .. prevFrameCount)
 --return p2CurrentHealth
--end

function getP1State(game)
   
  if game == "kinst" then
    readState = mem:read_log_u8(0x8808BC2C);
    if readState == 0x00 then
      p1State = "Neutral"
    elseif readState == 0x01 then
      p1State = "Crouch"
    elseif readState == 0x02 then
      p1State = "Jump"
    elseif readState == 0x04 then
      p1State = "Stand"
    elseif readState == 0x06 then
      p1State = "Air"
    elseif readState == 0x0C then
      p1State = "Standing Block"
    elseif readState == 0x0D then
      p1State = "Crouching Block"
    elseif readState == 0x14 then
      p1State = "Hurt"
      isP1Hurt = true
    elseif readState == 0x44 then
      p1State = "Blocked Standing Hit"
    elseif readState == 0x45 then
      p1State = "Blocked Crouching Hit"
    elseif readState == 0x46 then
      p1State = "Blocked Aerial Hit"
    elseif readState == 0xC4 then
      p1State = "Standing Hit"
    elseif readState == 0xC5 then
      p1State = "Crouching Hit"
    elseif readState == 0xC6 then
      p2State = "Aerial Hit"
    else
      p1State = ""
    end
  elseif game == "kinst2" then
    readState = mem:read_log_u8(0x887FC0DC);
    if readState == 0x00 then
      p1State = "Neutral"
    elseif readState == 0x01 then
      p1State = "Crouch"
    elseif readState == 0x02 then
      p1State = "Jump"
    elseif readState == 0x04 then
      p1State = "Stand"
    elseif readState == 0x06 then
      p1State = "Air"
    elseif readState == 0x0C then
      p1State = "Standing Block"
    elseif readState == 0x0D then
      p1State = "Crouching Block"
    elseif readState == 0x14 then
      p1State = "Hurt"
      isP1Hurt = true
    elseif readState == 0x44 then
      p1State = "Blocked Standing Hit"
    elseif readState == 0x45 then
      p1State = "Blocked Crouching Hit"
    elseif readState == 0x46 then
      p1State = "Blocked Aerial Hit"
    elseif readState == 0xC4 then
      p1State = "Standing Hit"
    elseif readState == 0xC5 then
      p1State = "Crouching Hit"
    elseif readState == 0xC6 then
      p1State = "Aerial Hit"
    else
      p1State = ""
    end
  end
return p1State;  

end

 function getP1Damage(game)
  if game == "kinst" then
    p1CurrentHealth = mem:read_log_u8(0x8808BC55);
  elseif game == "kinst2" then
    p1CurrentHealth = mem:read_log_u8(0x887FC105); --fix
  end
  
  --for d = 120, p2CurrentHealth, - p2CurrentHealth do
   -- print (d);
  --if isP2Hurt == true then
    --p2LastHealth = prevFrame(p2CurrentHealth)
    --p2Damage = p2LastHealth - p2CurrentHealth;
    --p2Damage = p2CurrentHealth;
  --else if g == "kinst2" then
    --p2Health = mem:read_log_u8();
  --end  
  return p1CurrentHealth;
end

function getP1Stun(game) 
  p1Stun = 0;
    if isP2Hurt == true then
      p1Stun = mem:read_log_u16(0x8808BC92);
    end
  --else if g == "kinst2" then
    --p2Stun = mem:read_log_u16();
return p1Stun;

end


function getP1Power(game)
  
  if game == "kinst2" then
      p1Power = mem:read_log_u8(0x887FBEB4);
  end
  
  return p1Power;
end
  

function getP1Height(game)
  
  if game == "kinst" then
    p1Height = mem:read_log_i16(0x8808BC0D);
  elseif game == "kinst2" then  
    p1Height = mem:read_log_i16(0x887FC0BD);
  end
   
  return p1Height;
end


function getP1FrameData(game)
  
  if game == "kinst" then
    p1Startup = mem:read_log_u8(0x8808BCC3);
    p2Active = 0;
    p2Recovery = 0;
    
    p1FrameData = (p1Startup .. "/" .. p1Active .. "/" .. p1Recovery);
  end
  return p1FrameData;
end

 function getP2State(game)
   
  if game == "kinst" then
    readState = mem:read_log_u8(0x8808BD2C);
    p2State = "?";
    if readState == 0x00 then
      p2State = "Neutral"
    elseif readState == 0x01 then
      p2State = "Crouch"
    elseif readState == 0x02 then
      p2State = "Jump"
    elseif readState == 0x04 then
      p2State = "Stand"
    elseif readState == 0x06 then
      p2State = "Air"
    elseif readState == 0x0C then
      p2State = "Standing Block"
    elseif readState == 0x0D then
      p2State = "Crouching Block"
    elseif readState == 0x14 then
      p2State = "Hurt"
      isP2Hurt = true
    elseif readState == 0x44 then
      p2State = "Blocked Standing Hit"
    elseif readState == 0x45 then
      p2State = "Blocked Crouching Hit"
    elseif readState == 0x46 then
      p2State = "Blocked Aerial Hit"
    elseif readState == 0xC4 then
      p2State = "Standing Hit"
    elseif readState == 0xC5 then
      p2State = "Crouching Hit"
    elseif readState == 0xC6 then
      p2State = "Aerial Hit"
    else
      p2State = ""
    end
  elseif game == "kinst2" then
    readState = mem:read_log_u8(0x887FC1DC);
    p2State = "?";
    if readState == 0x00 then
      p2State = "Neutral"
    elseif readState == 0x01 then
      p2State = "Crouch"
    elseif readState == 0x02 then
      p2State = "Jump"
    elseif readState == 0x04 then
      p2State = "Stand"
    elseif readState == 0x06 then
      p2State = "Air"
    elseif readState == 0x0C then
      p2State = "Standing Block"
    elseif readState == 0x0D then
      p2State = "Crouching Block"
    elseif readState == 0x14 then
      p2State = "Hurt"
      isP2Hurt = true
    elseif readState == 0x44 then
      p2State = "Blocked Standing Hit"
    elseif readState == 0x45 then
      p2State = "Blocked Crouching Hit"
    elseif readState == 0x46 then
      p2State = "Blocked Aerial Hit"
    elseif readState == 0xC4 then
      p2State = "Standing Hit"
    elseif readState == 0xC5 then
      p2State = "Crouching Hit"
    elseif readState == 0xC6 then
      p2State = "Aerial Hit"
    else
      p2State = ""
    end
  end
return p2State;  

end

 function getP2Damage(game)
  if game == "kinst" then
    p2CurrentHealth = mem:read_log_u8(0x8808BD55);
  elseif game == "kinst2" then
    p2CurrentHealth = mem:read_log_u8(0x887FC205);
  end
  
  --for d = 120, p2CurrentHealth, - p2CurrentHealth do
   -- print (d);
  --if isP2Hurt == true then
    --p2LastHealth = prevFrame(p2CurrentHealth)
    --p2Damage = p2LastHealth - p2CurrentHealth;
    --p2Damage = p2CurrentHealth;
  --else if g == "kinst2" then
    --p2Health = mem:read_log_u8();
  --end  
  return p2CurrentHealth;
end

function getP2Stun(game) 
  p2Stun = 0;
    if isP2Hurt == true then
      p2Stun = mem:read_log_u16(0x8808BD92);
    end
  --else if g == "kinst2" then
    --p2Stun = mem:read_log_u16();
return p2Stun;

end


function getP2Power(game)
  
  if game == "kinst2" then
      p2Power = mem:read_log_u8(0x887FBFB4);
  end
  
  return p2Power;
end
  

function getP2Height(game)
  
  if game == "kinst" then
    p2Height = mem:read_log_i16(0x8808BD0D);
  elseif game == "kinst2" then  
    p2Height = mem:read_log_i16(0x887FC1BD);
  end
   
  return p2Height;
end


function getP2FrameData(game)
  
  if game == "kinst" then
    p2Startup = mem:read_log_u8(0x8808BDC3);
    p2Active = 0;
    p2Recovery = 0;
    
    p2FrameData = (p2Startup .. "/" .. p2Active .. "/" .. p2Recovery);
  end
  return p2FrameData;
end
 function draw_hud() 
  if game == "kinst" then
    if mem:read_log_u8(0x8808BD01) ~= 0x00 then
      
      --kinst Player 1 info
      s:draw_box(20, 25, 140, 80, 0x80660066, 0xff0000ff)
      s:draw_text(25, 30, "Health: " .. getP1Damage("kinst"))
      s:draw_text(25, 38, "Stun: " .. getP1Stun("kinst"))
      s:draw_text(25, 46, "Player State: " .. getP1State("kinst"))
      s:draw_text(25, 54, "Height: " .. getP1Height("kinst"))
      s:draw_text(25, 62, "Frames: " .. getP1FrameData("kinst"))
  
      --kinst Player 2 info
      s:draw_box(180, 25, 300, 80, 0x80660066, 0xff0000ff)
      s:draw_text(185, 30, "Health: " .. getP2Damage("kinst"))
      s:draw_text(185, 38, "Stun: " .. getP2Stun("kinst"))
      s:draw_text(185, 46, "Player State: " .. getP2State("kinst"))
      s:draw_text(185, 54, "Height: " .. getP2Height("kinst"))
      s:draw_text(185, 62, "Frames: " .. getP2FrameData("kinst"))
    end
  elseif game == "kinst2" then
    if mem:read_log_u8(0x887FC1B1) ~= 0x00 then
  
      --kinst2 Player 1 info
      s:draw_box(20, 32, 140, 86, 0x80660066, 0xffff0000)
      s:draw_text(25, 37, "Health: " .. getP1Damage("kinst2"))
      s:draw_text(25, 45, "Power: " .. getP1Power("kinst2"))
      s:draw_text(25, 53, "Player State: " .. getP1State("kinst2"))
      s:draw_text(25, 61, "Height: " .. getP1Height("kinst2"))
      
      
      --kinst2 Player 2 info
      s:draw_box(180, 32, 300, 86, 0x80660066, 0xffff0000)
      s:draw_text(185, 37, "Health: " .. getP2Damage("kinst2"))
      s:draw_text(185, 45, "Power: " .. getP2Power("kinst2"))
      s:draw_text(185, 53, "Player State: " .. getP2State("kinst2"))
      s:draw_text(185, 61, "Height: " .. getP2Height("kinst2"))
    end
  end  
end
  

--emu.register_frame(prevFrame, "frame")
  emu.register_frame_done(tick, "frame");
  emu.register_frame_done(draw_hud, "frame");

