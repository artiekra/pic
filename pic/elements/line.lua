-- Meta Line class
Line = {point1 = {}, point2 = {}, colors = {}}
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


--- Create a Line object.
-- A simple line that goes through two given points
-- @param point1 first point
-- @param point2 second point
-- @param colors line colors
-- @return Line object
function Line:new(point1, point2, colors)

  local object = setmetatable({}, self)

  object.point1 = point1
  object.point2 = point2
  object.colors = colors

  return object
end


--- Compile the Line object.
-- @return the VSC table for the line
function Line:compile()

  local point1 = vertex_helpers.get_vertex(self.point1)
  local point2 = vertex_helpers.get_vertex(self.point2)

  local colors = color_helpers.get_color(self.colors)

  local computed_vertexes = {point1, point2}
  local computed_segments = {{0, 1}}

  local computed_colors
  if #colors == 0 then
    computed_colors = {0xffffff00, 0xffffff00}
  elseif #colors == 1 then
    local color = colors[1]
    computed_colors = {color, color}
  elseif #colors == 2 then
    computed_colors = colors
  else
    error("Line must have 2 or less colors specified")
  end

  return {computed_vertexes, computed_segments, computed_colors}
end


return Line
