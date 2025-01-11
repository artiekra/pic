local mesh = {}


--- Calculate an angle from two points
-- Calculates an angle between x-axis of the plane
-- and a line, expressed using 2 points
local function calculate_line_angle(x1, y1, x2, y2)

  local dx = x2 - x1
  local dy = y2 - y1
  
  local angle = math.atan2(dy, dx)
  
  if angle < 0 then
    angle = angle + 2 * math.pi
  end
  
  return angle
end


--- Add a polygon to a mesh (represented as VSC)
-- @return new mesh
function mesh.add_polygon(mesh, points, colors,
  width, is_closed)

  local mesh = mesh or {{}, {}, {}}
  local is_closed = is_closed or false

  local mesh_v, mesh_s, mesh_c = table.unpack(mesh)
  local segment_offset = #mesh_v

  local segments = {}

  for i, point in ipairs(points) do

    -- correction for segments because they use 0-based indexing
    table.insert(mesh_v, point)
    table.insert(mesh_c, colors[i])
    table.insert(segments, segment_offset+i-1)

  end

  if is_closed then
    table.insert(segments, segment_offset)
  end

  table.insert(mesh_s, segments)

  return {mesh_v, mesh_s, mesh_c}
end


return mesh
