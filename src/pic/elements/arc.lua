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
local transform_helpers = relative_import("helpers/transform.lua")

local ElementBase = relative_import("base.lua")


-- Meta Arc class
Arc = {}
Arc = setmetatable(Arc, ElementBase)
Arc.__index = Arc


--- Parse Arc object options.
-- Parses and verifies options for an Arc object.
-- @param options raw options
-- @return parsed option table
local function parse_options(options)
  local options = options or {}
  
  -- Default arc options:
  -- width: line width (number)
  -- is_closed: should the arc be closed (usually false) 
  -- joint: style for the joints between segments
  local width = options.width or 1
  local is_closed = false
  if options.is_closed ~= nil then
    is_closed = options.is_closed
  end
  local joint = options.joint or "none"

  assert(type(width) == "number",
    "number expected to represent Arc's width option")
  assert(type(is_closed) == "boolean",
    "boolean expected to represent Arc's is_closed option")
  assert(type(joint) == "string",
    "string expected to represent Arc's joint option")

  return {width = width, is_closed = is_closed, joint = joint}
end


--- Create an Arc object.
-- An arc is defined by its center, horizontal and vertical radii,
-- the starting and ending angles, and the number of segments
--   to approximate it.
-- @param cx Center x coordinate
-- @param cy Center y coordinate
-- @param rx Horizontal radius (ellipse radius along x)
-- @param ry Vertical radius (ellipse radius along y)
-- @param start_angle Starting angle (in radians)
-- @param end_angle Ending angle (in radians)
-- @param segments Number of segments to approximate the arc
-- @param colors Color(s) for each vertex (can be nil, a single color,
--   or a table)
-- @param options Additional options (width, is_closed, joint)
-- @return Arc object
function Arc:new(cx, cy, rx, ry, start_angle, end_angle, segments, colors, options)
  local object = setmetatable({}, self)
  
  object.center = {cx, cy}
  object.rx = rx
  object.ry = ry
  object.start_angle = start_angle
  object.end_angle = end_angle
  object.segments = segments or 36
  object.colors = color_helpers.compile(colors, true)
  object.options = parse_options(options)
  object.transforms = {}
  
  return object
end


--- Compile the Arc object.
-- This method creates a mesh representing the arc using the helper
-- function `mesh_helpers.add_arc()`, then applies any transforms.
-- @param constants Table with constants to use in mesh creation.
-- @return the VSC table (mesh) for the arc.
function Arc:compile(constants)
  local computed_colors = {}
  local total_points = self.segments + 1
  
  if #self.colors == 0 then
    for i = 1, total_points do
      table.insert(computed_colors, 0xffffff00)
    end
  elseif #self.colors == 1 then
    local col = self.colors[1]
    for i = 1, total_points do
      table.insert(computed_colors, col)
    end
  else
    computed_colors = self.colors
  end

  local cx = self.center[1]
  local cy = self.center[2]
  local rx = self.rx
  local ry = self.ry
  local start_angle = self.start_angle
  local end_angle = self.end_angle
  local segments = self.segments

  local mesh = mesh_helpers.add_arc(
    nil,
    cx, cy,
    rx, ry,
    start_angle, end_angle,
    segments,
    computed_colors,
    constants,
    {
      width = self.options.width,
      is_closed = self.options.is_closed,
      joint = self.options.joint
    }
  )
  
  mesh = transform_helpers.apply_transforms(mesh, self.transforms)
  
  return mesh
end


return Arc
