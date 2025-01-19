local transform_rotate = {}


-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
-- (with support for going up the directory tree)
local function relative_import(file)
    local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
    
    -- split both paths into segments
    local base_segments = {}
    for segment in library_folder:gmatch("[^/]+") do
        table.insert(base_segments, segment)
    end
    
    local file_segments = {}
    for segment in file:gmatch("[^/]+") do
        if segment == ".." then
            -- remove last segment when we see ..
            table.remove(base_segments)
        else
            table.insert(file_segments, segment)
        end
    end
    
    -- reconstruct the path
    local final_path = table.concat(base_segments, "/") .. "/" ..
      table.concat(file_segments, "/")
    
    return require("/" .. final_path)
end


local vertex_helpers = relative_import("../helpers/vertex.lua")


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
    local rot = vertex_helpers.compile(options[1])
    local origin = vertex_helpers.compile(options[2])
    local rot_x, rot_y, rot_z = table.unpack(rot)
    local origin_x, origin_y, origin_z = table.unpack(origin)
    
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
