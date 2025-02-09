-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)
  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)
  return lib
end


local Arc = relative_import("arc.lua")


-- Meta Ellipse class
Ellipse = {}
Ellipse = setmetatable(Ellipse, Arc)
Ellipse.__index = Ellipse


--- Create an Ellipse object.
-- Alias for Arc, but without setting start and end angles explicitly,
-- forming a full ellipse.
-- @param cx Center x coordinate
-- @param cy Center y coordinate
-- @param rx Horizontal radius
-- @param ry Vertical radius
-- @param segments Number of segments to approximate the ellipse
-- @param colors Color(s) for each vertex
-- @param options Additional options (width, joint)
-- @return Ellipse object
function Ellipse:new(cx, cy, rx, ry, segments, colors, options)
  local full_circle = 2 * math.pi

  if options ~= nil and options.is_closed ~= nil then
    error("unexpected is_closed option when creating an Ellipse")
  end
  
  local object = Arc.new(self, cx, cy, rx, ry, 0, full_circle, segments, colors, options)
  
  object.options.is_closed = nil
  
  return object
end


return Ellipse
