local transform_rotate = {}


--- Apply the rotation transform to the vertex.
-- Rotates a vertex according to the origin
-- @param vertex table containing x,y,z coordinates of the vertex to rotate
-- @param options table containing rotation angles and origin
--   coordinates table (for x, y, z)
-- @return table with rotated x,y,z coordinates
local function apply_to_vertex(vertex, options)

    -- Unpack input coordinates
    -- TODO: implement auto-detection of the center of the shape
    local x, y, z = table.unpack(vertex)
    local origin_x, origin_y, origin_z = table.unpack(options[2] or {0,0,0})
    local rot_x, rot_y, rot_z = table.unpack(options[1] or {0,0,0})
    
    -- Translate point to origin
    x = x - origin_x
    y = y - origin_y
    z = z - origin_z
    
    -- Apply X rotation
    local temp_y = y * math.cos(rot_x) - z * math.sin(rot_x)
    local temp_z = y * math.sin(rot_x) + z * math.cos(rot_x)
    y = temp_y
    z = temp_z
    
    -- Apply Y rotation
    local temp_x = x * math.cos(rot_y) + z * math.sin(rot_y)
    temp_z = -x * math.sin(rot_y) + z * math.cos(rot_y)
    x = temp_x
    z = temp_z
    
    -- Apply Z rotation
    temp_x = x * math.cos(rot_z) - y * math.sin(rot_z)
    temp_y = x * math.sin(rot_z) + y * math.cos(rot_z)
    x = temp_x
    y = temp_y
    
    -- Translate back
    x = x + origin_x
    y = y + origin_y
    z = z + origin_z
    
    return {x, y, z}
end


--- Apply the rotation transform to the mesh.
-- Rotates all the vertexes according to the origin
function transform_rotate.apply(mesh, options)

  local vertexes = mesh[1]

  local new_vertexes = {}
  for _, vertex in ipairs(vertexes) do
    local new_vertex = apply_to_vertex(vertex, options)
    table.insert(new_vertexes, new_vertex)
  end

  mesh[1] = new_vertexes
  return mesh
end


return transform_rotate
