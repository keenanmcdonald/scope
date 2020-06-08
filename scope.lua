-- scope for crow
--
--key 2: toggle xaxis
--key 3: toggle input 2 display
--enc 2: adjust rate
--enc 3: adjust xaxis offset

local volts1 = 0
local volts2 = 0
local state = 0
history1 = {}
history2 = {}
local rate = 50
local xaxis = false
local yrange = 2
local offset = 24
display2 = false

function init()
  crow.input[1].mode("stream", 1/rate)
  crow.input[1].stream = stream1
  crow.input[2].mode("stream", 1/rate)
  crow.input[2].stream = stream2
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
  initHistory()
  redraw()
end

function initHistory()
  for i = 0, 127 do
    history1[i] = 0
    history2[i] = 0
  end
end


function stream1(v)
  volts1 = v
  --history[0] = round(v*yrange * -1)
  history1[0] = v

  for i=127, 1, -1 do
    history1[i] = history1[i-1]
  end
  history1[128] = nil
  redraw()
end

function stream2(v)
  volts2 = v
  history2[0] = v
  for i=127, 1, -1 do
    history2[i] = history2[i-1]
  end
  history2[128] = nil
  redraw()
end

function redraw()
  screen.clear()
  screen.move(2,60)
  screen.text("volts: "..string.format("%.3f",volts1))
  screen.move(60, 60)
  --screen.text("offset: "..string.format(offset))
  screen.text("rate: "..string.format("%.2f",rate).."px/s")
  screen.line_width(1)
  --screen.pixel(40,40)
  for i = 127, 0, -1 do
    screen.move(i, round(history1[i]*yrange*-1) + offset)
    screen.line_rel(0, -1)
    screen.stroke()
    if display2 then
      screen.move(i, round(history2[i]*yrange*-1) + offset)
      screen.line_rel(0, -1)
      screen.stroke()
    end
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
  if n==1 then
    yrange = util.clamp(yrange + z*.5, 1, 8)
  elseif n==2 then
    rate = util.clamp(rate + z, 1, 100)
    crow.input[1].mode("stream", 1/rate)
  elseif n==3 then
    offset = util.clamp(offset - z, 0, 50)
  end
end 

function key(n, z)
  if n==2 and z==1 and xaxis then
    xaxis = false
  elseif n==2 and z==1 and not axis then
    xaxis = true
  elseif n==3 and z==1 and display2 then
    display2 = false
  elseif n==3 and z==1 and not display2 then
    display2 = true
  end
end