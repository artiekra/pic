local vertex = {}


--- Get vertex from a point.
-- Compiles point (a table, class, etc) into a mesh vertex
-- @param point given point
-- @return vertex
function vertex.get_vertex(point)

  -- if a support classes, use compile function
  if point.compile then
    return point:compile()
  end

  -- otherwise get the coordinates
  local x = point["x"] or point[1] or 0
  local y = point["y"] or point[2] or 0
  local z = point["z"] or point[3] or 0

  return {x, y, z}
end


return vertex
