-- TODO: potentially introduce class privacy
-- TODO: improve commenting (LDoc stuff too)
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


pic.Mesh = relative_import("mesh.lua")
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


return pic 
