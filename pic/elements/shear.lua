local transform_shear = {}


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


--- Apply the shear transform to the vertex.
-- Shears a vertex with respect to a specified origin
-- @param vertex table containing x,y,z coordinates of the vertex to shear
-- @param options table containing shear factors and origin coordinates
-- @return table with sheared x,y,z coordinates
local function apply_to_vertex(vertex, options)
    -- Unpack input coordinates
    local x, y, z = table.unpack(vertex)
    local shear = vertex_helpers.compile(options[1])
    local origin = vertex_helpers.compile(options[2])
    local shear_x, shear_y, shear_z = table.unpack(shear)
    local origin_x, origin_y, origin_z = table.unpack(origin)
    
    -- Translate point to origin
    x = x - origin_x
    y = y - origin_y
    z = z - origin_z
    
    -- Apply shearing
    x = x + shear_x * y + shear_z * z
    y = y + shear_y * x
    z = z + shear_x * x + shear_y * y
    
    -- Translate back
    x = x + origin_x
    y = y + origin_y
    z = z + origin_z
    
    return {x, y, z}
end


--- Apply the shear transform to the mesh.
-- Shears all the vertices according to the origin
function transform_shear.apply(mesh, options)
    local vertexes = mesh[1]

    local new_vertexes = {}
    for _, vertex in ipairs(vertexes) do
        local new_vertex = apply_to_vertex(vertex, options)
        table.insert(new_vertexes, new_vertex)
    end

    mesh[1] = new_vertexes
    return mesh
end


return transform_shear
