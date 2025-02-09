-- TODO: potentially introduce class privacy
-- TODO: improve commenting (LDoc stuff too)
-- TODO: implement copy_vsc and copy_object
local pic = {}

pic._VERSION = "1.0.0"


-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


-- Importing and including Mesh class
pic.Mesh = relative_import("mesh.lua")

-- Import types to be added to the library
local PointClass = relative_import("types/point.lua")
local PointPolarClass = relative_import("types/point_polar.lua")
local ColorClass = relative_import("types/color.lua")
local ColorRgbClass = relative_import("types/color_rgb.lua")
local ColorRgbaClass = relative_import("types/color_rgba.lua")
local ColorHsvClass = relative_import("types/color_hsv.lua")


-- Add all the neccesary methods for a certain type
-- to the library
local function add_type_methods(name, class)

  pic[name] = function(...)
    return class:new(...)
  end

 
end


add_type_methods("Point", PointClass)
add_type_methods("PointPolar", PointPolarClass)

add_type_methods("Color", ColorClass)
add_type_methods("ColorRGB", ColorRgbClass)
add_type_methods("ColorRGBA", ColorRgbaClass)
add_type_methods("ColorHSV", ColorHsvClass)


--- Define many meshes
function pic.define_meshes(n, constants)

  local n = n or 1

  local meshes = {}
  for i=1, n do
    
    local new_mesh = pic.Mesh:new(constants)
    table.insert(meshes, new_mesh)

  end

  return meshes
end


--- Compile many meshes
function pic.compile_meshes(meshes)
  
  local results = {}
  for _, mesh in ipairs(meshes) do
    table.insert(results, mesh:compile())
  end
  
  return results
end


function pic.print_memory_usage(title)

  local memory_usage_raw = collectgarbage("count")
  local memory_usage = string.format("%i%s %i%s", memory_usage_raw // 1,
    "KB", memory_usage_raw % 1 * 1024, "B")
  
  if title == nil then
    pewpew.print("💾 Memory usage: "..memory_usage)
  elseif type(title) == "string" then
    pewpew.print("💾 "..title.." (memory usage): "..memory_usage)
  else
    error("nil or string expected to represent memory usage print title")
  end

end


return pic 
