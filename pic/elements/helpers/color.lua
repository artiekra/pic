local color = {}


--- Get color from an object.
-- Compiles a given object (a table, class, etc) into a mesh color
-- @param color given object
-- @return colors as a table
function color.get_color(o, is_table_allowed)

  local is_table_allowed = is_table_allowed or true

  -- if falsy, return transparent white
  if not o then
    return {0xffffff00}
  end

  -- if just a number, return it (but as a table with a single element)
  if type(o) == "number" then
    return {o}
  end

  -- if a supported class, use compile function
  if o.compile then
    return o:compile()
  end

  assert(type(o) == "table", "number, table, or color object expected")

  if not is_table_allowed then
    error("must specify one color; number or color object expected")
  end

  local colors = {}

  for _, raw_color in ipairs(o) do
    table.insert(colors, color.get_color(raw_color)[1])
  end

  return colors
end


return color
