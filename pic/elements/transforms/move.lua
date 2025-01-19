local transform_move = {}


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


--- Apply the move transform to the vertex.
-- Moves the vertex by a certain offset
local function apply_to_vertex(vertex, point)

  local new_x = vertex[1] + point[1]
  local new_y = vertex[2] + point[2]
  local new_z = vertex[3] + point[3]

  return {new_x, new_y, new_z}
end


--- Apply the move transform to the mesh.
-- Moves all the vertexes by a certain offset
function transform_move.apply(mesh, options)

  local vertexes = mesh[1]

  local new_vertexes = {}
  for _, vertex in ipairs(vertexes) do
    local point = vertex_helpers.compile(options[1])
    local new_vertex = apply_to_vertex(vertex, point)
    table.insert(new_vertexes, new_vertex)
  end

  mesh[1] = new_vertexes
  return mesh
end


return transform_move
