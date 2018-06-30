-- ver 0.2a, 6/30/2018
-- code by @CSword123, Special Thanks: Abystus, jedpossum
cpu = manager:machine().devices[":maincpu"];
mem = cpu.spaces["program"];
s = manager:machine().screens[":screen"];
--currFrameCount = s:frame_number();
--prevFrameCount = currFrameCount - 1;
game = emu.romname("kinst", "kinst2");

--for k,v in pairs(manager:machine().devices) do print(k) end

local p2State = "";
local isP2Hurt = false;
local p2Damage = 0;
local p2Stun = 0;
local p2Power = 0;
local readState = 0x00;
local MAX_HEALTH = 120;
local p2NextHealth = 0;
local p2CurrentHealth = 0;
local p2Height = 0;

function tick() 

 
  
  updateP2State = getP2State(game);
  updateP2Damage = getP2Damage(game);
  updateP2Stun = getP2Stun(game);
 
 --print("curr Health: " .. updateP2Damage .. " curr Frame Count: " .. currFrameCount);
 --print("curr Health: " .. updateP2Damage .. " curr Stun: " .. updateP2Stun .. " curr State: " .. updateP2State);
end  

--function prevFrame(p2currentHealth)
  
 
 --print("prev Health: " .. p2CurrentHealth .. " prev Frame Count: " .. prevFrameCount)
 --return p2CurrentHealth
--end

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


 function draw_hud() 
  if game == "kinst" then
  
    s:draw_box(180, 25, 300, 80, 0x80660066, 0xff0000ff)
    s:draw_text(185, 30, "Health: " .. getP2Damage("kinst"))
  
  
    s:draw_text(185, 38, "Stun: " .. getP2Stun("kinst"))
 
    s:draw_text(185, 46, "Player State: " .. getP2State("kinst"))
    s:draw_text(185, 54, "Height: " .. getP2Height("kinst"))
  elseif game == "kinst2" then
  
    s:draw_box(180, 32, 300, 86, 0x80660066, 0xffff0000)
    s:draw_text(185, 37, "Health: " .. getP2Damage("kinst2"))
  
  
    s:draw_text(185, 45, "Power: " .. getP2Power("kinst2"))
 
    s:draw_text(185, 53, "Player State: " .. getP2State("kinst2"))
    s:draw_text(185, 61, "Height: " .. getP2Height("kinst2"))
  end  
end
  

--emu.register_frame(prevFrame, "frame")
emu.register_frame_done(tick, "frame");

emu.register_frame_done(draw_hud, "frame");
