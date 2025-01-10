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
local mesh_helpers = relative_import("helpers/mesh.lua")
local lerp_helpers = relative_import("helpers/lerp.lua")


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

  local computed_colors
  if #colors == 0 then
    computed_colors = {0xffffff00, 0xffffff00}
  elseif #colors == 1 then
    local color = colors[1]
    computed_colors = {color, color}
  else
    computed_colors = colors
  end

  local computed_vertexes = {}
  table.insert(computed_vertexes, point1)

  local intermediate_points = #computed_colors - 2
  for i=1, intermediate_points do
    local a = i / (intermediate_points + 1)
    local x = lerp_helpers.lerp(point1[1], point2[1], a)
    local y = lerp_helpers.lerp(point1[2], point2[2], a)
    local z = lerp_helpers.lerp(point1[3], point2[3], a)
    table.insert(computed_vertexes, {x, y, z})
  end

  table.insert(computed_vertexes, point2)

  return mesh_helpers.add_polygon(nil, computed_vertexes, computed_colors)
end


return Line
