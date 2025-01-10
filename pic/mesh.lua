-- Meta Mesh class
-- TODO: implement mesh-wide offset (potentially?)
-- TODO: implement mesh-wide transforms
Mesh = {elements = {}}
Mesh.__index = Mesh

-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


local Line = relative_import("elements/line.lua")


local function merge_tables(a, b)

  local result = {}

  for _, n in ipairs(a) do
    table.insert(result, n) 
  end

  for _, n in ipairs(b) do
    table.insert(result, n) 
  end

  return result

end


--- Create new Mesh instance.
-- @return Mesh object
-- TODO: add `shapes` param to add shapes upon initialization
function Mesh:new()

  local object = setmetatable({}, self)

  -- self.elements = {}

  return object

end


--- Add a line to the mesh
-- Add a line that goes through two given points
-- @param point1 first point
-- @param point2 second point
-- @param outline line settings
-- @return Line object
function Mesh:new_line(point1, point2, outline)

  local object = Line:new(point1, point2, outline)

  table.insert(self.elements, object)

  return object

end


--- Compile Mesh object into VSC table.
-- Uses the Mesh object to get vertexes, segments
-- and colors data.
-- TODO: potentially reimplement / clean up
function Mesh:compile()

  local segment_offset = 0

  local computed_vertexes = {}
  local computed_segments = {}
  local computed_colors = {}

  for _, element in ipairs(self.elements) do

    local element_vertexes, element_segments, element_colors =
      table.unpack(element:compile())

    computed_vertexes = merge_tables(computed_vertexes, element_vertexes)
    computed_colors = merge_tables(computed_colors, element_colors)
    
    for _, new_segment in ipairs(element_segments) do
      
      local processed_segment = {}
      for _, segment_vertex in ipairs(new_segment) do
        table.insert(processed_segment, segment_vertex + segment_offset)
      end

      table.insert(computed_segments, processed_segment)
    end

    segment_offset = segment_offset + #element_vertexes

  end

  local result = {
    vertexes = computed_vertexes,
    segments = computed_segments,
    colors = computed_colors
  }

  return result
end


return Mesh
