-- Meta ColorRGBA class
ColorRGBA = {red = 0, green = 0, blue = 0, alpha = 0}
ColorRGBA.__index = ColorRGBA


--- Create a ColorRGBA object.
-- A simple RGB color value.
-- @param r red color channel
-- @param g green color channel
-- @param b blue color channel
-- @param a alpha (opacity) channel
-- @return ColorRGBA object
function ColorRGBA:new(r, g, b, a)

  local object = setmetatable({}, self)

  object.red = r
  object.green = g
  object.blue = b
  object.alpha = a

  return object
end


--- Compile the ColorRGBA object.
-- @return hex color
function ColorRGBA:compile()
  return (self.red << 24) | (self.green << 16) | (self.blue << 8) | self.alpha
end


return ColorRGBA
