local pic = require("/dynamic/pic/.lua")
local inspect = require("/dynamic/inspect.lua")


meshes = pic.define_meshes(2)

print(inspect(meshes[1]))
