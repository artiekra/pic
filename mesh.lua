local pic = require("/dynamic/pic/.lua")
local inspect = require("/dynamic/inspect.lua")


local mesh = pic.Mesh:new()

mesh:new_line({0, 0}, {50, 50}, 0xff0000ff)
mesh:new_line({0, 0}, {-50, 50}, 0x00ff00ff)
mesh:new_line({0, -10}, {0, 50}, 0x0000ffff)

print(inspect(mesh))

meshes = {mesh:compile()}

print(inspect(meshes))
