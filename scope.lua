-- scope for crow
--
--key 2: toggle xaxis
--enc 2: adjust rate
--enc 3: adjust xaxis offset

local volts = 0
local state = 0
local history = {}
local rate = 50
local xaxis = false
local offset = 24

function init()
  crow.input[1].mode("stream", 1/rate)
  crow.input[1].stream = stream
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
  initHistory()
  redraw()
end

function initHistory()
  for i = 0, 127 do
    history[i] = 0
  end
end

function stream(v)
  volts = v
  history[0] = round(v*-2)
  for i=127, 1, -1 do
    history[i] = history[i-1]
  end
  history[128] = nil
  redraw()
end

function redraw()
  screen.clear()
  screen.move(2,60)
  screen.text("volts: "..string.format("%.3f",volts))
  screen.move(60, 60)
  --screen.text("offset: "..string.format(offset))
  screen.text("rate: "..string.format("%.2f",rate).."px/s")
  screen.line_width(1)
  --screen.pixel(40,40)
  for i = 127, 0, -1 do
    --screen.pixel(i, history[i])
    screen.move(i, history[i] + offset)
    screen.line_rel(0, -1)
    screen.stroke()
  end
  if xaxis then
    screen.move(0, offset)
    screen.line_rel(127,0)
    screen.stroke()
  end
  screen.update()
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(math.floor(num * mult + 0.5) / mult)
end

function getLength(t)
  count = 0 
  for _ in t do
    count = count + 1
  end
  return count
end

function enc(n,z)
  if n==2 then
    rate = util.clamp(rate + z, 1, 100)
    crow.input[1].mode("stream", 1/rate)
  elseif n==3 then
    offset = util.clamp(offset - z, 0, 60)
  end
end 

function key(n, z)
  if n==2 and z==1 and xaxis then
    xaxis = false
  elseif n==2 and z==1 and not axis then
    xaxis = true
  end
end