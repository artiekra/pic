local transform_scale = {}


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


--- Apply the scale transform to the vertex.
-- Scales a vertex with respect to a specified origin
-- @param vertex table containing x,y,z coordinates of the vertex to scale
-- @param options table containing scale factors and origin coordinates
-- @return table with scaled x,y,z coordinates
local function apply_to_vertex(vertex, options)
    -- Unpack input coordinates
    local x, y, z = table.unpack(vertex)
    local scale = vertex_helpers.compile(options[1])
    local origin = vertex_helpers.compile(options[2])
    local scale_x, scale_y, scale_z = table.unpack(scale)
    local origin_x, origin_y, origin_z = table.unpack(origin)
    
    -- Translate point to origin
    x = x - origin_x
    y = y - origin_y
    z = z - origin_z
    
    -- Apply scaling
    x = x * scale_x
    y = y * scale_y
    z = z * scale_z
    
    -- Translate back
    x = x + origin_x
    y = y + origin_y
    z = z + origin_z
    
    return {x, y, z}
end


--- Apply the scale transform to the mesh.
-- Scales all the vertices according to the origin
function transform_scale.apply(mesh, options)
    local vertexes = mesh[1]

    local new_vertexes = {}
    for _, vertex in ipairs(vertexes) do
        local new_vertex = apply_to_vertex(vertex, options)
        table.insert(new_vertexes, new_vertex)
    end

    mesh[1] = new_vertexes
    return mesh
end


return transform_scale
