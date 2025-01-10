-- TODO: potentially introduce class privacy
local pic = {}

pic._VERSION = "1.0.0"


-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


pic.Mesh = relative_import("mesh.lua")
local point = relative_import("types/point.lua")


function pic.Point(...)

  return point:new(...)

end


return pic 
