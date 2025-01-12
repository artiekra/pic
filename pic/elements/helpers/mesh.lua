local mesh = {}

local inspect = require("/dynamic/inspect.lua")


--- Calculate an angle from two points
-- Calculates an angle between x-axis of the plane
-- and a line, expressed using 2 points
-- TODO: reimplement with atan2 if new ppl-utils support it
local function calculate_line_angle(x1, y1, x2, y2)

  local dx = x2 - x1
  local dy = y2 - y1
  
  local angle = math.atan(dy/dx)
  
  if dx < 0 then
    angle = angle + math.pi
  elseif dx == 0 then
    if dy > 0 then
      angle = math.pi / 2
    elseif dy < 0 then
      angle = 3 * math.pi / 2
    else
      angle = 0  -- points are the same
    end
  elseif dy < 0 and dx > 0 then
    angle = angle + 2 * math.pi
  end
  
  return angle
end


--- Get point to create a line with given angle and distance
-- The point created will be on the given distance from the given
-- point, and the line created by two points will create a given
-- angle with x-axis. Similar to converting polar into cartesian,
-- but with a custom origin
local function get_point_at_angle_and_distance(x, y, angle, distance)

  local new_x = x + distance * math.cos(angle)
  local new_y = y + distance * math.sin(angle)
  
  return new_x, new_y
end


local function add_line(mesh, points, colors)

  local mesh_v, mesh_s, mesh_c = table.unpack(mesh)
  local segment_offset = #mesh_v

  -- first point (vertex and its color)
  table.insert(mesh_v, points[1])
  table.insert(mesh_c, colors[1])

  -- second point (vertex and its color)
  table.insert(mesh_v, points[2])
  table.insert(mesh_c, colors[2])

  -- segment between two points
  table.insert(mesh_s, {segment_offset, segment_offset+1})

  return {mesh_v, mesh_s, mesh_c}
end


--- Increase given line's width by 2
-- Creates additional lines around the given one (according to gap)
-- @param mesh mesh to add new lines to (as an array-like table)
-- @param points 2 points, defining the original (center) line
-- @param color 2 colors, for 2 points
-- @param gap gap between original lines and new ones
-- @return modified mesh (as vertexes, segments and colors in
--   array-like table)
local function increase_line_width(mesh, points, colors, gap)

  local point1, point2 = table.unpack(points)
  local color1, color2 = table.unpack(colors)

  -- Helper function to generate an extension only to one side of the line
  local function increase_line_width_one_side(mesh, points,
    colors, gap, extension_angle)

    local point1, point2 = table.unpack(points)
    local color1, color2 = table.unpack(colors)

    local x1, y1 = get_point_at_angle_and_distance(
      point1[1], point1[2], extension_angle, gap
    )
    local x2, y2 = get_point_at_angle_and_distance(
      point2[1], point2[2], extension_angle, gap
    )

    local new_line = {{x1, y1, point1[3]}, {x2, y2, point2[3]}}

    mesh = add_line(mesh, new_line, {color1, color2})

    return mesh
  end

  -- extensions are built perpendicular to line angle
  local extension_angle = calculate_line_angle(point1[1],
    point1[2], point2[1], point2[2]) + math.pi/2
  mesh = increase_line_width_one_side(mesh, points,
    colors, gap, extension_angle)

  -- add 180deg to generate an extension to another side
  local extension_angle2 = extension_angle + math.pi
  mesh = increase_line_width_one_side(mesh, points,
    colors, gap, extension_angle2)

  return mesh
end


--- Add a polygon to a mesh (represented as VSC)
-- @param mesh existing mesh or nil to create a new one
-- @colors one color for each point
-- @constants table with constants to use
-- @options is_closed, width
-- @return new mesh
--TODO: create less vertexes (no duplicates)
function mesh.add_polygon(mesh, points, colors, constants, options)

  local options = options or {}

  local mesh = mesh or {{}, {}, {}}
  local is_closed = options.is_closed or false
  local width = options.width or 1 

  if options.is_closed then
    table.insert(points, points[1])
    table.insert(colors, colors[1])
  end

  for i, point in ipairs(points) do

    -- skip the first point, start adding a line for every next point
    if i == 1 then goto continue end

    local line_points = {points[i-1], point}
    local line_colors = {colors[i-1], colors[i]}

    if width % 2 == 0 then
      local lines_on_one_side = width / 2
      local gap = constants.FAKE_WIDTH_LINE_GAP
      for l=1, lines_on_one_side do
        mesh = increase_line_width(mesh, line_points, line_colors, gap*(l-0.5))
      end

    else
      local lines_on_one_side = (width-1) / 2

      local gap = constants.FAKE_WIDTH_LINE_GAP
      for l=1, lines_on_one_side do
        mesh = increase_line_width(mesh, line_points, line_colors, gap*l)
      end

      -- add a center line (since the width is odd)
      mesh = add_line(mesh, line_points, line_colors)

    end

    ::continue::
  end

  return mesh
end


return mesh
