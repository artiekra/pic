local color_helpers = {}


--- Compile color.
-- Compiles a given color (a table, class, etc) into
-- a mesh color (table or a hex value)
-- @param color given object
-- @param multiple_color_choice handle multiple colors (and
--   return a table), by default false
-- @return colors as a table
function color_helpers.compile(color, multiple_color_choice)

  local multiple_color_choice = multiple_color_choice or false

  -- if falsy, return transparent white
  if not color then
    if multiple_color_choice then
      return {0xffffff00}
    end
    return 0xffffff00
  end

  -- if just a number, return it (but as a table with a single element,
  --   if multiple_color_choice)
  if type(color) == "number" then
    if multiple_color_choice then
      return {color}
    end
    return color
  end

  assert(type(color) == "table",
    "falsy value, number, table, or a supported object "..
    "expected to represent color")

  -- if a supported class, use compile function (wrap in a table if neccesary)
  if type(color.compile) == "function" then
    local result = color:compile()
    return color_helpers.compile(result, multiple_color_choice)
  end

  local colors = {}

  for _, raw_color in ipairs(color) do
    local new_colors = color_helpers.compile(raw_color, true)
    for _, new_color in ipairs(new_colors) do
      table.insert(colors, new_color)
    end
  end

  if not multiple_color_choice then
    assert(#colors <= 1, "no more then 1 color expected")
  end

  return colors
end


return color_helpers
