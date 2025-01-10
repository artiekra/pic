-- Meta Point class
Point = {x = 0, y = 0, z = 0}
Point.__index = Point


--- Create a Point object.
-- A simple point in space using cartesian coordinate system.
-- @param x x coordinate
-- @param y y coordinate
-- @param z z coordinate
-- @return Point Point object
function Point:new(x, y, z)

  local object = setmetatable({}, self)

  object.x = x
  object.y = y
  object.z = z or 0

  return object
end


--- Compile the Point object.
-- @return the coordinates of the point
function Point:compile()
  return {self.x, self.y, self.z}
end


return Point
