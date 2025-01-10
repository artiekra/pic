-- Meta ColorHSV class
ColorHSV = {hue = 0, saturation = 0, value = 0}
ColorHSV.__index = ColorHSV


--- Create a ColorHSV object.
-- A simple HSV color value.
-- @param h hue (0-360 degrees)
-- @param s saturation (0-1)
-- @param v value/brightness (0-1)
-- @return ColorHSV object
function ColorHSV:new(h, s, v)

  local object = setmetatable({}, self)

  object.hue = h
  object.saturation = s
  object.value = v

  return object
end


--- Compile the ColorHSV object.
-- Converts HSV to RGB and returns the compiled hex color.
-- @return hex color
function ColorHSV:compile()
  local h = self.hue / 60
  local s = self.saturation
  local v = self.value

  local c = v * s
  local x = c * (1 - math.abs(h % 2 - 1))
  local m = v - c

  local r, g, b

  if h >= 0 and h < 1 then
    r, g, b = c, x, 0
  elseif h >= 1 and h < 2 then
    r, g, b = x, c, 0
  elseif h >= 2 and h < 3 then
    r, g, b = 0, c, x
  elseif h >= 3 and h < 4 then
    r, g, b = 0, x, c
  elseif h >= 4 and h < 5 then
    r, g, b = x, 0, c
  elseif h >= 5 and h < 6 then
    r, g, b = c, 0, x
  else
    r, g, b = 0, 0, 0
  end

  local red = math.floor((r + m) * 255)
  local green = math.floor((g + m) * 255)
  local blue = math.floor((b + m) * 255)

  return (red << 24) | (green << 16) | (blue << 8) | 0xff
end

return ColorHSV
