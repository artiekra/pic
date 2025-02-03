-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


local Polygon = relative_import("polygon.lua")


-- Meta Chain class
Chain = {}
Chain = setmetatable(Chain, Polygon)
Chain .__index = Chain


--- Create a Chain object.
-- Alias for Polygon object, but the is_closed option is false by default
function Chain:new(points, colors, options)

  local object = Polygon.new(self, points, colors, options)

  if options == nil or options.is_closed == nil then
    object.options.is_closed = false
  end

  return object
end


return Chain
