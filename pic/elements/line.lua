-- Meta Line class
Line = {point1 = {}, point2 = {}, outline = 0}
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
-- @param outline line settings
-- @return Line object
function Line:new(point1, point2, outline)

  local object = setmetatable({}, self)

  object.point1 = point1
  object.point2 = point2
  object.outline = outline

  return object
end


--- Compile the Line object.
-- @return the VSC table for the line
function Line:compile()

  local point1 = vertex_helpers.get_vertex(self.point1)
  local point2 = vertex_helpers.get_vertex(self.point2)

  local color = color_helpers.get_color(self.outline)

  local computed_vertexes = {point1, point2}
  local computed_segments = {{0, 1}}
  local computed_colors = {color, color}

  return {computed_vertexes, computed_segments, computed_colors}
end


return Line
