local driver = {}


-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


local polygon = relative_import("polygon.lua")
local arc = relative_import("arc.lua")

driver.add_polygon = polygon.add_polygon
driver.add_arc = arc.add_arc


return driver
