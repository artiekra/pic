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
local transform_scale = relative_import("transforms/scale.lua")
local transform_shear = relative_import("transforms/shear.lua")


--- Parse Line object options
-- Parse and verify the options for Line object
-- @param options raw options
-- @returned parsed option table
local function parse_options(options)

  local options = options or {}

  assert(type(options) == "table",
    "nil or table expected to represent Line options")

  local width = options.width or 1
  local no_gradient = options.no_gradient or false

  assert(type(width) == "number",
    "number expected to represent Line's width option")
  assert(type(no_gradient) == "boolean",
    "boolean expected to represent Line's no_gradient option")

  return {width = width, no_gradient = no_gradient}
end


--- Create a Line object.
-- A simple line that goes through two given points
-- @param point1 first point
-- @param point2 second point
-- @param colors line colors - any amount (nil, number, color object, or a
--  table containing numbers or color objects expected)
-- @param options no_gradient, width
-- @return Line object
function Line:new(point1, point2, colors, options)

  local object = setmetatable({}, self)

  object.point1 = vertex_helpers.compile(point1)
  object.point2 = vertex_helpers.compile(point2)
  object.colors = color_helpers.compile(colors, true)
  object.options = parse_options(options)
  object.transforms = {}

  return object
end


--- Compile the Line object.
-- @return the VSC table for the line
function Line:compile(constants)

  local computed_colors
  if #self.colors == 0 then
    computed_colors = {0xffffff00, 0xffffff00}
  elseif #self.colors == 1 then
    local color = self.colors[1]
    computed_colors = {color, color}
  else
    computed_colors = self.colors
  end

  local computed_vertexes = {}
  table.insert(computed_vertexes, self.point1)

  if self.options.no_gradient then

    local ld = constants.GRADIENT_PREVENTION_VERTEX_SPACING

    local new_computed_colors = {}
    table.insert(new_computed_colors, computed_colors[1])

    -- (#computed_colors - 2) + 1, because we need the same
    --   amount of segments as colors
    local intermediate_points = #computed_colors - 1
    for i=1, intermediate_points do
      local a = i / (intermediate_points + 1)
      local x1 = lerp_helpers.lerp(self.point1[1], self.point2[1], a-ld)
      local y1 = lerp_helpers.lerp(self.point1[2], self.point2[2], a-ld)
      local z1 = lerp_helpers.lerp(self.point1[3], self.point2[3], a-ld)
      table.insert(computed_vertexes, {x1, y1, z1})
      table.insert(new_computed_colors, computed_colors[i])
      local x2 = lerp_helpers.lerp(self.point1[1], self.point2[1], a+ld)
      local y2 = lerp_helpers.lerp(self.point1[2], self.point2[2], a+ld)
      local z2 = lerp_helpers.lerp(self.point1[3], self.point2[3], a+ld)
      table.insert(computed_vertexes, {x2, y2, z2})
      table.insert(new_computed_colors, computed_colors[i+1])
    end

    table.insert(new_computed_colors, computed_colors[#computed_colors])
    computed_colors = new_computed_colors

  else

    local intermediate_points = #computed_colors - 2
    for i=1, intermediate_points do
      local a = i / (intermediate_points + 1)
      local x = lerp_helpers.lerp(self.point1[1], self.point2[1], a)
      local y = lerp_helpers.lerp(self.point1[2], self.point2[2], a)
      local z = lerp_helpers.lerp(self.point1[3], self.point2[3], a)
      table.insert(computed_vertexes, {x, y, z})
    end

  end

  table.insert(computed_vertexes, self.point2)

  local mesh = mesh_helpers.add_polygon(nil, computed_vertexes,
    computed_colors, constants, {width=self.options.width})

  for _, transform in ipairs(self.transforms) do
    local transform_type = transform[1]
    local transform_options = transform[2]

    if transform_type == "move" then
      mesh = transform_move.apply(mesh, transform_options)
    elseif transform_type == "rotate" then
      mesh = transform_rotate.apply(mesh, transform_options)
    elseif transform_type == "scale" then
      mesh = transform_scale.apply(mesh, transform_options)
    elseif transform_type == "shear" then
      mesh = transform_shear.apply(mesh, transform_options)
    end
  end

  return mesh
end


class_helpers.add_transform_methods(Line)


return Line
