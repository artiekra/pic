-- Meta Mesh class
-- TODO: implement mesh-wide offset (potentially?)
-- TODO: implement mesh-wide transforms
Mesh = {elements = {}, constants = {}}
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


--- Merge two tables into one.
-- Only works for array-like tables
-- @param a first table
-- @param b second table
-- @return result of merging two table
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

  self.elements = {}
  self.constants = {
    GRADIENT_PREVENTION_VERTEX_SPACING = 0.01
  }

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
      table.unpack(element:compile(self.constants))

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


-- Add all the neccesary methods for a certain element
-- to the Mesh class
local function add_element_methods(name, class)

  Mesh["get_" .. name] = function(self, ...)
    return class:new(...)
  end

  Mesh["new_" .. name] = function(self, ...)
    local object = class:new(...)
    table.insert(self.elements, object)
    return object
  end
  
end


add_element_methods("line", Line)


return Mesh
