-- Meta Color class
Color = {value = 0}
Color.__index = Color


--- Create a Color object.
-- A simple hex color value.
-- @param v value
-- @return Color object
function Color:new(v)

  local object = setmetatable({}, self)

  object.value = v

  return object
end


--- Compile the Color object.
-- @return hex color
function Color:compile()
  return self.value
end


return Color
