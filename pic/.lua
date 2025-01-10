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


--- Define `meshes` table.
-- Defines and returns `meshes` table, containing specified
-- amount of pic.Mesh objects.
-- @param n amount of meshes to define
-- @return `meshes` table
-- @see pic.Mesh
-- TODO: remove this?
function pic.define_meshes(n)

  local meshes = {}

  for i=1, n do
    local new_mesh = pic.Mesh:new()
    table.insert(meshes, new_mesh)
  end

  return meshes
end


return pic 
