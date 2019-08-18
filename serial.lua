-- FlashAir W-04 - Serial + Motor Driver
-- Motor Driver Serial Command
--  init   "E"
--  drive  "M0F0" - "M0F100" / "M0R0" - "M0R100"
--  deinit "D"
STATE_SPEED = 0
STATE_TR = 1

function send_serial_command(data)
	fa.serial("write", data .. "\r\n")
	print("send_serial_command data[" .. data .. "]")
end

function controlSpeed(speednum, tr)
	if(speednum < 0) then return end
	if(speednum > 200) then return end
	if (tr == 1) then
		sendtxt = "M0F" .. speednum/2
		send_serial_command(sendtxt)
	else
		sendtxt = "M0R" .. speednum/2
		send_serial_command(sendtxt)
	end
end

function motorDriverOpen()
	send_serial_command("E")
end

function motorDriverClose()
	send_serial_command("D")
end

function getSharedMem()
  local b = fa.sharedmemory("read", 0, 4)
  if (b == nil) then
    return 0
  else
    STATE_SPEED = tonumber(string.sub(b, 1, 3))
    STATE_TR  = tonumber(string.sub(b, 4, 4))
  end
  return 1
end

function initSharedMem()
  local c = fa.sharedmemory("write", 0, 4, "0000")
  if (c ~= 1) then
    return 0
  end
  return 1
end

res = fa.serial("init", 9600)
motorDriverOpen()

local r = initSharedMem()
if(r ~= 1) then
  motorDriverClose()
  return
end
sleep(1000)
while(1) do
  local tmp_spd = STATE_SPEED
  local tmp_tr = STATE_TR
  r = getSharedMem()
  if(r == 1) then
    if(tmp_spd ~= STATE_SPEED or tmp_tr ~= STATE_TR) then
      controlSpeed(STATE_SPEED, STATE_TR)
    end
  end
  sleep(100)
  collectgarbage("collect")
end
motorDriverClose()


