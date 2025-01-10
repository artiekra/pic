local pic = require("/dynamic/pic/.lua")
local inspect = require("/dynamic/inspect.lua")


local mesh1 = pic.Mesh:new()

-- Test basic Line creation
mesh1:new_line({0, 0}, {50, 50}, 0xff0000ff)

-- Test different Point types
mesh1:new_line(pic.Point(-50, 0), pic.PointPolar(100, 1, 10), 0x00ff00ff)

-- Test different number of colors being used
mesh1:new_line({10, 0}, {60, 50})
mesh1:new_line({20, 0}, {70, 50}, {0xff0000ff, 0x0000ffff})
mesh1:new_line({30, 0}, {80, 50}, {0x0000ffff, 0xff0000ff, 0xffff00ff})

-- Random line with lots of colors (and z-axis involved)
mesh1:new_line({-100, -20}, {100, 0}, {0x0000ffff, 0xff0000ff,
  0xffff00ff, 0x00ff00ff, 0xffffffff, 0xff00ffff})


print(inspect(mesh1))
local mesh1_compiled = mesh1:compile()

meshes = {mesh1_compiled}

print(inspect(meshes))
