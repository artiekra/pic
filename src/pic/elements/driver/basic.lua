local basic = {}


function basic.add_line(mesh, points, colors)
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


return basic
