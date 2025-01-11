local mesh = {}


--- Calculate an angle from two points
-- Calculates an angle between x-axis of the plane
-- and a line, expressed using 2 points
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
function get_point_at_angle_and_distance(x, y, angle, distance)

  local new_x = x + distance * math.cos(angle)
  local new_y = y + distance * math.sin(angle)
  
  return new_x, new_y
end


--- Add a polygon to a mesh (represented as VSC)
-- @return new mesh
function mesh.add_polygon(mesh, points, colors,
  width, is_closed)

  local WIDTH_GAP = 0.75

  local mesh = mesh or {{}, {}, {}}
  local is_closed = is_closed or false

  local mesh_v, mesh_s, mesh_c = table.unpack(mesh)
  local segment_offset = #mesh_v

  local segments = {}

  -- TODO: handle closed polygons correctly
  for i, point in ipairs(points) do

    -- TODO: potentially find better solution
    if i == 1 then goto continue end

    if width % 2 == 0 then
      local lines_on_one_side = width / 2

      for l=1, lines_on_one_side do
        
        local gap = WIDTH_GAP
        if l == 1 then gap = gap / 2 end

        local extension_angle = calculate_line_angle(points[i-1][1],
          points[i-1][2], point[1], point[2]) + math.pi/2
        local extension_angle2 = extension_angle + math.pi
        local x1, y1 = get_point_at_angle_and_distance(
          points[i-1][1], points[i-1][2], extension_angle, gap*l
        )
        local x2, y2 = get_point_at_angle_and_distance(
          point[1], point[2], extension_angle, gap*l
        )
        local x3, y3 = get_point_at_angle_and_distance(
          points[i-1][1], points[i-1][2], extension_angle2, gap*l
        )
        local x4, y4 = get_point_at_angle_and_distance(
          point[1], point[2], extension_angle2, gap*l
        )

        table.insert(mesh_v, {x1, y1, points[i-1][3]})
        table.insert(mesh_v, {x2, y2, point[3]})
        table.insert(mesh_v, {x3, y3, points[i-1][3]})
        table.insert(mesh_v, {x4, y4, point[3]})
        table.insert(mesh_c, colors[i-1])
        table.insert(mesh_c, colors[i])
        table.insert(mesh_c, colors[i-1])
        table.insert(mesh_c, colors[i])
        table.insert(segments,
          {segment_offset, segment_offset+1})
        table.insert(segments,
          {segment_offset+2, segment_offset+3})
        segment_offset = segment_offset + 4
      end

    else
      local lines_on_one_side = (width-1) / 2

      for l=1, lines_on_one_side do
        
        local gap = WIDTH_GAP

        local extension_angle = calculate_line_angle(points[i-1][1],
          points[i-1][2], point[1], point[2]) + math.pi/2
        local extension_angle2 = extension_angle + math.pi
        local x1, y1 = get_point_at_angle_and_distance(
          points[i-1][1], points[i-1][2], extension_angle, gap*l
        )
        local x2, y2 = get_point_at_angle_and_distance(
          point[1], point[2], extension_angle, gap*l
        )
        local x3, y3 = get_point_at_angle_and_distance(
          points[i-1][1], points[i-1][2], extension_angle2, gap*l
        )
        local x4, y4 = get_point_at_angle_and_distance(
          point[1], point[2], extension_angle2, gap*l
        )

        table.insert(mesh_v, {x1, y1, points[i-1][3]})
        table.insert(mesh_v, {x2, y2, point[3]})
        table.insert(mesh_v, {x3, y3, points[i-1][3]})
        table.insert(mesh_v, {x4, y4, point[3]})
        table.insert(mesh_c, colors[i-1])
        table.insert(mesh_c, colors[i])
        table.insert(mesh_c, colors[i-1])
        table.insert(mesh_c, colors[i])
        table.insert(segments,
          {segment_offset, segment_offset+1})
        table.insert(segments,
          {segment_offset+2, segment_offset+3})
        segment_offset = segment_offset + 4
      end

      table.insert(mesh_v, points[i-1])
      table.insert(mesh_v, point)
      table.insert(mesh_c, colors[i-1])
      table.insert(mesh_c, colors[i])
      table.insert(segments,
        {segment_offset, segment_offset+1})
      segment_offset = segment_offset + 2

    end

    ::continue::
  end

  for _, segment in ipairs(segments) do
    table.insert(mesh_s, segment)
  end

  return {mesh_v, mesh_s, mesh_c}
end


return mesh
