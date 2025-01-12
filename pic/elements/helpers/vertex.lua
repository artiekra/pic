local vertex_helpers = {}


--- Compile vertex.
-- Compiles vertex (a table, class, etc) into a mesh vertex (table)
-- @param vertex given vertex to compile
-- @param multiple_vertex_support handle multiple vertexes (an
--   return a table), by default false (required table of vertexes)
-- @return resulting vertex as a table
function vertex_helpers.compile(vertex, multiple_vertex_choice)

  local multiple_vertex_choice = multiple_vertex_choice or false

  if multiple_vertex_choice then
    assert(type(vertex) == "table",
      "table or a supported object expected to represent vertexes")
    local result = {}
    for _, individual_vertex in ipairs(vertex) do
      table.insert(result, vertex_helpers.compile(individual_vertex))
    end
    return result
  end

  assert(type(vertex) == "table",
    "table or a supported object expected to represent a vertex")

  -- if a supported class, use compile function
  if type(vertex.compile) == "function" then
    return vertex:compile()
  end

  -- otherwise get the coordinates
  local x = vertex[1]
  local y = vertex[2]
  local z = vertex[3] or 0

  assert(type(x) == "number", "number expected to represent vertex's x value")
  assert(type(y) == "number", "number expected to represent vertex's y value")
  assert(type(z) == "number", "number expected to represent vertex's z value")

  return {x, y, z}
end


return vertex_helpers
