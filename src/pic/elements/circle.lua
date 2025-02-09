-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)
  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)
  return lib
end


local driver = relative_import("driver/init.lua")
local color_helpers = relative_import("helpers/color.lua")
local transform_helpers = relative_import("helpers/transform.lua")
local ElementBase = relative_import("base.lua")


-- Meta Circle class
Circle = {}
Circle = setmetatable(Circle, ElementBase)
Circle.__index = Circle


--- Create a Circle object.
-- Represents a perfect circle with a given center and radius.
-- @param cx Center x coordinate
-- @param cy Center y coordinate
-- @param r Radius of the circle
-- @param segments Number of segments to approximate the circle
-- @param colors Color(s) for each vertex
-- @param options Additional options (width, joint)
-- @return Circle object
function Circle:new(cx, cy, r, segments, colors, options)
  local object = setmetatable({}, self)
  object.center = {cx, cy}
  object.radius = r
  object.segments = segments or 36
  object.colors = color_helpers.compile(colors, true)
  object.options = { width = options and options.width or 1, joint = options and options.joint or "none" }
  object.transforms = {}
  return object
end


--- Compile the Circle object.
-- This method creates a mesh representing the circle using `driver.add_circle()`.
-- @param constants Table with constants to use in mesh creation.
-- @return the VSC table (mesh) for the circle.
function Circle:compile(constants)
  local computed_colors = {}
  for i = 1, self.segments do
    table.insert(computed_colors, #self.colors > 0 and self.colors[1] or 0xffffff00)
  end

  local mesh = driver.add_circle(
    nil,
    self.center[1], self.center[2],
    self.radius,
    self.segments,
    computed_colors,
    constants,
    { width = self.options.width, joint = self.options.joint }
  )
  
  mesh = transform_helpers.apply_transforms(mesh, self.transforms)
  
  return mesh
end


return Circle
