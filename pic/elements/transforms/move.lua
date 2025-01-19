local transform_move = {}


--- Apply the move transform to the vertex.
-- Moves the vertex by a certain offset
local function apply_to_vertex(vertex, options)

  local offset_x = options[1] or 0
  local offset_y = options[2] or 0
  local offset_z = options[3] or 0

  local new_x = vertex[1] + offset_x
  local new_y = vertex[2] + offset_y
  local new_z = vertex[3] + offset_z

  return {new_x, new_y, new_z}
end


--- Apply the move transform to the mesh.
-- Moves all the vertexes by a certain offset
function transform_move.apply(mesh, options)

  local vertexes = mesh[1]

  local new_vertexes = {}
  for _, vertex in ipairs(vertexes) do
    local new_vertex = apply_to_vertex(vertex, options)
    table.insert(new_vertexes, new_vertex)
  end

  mesh[1] = new_vertexes
  return mesh
end


return transform_move
