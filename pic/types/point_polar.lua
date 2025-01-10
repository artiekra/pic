-- Meta PointPolar class
PointPolar = {r = 0, a = 0, z = 0}
PointPolar.__index = PointPolar


--- Create a PointPolar object.
-- A simple point in space using polar coordinate system. Note that z-plane
-- is specified in cartesian system (this is *not* a spherical coordinate
-- system point).
-- @param r distance
-- @param a angle
-- @param z z coordinate
-- @return PointPolar object
function PointPolar:new(r, a, z)

  local object = setmetatable({}, self)

  object.r = r
  object.a = a
  object.z = z or 0

  return object
end


--- Compile the PointPolar object.
-- @return the coordinates of the point
function PointPolar:compile()

  local x = self.r * math.cos(self.a)
  local y = self.r * math.sin(self.a)
  local z = self.z

	return {x, y, z}
end


return PointPolar
