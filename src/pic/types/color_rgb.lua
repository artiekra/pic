-- Meta ColorRGB class
ColorRGB = {red = 0, green = 0, blue = 0}
ColorRGB.__index = ColorRGB


--- Create a ColorRGB object.
-- A simple RGB color value.
-- @param r red color channel
-- @param g green color channel
-- @param b blue color channel
-- @return ColorRGB object
function ColorRGB:new(r, g, b)

  local object = setmetatable({}, self)

  object.red = r
  object.green = g
  object.blue = b

  return object
end


--- Compile the ColorRGB object.
-- @return hex color
function ColorRGB:compile()
  return (self.red << 24) | (self.green << 16) | (self.blue << 8) | 0xff
end


return ColorRGB
