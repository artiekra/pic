local pic = require("/dynamic/pic/.lua")
local inspect = require("/dynamic/inspect.lua")


local mesh1 = pic.Mesh:new()

mesh1:new_line({0, 0}, {50, 50}, 0xff0000ff)
mesh1:new_line(pic.Point(-50, 0), pic.PointPolar(100, 1, 10), 0x00ff00ff)


local mesh1_compiled = mesh1:compile()

meshes = {mesh1_compiled}

print(inspect(mesh1))
print(inspect(meshes))
