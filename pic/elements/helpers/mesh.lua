local mesh = {}


--- Add a polygon to a mesh (represented as VSC)
-- @return new mesh
function mesh.add_polygon(mesh, points, colors, is_closed)

  local mesh = mesh or {{}, {}, {}}
  local is_closed = is_closed or false

  local mesh_v, mesh_s, mesh_c = table.unpack(mesh)
  local segment_offset = #mesh_v

  for _, point in ipairs(points) do
    table.insert(mesh_v, point)
  end

  local segments = {}
  for i=0, #points-1 do
    table.insert(segments, segment_offset+i)
  end
  if is_closed then
    table.insert(segments, segment_offset)
  end
  table.insert(mesh_s, segments)

  for _, color in ipairs(colors) do
    table.insert(mesh_c, color)
  end

  return {mesh_v, mesh_s, mesh_c}

end


return mesh
