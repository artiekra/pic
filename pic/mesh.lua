-- Meta Mesh class
-- TODO: implement mesh-wide offset (potentially?)
-- TODO: implement mesh-wide transforms
Mesh = {elements = {}, constants = {}, transforms = {}}
Mesh.__index = Mesh

-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


local constant_defaults = relative_import("defaults.lua")
local class_helpers = relative_import("elements/helpers/class.lua")

local transform_move = relative_import("elements/transforms/move.lua")
local transform_rotate = relative_import("elements/transforms/rotate.lua")
local transform_scale = relative_import("elements/transforms/scale.lua")
local transform_shear = relative_import("elements/transforms/shear.lua")

local Line = relative_import("elements/line.lua")
local Polygon = relative_import("elements/polygon.lua")


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


--- Parse Mesh object constants
-- Parse and verify the constants passed to Mesh object
-- @param constants raw constant input
-- @returned parsed constant table
local function parse_mesh_constants(constants)

  local constants = constants or {}

  assert(type(constants) == "table",
    "nil or table expected to represent Mesh constants")

  -- TODO: add support for non-number constants
  local function process_constant(results_table, name)
    local value = constants[name] or constant_defaults[name]
    assert(type(value) == "number", "number expected to represent a constant")
    results_table[name] = value
  end

  results = {}

  for k, v in pairs(constant_defaults) do
    process_constant(results, k)
  end

  return results
end



--- Create new Mesh instance.
-- @return Mesh object
-- TODO: add `shapes` param to add shapes upon initialization
function Mesh:new(constants)

  local object = setmetatable({}, self)

  object.elements = {}
  object.constants = parse_mesh_constants(constants)
  object.transforms = {}

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

  local mesh = {computed_vertexes, computed_segments, computed_colors}
  
  for _, transform in ipairs(self.transforms) do
    local transform_type = transform[1]
    local transform_options = transform[2]

    if transform_type == "move" then
      mesh = transform_move.apply(mesh, transform_options)
    elseif transform_type == "rotate" then
      mesh = transform_rotate.apply(mesh, transform_options)
    elseif transform_type == "scale" then
      mesh = transform_scale.apply(mesh, transform_options)
    elseif transform_type == "shear" then
      mesh = transform_shear.apply(mesh, transform_options)
    end
  end

  local result = {
    vertexes = mesh[1],
    segments = mesh[2],
    colors = mesh[3] 
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
add_element_methods("polygon", Polygon)

class_helpers.add_transform_methods(Mesh)


return Mesh
