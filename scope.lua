-- scope for crow
--
--key 2: toggle xaxis
--key 3: toggle input 2 display
--enc 2: adjust rate (hold key 1 to finetune)
--enc 3: adjust xaxis offset

local volts1 = 0
local volts2 = 0
local state = 0
local history1 = {}
local history2 = {}
local rate = .5
local xaxis = false
local yrange = 2
local offset = 24
local display2 = false
local displayMode = 1
local enc3Mode = 'yrange'

function init()
  crow.input[1].mode("stream", 1/(rate*127))
  crow.input[1].stream = stream1
  crow.input[2].mode("stream", 1/(rate*127))
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
  if displayMode == 1 then
    screen.move(2,60)
    screen.text("volts(1): "..string.format("%.3f",volts1))
    screen.move(64, 60)
    screen.text("volts(2): "..string.format("%.3f",volts2))
  elseif displayMode == 2 then
    screen.move(2,60)
    screen.text("rate: "..string.format(rate).." hz")
  elseif displayMode == 3 then
    screen.move(0, 56)
    screen.line_rel(127, 0)
    xaxisRange = math.floor(1/rate)
    xaxisSpec = 2
    for i=1, xaxisRange*xaxisSpec do
      screen.move(round((127*rate*i)/xaxisSpec), 56)
      screen.line_rel(0,2)
      screen.move(round((127*rate*i)/xaxisSpec)-2, 64)
      screen.font_size(8)
      screen.text(string.format(i/xaxisSpec))
    end
  end
  screen.line_width(1)
  for i = 127, 0, -1 do
    screen.move(127-i, round(history1[i]*yrange*-1) + offset)
    screen.line_rel(0, -1)
    screen.stroke()
    if display2 then
      screen.move(127-i, round(history2[i]*yrange*-1) + offset)
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
    displayMode = util.clamp(displayMode + z, 1, 3)
  elseif n==2 then
    rate = util.clamp(rate + z*.01, .01, 2)
    crow.input[1].mode("stream", 1/(rate*127))
    crow.input[2].mode("stream", 1/(rate*127))
  elseif n==3 then
    if enc3Mode == 'offset' then
      offset = util.clamp(offset - z, 0, 50)
    elseif enc3Mode == 'yrange' then
      yrange = util.clamp(yrange + z*.5, 1, 8)
    end
  end
end 

function key(n, z)
  if n==1 and z==1 then
    enc3Mode = 'offset'
  elseif n==1 and z==-1 then
    enc3Mode = 'yrange'
  elseif n==2 and z==1 then
    if xaxis then
      xaxis = false
    else
      xaxis = true
    end
  elseif n==3 and z==1 then
    if display2 then
      display2 = false
    else
      display2 = true
    end
  end
end