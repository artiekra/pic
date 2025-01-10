-- Meta Mesh class
Mesh = {}

-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


--- Create new Mesh instance.
-- @return Mesh object
function Mesh:new()

  object = {}
  setmetatable(object, self)
  self.__index = self

  return object

end


return Mesh
