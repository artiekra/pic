-- TODO: potentially introduce class privacy
-- TODO: improve commenting (LDoc stuff too)
-- TODO: mesh-wide transforms
-- TODO: implement copy_vsc and copy_object
-- TODO: implement MeshSet
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


function pic.compile_meshes(...)
  
  local results = {}
  for _, mesh in ipairs(table.pack(...)) do
    table.insert(results, mesh:compile())
  end
  
  return results
end


function pic.print_memory_usage()
  
  local memory_usage_raw = collectgarbage("count")
  local memory_usage = string.format("%i%s %i%s", memory_usage_raw // 1,
    "KB", memory_usage_raw % 1 * 1024, "B")

  print("💾 Memory usage: "..memory_usage)

end


return pic 
