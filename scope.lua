-- scope for crow

-- rising: crow study 2
-- input modes
--
-- input 1 is stream/query
-- input 2 is change
--
-- K2 query
-- K3 toggle mode

local volts = 0
local state = 0
local history = {}

function init()
  crow.input[1].mode("stream")
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
  history[0] = v
  for i=127, 1, -1 do
    history[i] = history[i-1]
  end
  history[128] = nil
  redraw()
end

function redraw()
  screen.clear()
  screen.move(6,60)
  screen.text("volts: "..string.format("%.3f",volts))
  for i = 127, 0, -1 do
    screen.pixel(i, history[i]*-4 + 30)
    screen.stroke()
  end
  screen.update()
end

function getLength(t)
  count = 0 
  for _ in t do
    count = count + 1
  end
  return count
end

function key(n,z)
end 
