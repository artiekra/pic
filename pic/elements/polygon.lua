-- Meta Polygon class
Polygon = {points = {}, colors = {}, transforms = {}}
Polygon.__index = Polygon


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


--- Parse Polygon object options
-- Parse and verify the options for Polygon object
-- @param options raw options
-- @returned parsed option table
local function parse_options(options)

  local options = options or {}

  assert(type(options) == "table",
    "nil or table expected to represent Line options")

  local width = options.width or 1

  assert(type(width) == "number",
    "number expected to represent Line's width option")

  return {width = width}
end


--- Create a Polygon object.
-- A simple (closed/open) polygonal chain that goes through given points
-- @param points chain points
-- @param colors colors - one for each vertex (nil, number, color object,
--   or a table containing numbers or color objects expected)
-- @param options width
-- @return Polygon object
function Polygon:new(points, colors, options)

  local object = setmetatable({}, self)

  object.points = vertex_helpers.compile(points, true)
  object.colors = color_helpers.compile(colors, true)
  object.options = parse_options(options)
  object.transforms = {}

  assert(#object.points == #object.colors,
    "the same amount of colors as point expected to represent Polygon object")

  return object
end


--- Compile the Polygon object (no transforms).
-- @param object Polygon object
-- @return the VSC table for the polygonal chain
-- TODO: make it a class method, but private?
local function compile_basic(object, constants)

  return mesh_helpers.add_polygon(nil, constants, object.points,
    object.colors, object.options.width)
end



--- Compile the Polygon object.
-- @return the VSC table for the polygonal chain
function Polygon:compile(constants)

  local mesh = compile_basic(self, constants)

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


class_helpers.add_transform_methods(Polygon)


return Polygon
