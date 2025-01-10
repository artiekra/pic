-- Meta Line class
Line = {point1 = {}, point2 = {}, outline = 0}
Line.__index = Line


function Line:new(point1, point2, outline)

  local object = setmetatable({}, self)

  object.point1 = point1
  object.point2 = point2
  object.outline = outline

  return object
end


function Line:compile()

  local computed_vertexes = {self.point1, self.point2}
  local computed_segments = {{0, 1}}
  local computed_colors = {self.outline, self.outline}

  return {computed_vertexes, computed_segments, computed_colors}
end


return Line
