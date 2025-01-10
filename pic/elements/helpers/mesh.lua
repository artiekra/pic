local mesh = {}


--- Add a line to a mesh (represented as VSC)
-- @return new mesh
function mesh.add_line(mesh, point1, point2, color1, color2)

  local mesh_v, mesh_s, mesh_c = table.unpack(mesh)
  local segment_offset = #mesh_v

  table.insert(mesh_v, point1)
  table.insert(mesh_v, point2)

  table.insert(mesh_s, {segment_offset, segment_offset+1})

  table.insert(mesh_c, color1)
  table.insert(mesh_c, color2)

  return {mesh_v, mesh_s, mesh_c}

end


return mesh
