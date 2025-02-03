local transform_helpers = {}


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



local move_transform = relative_import("../transforms/move.lua")
local rotate_transform = relative_import("../transforms/rotate.lua")
local scale_transform = relative_import("../transforms/scale.lua")
local shear_transform = relative_import("../transforms/shear.lua")
local transform_modules = {move = move_transform,
  rotate = rotate_transform, scale = scale_transform,
  shear = shear_transform}


--- Decodes and applies transforms to a given mesh
function transform_helpers.apply_transforms(mesh, transforms)

  for _, transform in ipairs(transforms) do
    local transform_type = transform[1]
    local transform_options = transform[2]

    mesh = transform_modules[transform_type].apply(
      mesh, transform_options
    )
  end

  return mesh
end


return transform_helpers
