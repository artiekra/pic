-- Meta Line class
Line = {point1 = {}, point2 = {}, colors = {},
  transforms = {}}
Line.__index = Line


-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


local vertex_helpers = relative_import("helpers/vertex.lua")
local color_helpers = relative_import("helpers/color.lua")
local mesh_helpers = relative_import("helpers/mesh.lua")
local lerp_helpers = relative_import("helpers/lerp.lua")
local class_helpers = relative_import("helpers/class.lua")

local transform_move = relative_import("transforms/move.lua")
local transform_rotate = relative_import("transforms/rotate.lua")

local inspect = require("/dynamic/inspect.lua")


--- Create a Line object.
-- A simple line that goes through two given points
-- @param point1 first point
-- @param point2 second point
-- @param colors line colors - any amount (nil, number, color object, or a
--  table containing numbers or color objects expected)
-- @return Line object
function Line:new(point1, point2, colors)

  local object = setmetatable({}, self)

  object.point1 = vertex_helpers.compile(point1)
  object.point2 = vertex_helpers.compile(point2)
  object.colors = color_helpers.get_color(colors)
  object.transforms = {}

  return object
end


--- Compile the Line object (no transforms).
-- @param object Line object
-- @return the VSC table for the line
-- TODO: make it a class method, but private?
local function compile_basic(object)

  local computed_colors
  if #object.colors == 0 then
    computed_colors = {0xffffff00, 0xffffff00}
  elseif #object.colors == 1 then
    local color = object.colors[1]
    computed_colors = {color, color}
  else
    computed_colors = object.colors
  end

  local computed_vertexes = {}
  table.insert(computed_vertexes, object.point1)

  local intermediate_points = #computed_colors - 2
  for i=1, intermediate_points do
    local a = i / (intermediate_points + 1)
    local x = lerp_helpers.lerp(object.point1[1], object.point2[1], a)
    local y = lerp_helpers.lerp(object.point1[2], object.point2[2], a)
    local z = lerp_helpers.lerp(object.point1[3], object.point2[3], a)
    table.insert(computed_vertexes, {x, y, z})
  end

  table.insert(computed_vertexes, object.point2)

  return mesh_helpers.add_polygon(nil, computed_vertexes, computed_colors)
end



--- Compile the Line object.
-- @return the VSC table for the line
function Line:compile(no_transforms)

  local mesh = compile_basic(self)

  if no_transforms then
    return mesh
  end

  for _, transform in ipairs(self.transforms) do
    local transform_type = transform[1]
    local transform_options = transform[2]

    if transform_type == "move" then
      mesh = transform_move.apply(mesh, transform_options)
    elseif transform_type == "rotate" then
      mesh = transform_rotate.apply(mesh, transform_options)
    end
  end

  return mesh
end


class_helpers.add_transform_methods(Line)


return Line
