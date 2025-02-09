local polygon = {}


-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


local basic = relative_import("basic.lua")


--- Calculate an angle from two points
-- Calculates an angle between the x-axis of the plane and a line defined by
-- two points
-- TODO: reimplement with atan2 (atan with 2 arguments passed for lua5.3,
--  refer to lua code)
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
-- The created point will be at the given distance from the given point,
-- along a line that makes the given angle with the x-axis.
-- Similar to converting polar to Cartesian, but with a custom origin.
local function get_point_at_angle_and_distance(x, y, angle, distance)
  local new_x = x + distance * math.cos(angle)
  local new_y = y + distance * math.sin(angle)

  return new_x, new_y
end


--- Increase given line's width by 2
-- Creates additional lines around the given one (according to gap)
-- @param mesh mesh to add new lines to (as an array-like table)
-- @param points 2 points, defining the original (center) line
-- @param colors 2 colors, for the two points
-- @param gap gap between the original line and the new ones
-- @return modified mesh (as vertexes, segments, and colors in
--   an array-like table)
local function increase_line_width(mesh, points, colors, gap)
  local point1, point2 = table.unpack(points)
  local color1, color2 = table.unpack(colors)

  -- Helper function to generate an extension on one side of the line
  local function increase_line_width_one_side(mesh, points, colors, gap,
                                                extension_angle)
    local point1, point2 = table.unpack(points)
    local color1, color2 = table.unpack(colors)

    local x1, y1 = get_point_at_angle_and_distance(
      point1[1], point1[2], extension_angle, gap
    )
    local x2, y2 = get_point_at_angle_and_distance(
      point2[1], point2[2], extension_angle, gap
    )

    local new_line = {
      {x1, y1, point1[3]},
      {x2, y2, point2[3]}
    }

    mesh = basic.add_line(mesh, new_line, {color1, color2})

    return mesh
  end

  -- Build extensions perpendicular to the line angle
  local extension_angle = calculate_line_angle(
    point1[1], point1[2], point2[1], point2[2]
  ) + math.pi / 2
  mesh = increase_line_width_one_side(
    mesh, points, colors, gap, extension_angle
  )

  -- Add an extension to the opposite side (180deg apart)
  local extension_angle2 = extension_angle + math.pi
  mesh = increase_line_width_one_side(
    mesh, points, colors, gap, extension_angle2
  )

  return mesh
end


--- Add a polygon to a mesh (represented as VSC)
-- @param mesh Existing mesh or nil to create a new one
-- @param points Table of points
-- @param colors One color for each point
-- @param constants Table with constants to use
-- @param options Options (e.g., is_closed, width)
-- @return New mesh
-- TODO: create fewer vertices (avoid duplicates)
function polygon.add_polygon(
  mesh, points, colors, constants, options
)
  local options = options or {}
  local mesh = mesh or {{}, {}, {}}
  local is_closed = options.is_closed or false
  local width = options.width or 1
  local joint = options.joint or "none"

  if is_closed then
    table.insert(points, points[1])
    table.insert(colors, colors[1])
  end

  for i, point in ipairs(points) do
    -- Skip the first point; start adding a line from the second point
    if i == 1 then
      goto continue
    end

    local line_points = {points[i - 1], point}
    local line_colors = {colors[i - 1], colors[i]}

    if width % 2 == 0 then
      local lines_on_one_side = width / 2
      local gap = constants.FAKE_WIDTH_LINE_GAP
      for l = 1, lines_on_one_side do
        mesh = increase_line_width(
          mesh, line_points, line_colors, gap * (l - 0.5)
        )
      end
    else
      local lines_on_one_side = (width - 1) / 2
      local gap = constants.FAKE_WIDTH_LINE_GAP
      for l = 1, lines_on_one_side do
        mesh = increase_line_width(
          mesh, line_points, line_colors, gap * l
        )
      end
      -- Add a center line (since the width is odd)
      mesh = basic.add_line(mesh, line_points, line_colors)
    end

    -- Create joints only on wide enough lines
    if width >= 10 then
      local joint_position = points[i - 1]
      local joint_color = colors[i - 1]
      local real_line_width = (width + 1) * constants.FAKE_WIDTH_LINE_GAP

      if joint == "round" then
        local joint_radius = real_line_width / 2
        local joint_points = {}
        for a = 0, 2 * math.pi, 2 * math.pi / 36 do
          for r = 0, joint_radius, 0.5 do
            local x = joint_position[1] + r * math.cos(a)
            local y = joint_position[2] + r * math.sin(a)
            table.insert(joint_points, {x, y, joint_position[3]})
          end
        end

        local joint_colors = {}
        for n = 1, #joint_points do
          table.insert(joint_colors, joint_color)
        end

        mesh = polygon.add_polygon(
          mesh, joint_points, joint_colors, constants, {is_closed = true}
        )
      end
    end

    ::continue::
  end

  return mesh
end


return polygon
