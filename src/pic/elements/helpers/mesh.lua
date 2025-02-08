local mesh_helpers = {}


--- Calculate an angle from two points
-- Calculates an angle between the x-axis of the plane and a line defined by
-- two points
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
-- The created point will be at the given distance from the given point,
-- along a line that makes the given angle with the x-axis.
-- Similar to converting polar to Cartesian, but with a custom origin.
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

  -- segment between the two points
  table.insert(mesh_s, {segment_offset, segment_offset + 1})

  return {mesh_v, mesh_s, mesh_c}
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

    mesh = add_line(mesh, new_line, {color1, color2})

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


--- Add a Bezier curve to a mesh
-- @param mesh Existing mesh or nil to create a new one
-- @param control_points Table of control points (each control point is a table
--   {x, y, [z]})
-- @param segments Number of segments to approximate the curve
-- @param colors Color(s) for the curve points (a single color or a table
--   of colors)
-- @param constants Table with constants to use (passed to add_polygon)
-- @param options Options table (e.g., is_closed, width, etc.)
-- @return Mesh with the added Bezier curve
function mesh_helpers.add_bezier_curve(
  mesh, control_points, segments, colors, constants, options
)
  local points = {}
  local color_table = {}
  segments = segments or 36  -- default number of segments if not provided
  local dt = 1 / segments

  --- Evaluate a Bezier curve at parameter t using de Casteljau's algorithm
  local function evaluate_bezier(control_points, t)
    -- Create a working copy of the control points
    local pts = {}
    for i, p in ipairs(control_points) do
      pts[i] = {p[1], p[2], p[3] or 0}
    end

    local n = #pts
    while n > 1 do
      for i = 1, n - 1 do
        local x = (1 - t) * pts[i][1] + t * pts[i + 1][1]
        local y = (1 - t) * pts[i][2] + t * pts[i + 1][2]
        local z = (1 - t) * pts[i][3] + t * pts[i + 1][3]
        pts[i] = {x, y, z}
      end
      n = n - 1
    end

    return pts[1]
  end

  for i = 0, segments do
    local t = i * dt
    local pt = evaluate_bezier(control_points, t)
    table.insert(points, {pt[1], pt[2], pt[3]})

    if type(colors) == "table" and #colors > 1 then
      table.insert(color_table, colors[(i % #colors) + 1])
    else
      table.insert(color_table, colors or {1, 1, 1})  -- default white
    end
  end

  options = options or {is_closed = false}
  return mesh_helpers.add_polygon(
    mesh, points, color_table, constants, options
  )
end


--- Add a polygon to a mesh (represented as VSC)
-- @param mesh Existing mesh or nil to create a new one
-- @param points Table of points
-- @param colors One color for each point
-- @param constants Table with constants to use
-- @param options Options (e.g., is_closed, width)
-- @return New mesh
-- TODO: create fewer vertices (avoid duplicates)
function mesh_helpers.add_polygon(
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
      mesh = add_line(mesh, line_points, line_colors)
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

        mesh = mesh_helpers.add_polygon(
          mesh, joint_points, joint_colors, constants, {is_closed = true}
        )
      end
    end

    ::continue::
  end

  return mesh
end


--- Add an arc of an ellipse to a mesh
-- This function creates an arc by sampling points along an ellipse.
-- @param mesh Existing mesh or nil to create a new one
-- @param cx Center x coordinate of the ellipse
-- @param cy Center y coordinate of the ellipse
-- @param rx Horizontal radius of the ellipse
-- @param ry Vertical radius of the ellipse
-- @param start_angle Starting angle (in radians)
-- @param end_angle Ending angle (in radians)
-- @param segments Number of segments to approximate the arc
-- @param colors Color(s) for the arc points (a single color
--   or a table of colors)
-- @param constants Table with constants to use (passed to add_polygon)
-- @param options Options table (e.g., is_closed, width, etc.)
-- @return Mesh with the added arc
function mesh_helpers.add_arc(
  mesh, cx, cy, rx, ry, start_angle, end_angle, segments, colors,
  constants, options
)
  local points = {}
  local color_table = {}
  segments = segments or 36
  local angle_step = (end_angle - start_angle) / segments

  for i = 0, segments do
    local angle = start_angle + i * angle_step
    local x = cx + rx * math.cos(angle)
    local y = cy + ry * math.sin(angle)
    -- Default z coordinate is set to 0
    table.insert(points, {x, y, 0})

    if type(colors) == "table" and #colors > 1 then
      table.insert(color_table, colors[(i % #colors) + 1])
    else
      table.insert(color_table, colors or {1, 1, 1})  -- default white
    end
  end

  options = options or {is_closed = false}
  return mesh_helpers.add_polygon(
    mesh, points, color_table, constants, options
  )
end


return mesh_helpers
