-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


local driver = relative_import("driver/init.lua")

local vertex_helpers = relative_import("helpers/vertex.lua")
local color_helpers = relative_import("helpers/color.lua")
local lerp_helpers = relative_import("helpers/lerp.lua")
local transform_helpers = relative_import("helpers/transform.lua")

local ElementBase = relative_import("base.lua")


-- Meta Polygon class
Polygon = {points = {}, colors = {}}
Polygon  = setmetatable(Polygon, ElementBase)
Polygon.__index = Polygon


--- Parse Polygon object options
-- Parse and verify the options for Polygon object
-- @param options raw options
-- @returned parsed option table
local function parse_options(options)

  local options = options or {}

  assert(type(options) == "table",
    "nil or table expected to represent Polygon options")

  local width = options.width or 1
  local is_closed
  if options.is_closed == nil then
    is_closed = true
  else
    is_closed = options.is_closed
  end
  local joint = options.joint or "none"

  assert(type(width) == "number",
    "number expected to represent Polygon's width option")
  assert(type(is_closed) == "boolean",
    "boolean expected to represent Polygon's is_closed option")
  assert(type(joint) == "string",
    "string expected to represent Polygon's joint option")

  return {width = width, is_closed = is_closed, joint = joint}
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

  assert(#object.points == #object.colors or #object.colors == 0 or
    #object.colors == 1, "0, 1, or the same amount of colors as points "..
    "expected to represent Polygon object")

  return object
end


--- Compile the Polygon object.
-- @return the VSC table for the polygonal chain
function Polygon:compile(constants)

  local computed_colors = {}
  if #self.colors == 0 then
    for n=1, #self.points do
      table.insert(computed_colors, 0xffffff00)
    end
  elseif #self.colors == 1 then
    local color = self.colors[1]
    for n=1, #self.points do
      table.insert(computed_colors, color)
    end
  else
    computed_colors = self.colors
  end

  local mesh = driver.add_polygon(nil, self.points,
    computed_colors, constants, {width=self.options.width,
    is_closed=self.options.is_closed, joint=self.options.joint})

  mesh = transform_helpers.apply_transforms(mesh, self.transforms)

  return mesh
end


return Polygon
