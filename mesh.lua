local pic = require("/dynamic/pic/.lua")
local inspect = require("/dynamic/inspect.lua")

local TEST_PERFORMANCE = false


local function print_memory_usage(title)
  print("🕑" .. " Memory used " .. collectgarbage("count") ..
   " - " .. title)
end


print_memory_usage("after import")


local mesh1 = pic.Mesh:new()


print_memory_usage("after creating a mesh")


-- Test basic Line creation
mesh1:new_line({-200, 200}, {-160, 160}, 0xff0000ff)

-- Test different number of colors being used
mesh1:new_line({-160, 200}, {-120, 160}, {0xff0000ff, 0x0000ffff})
mesh1:new_line({-140, 200}, {-100, 160}, {0x0000ffff, 0xff0000ff, 0xffff00ff})

-- Line should not be visible
mesh1:new_line({-180, 200}, {-140, 160})
mesh1:new_line({-180, 200}, {-160, 180}, 0xffffffff)  -- for reference

-- Test different Point types
mesh1:new_line(pic.Point(-110, 200), pic.PointPolar(180, 2.05, 10), 0x00ff00ff)

-- Random line with lots of colors (and z-axis involved)
mesh1:new_line({-80, 200}, {-20, 200, -50}, {0x0000ffff, 0xff0000ff,
  0xffff00ff, 0x00ff00ff, 0xffffffff, 0xff00ffff})

-- Test different Color types
mesh1:new_line({-80, 190}, {-20, 190, -25}, {pic.Color(0xff0000ff),
  pic.ColorRGB(0, 0, 255), pic.ColorRGBA(255, 255, 0, 50),
  pic.ColorHSV(180, 1, 0.5)})


print_memory_usage("after creating basic lines")


-- Test transforms
mesh1:new_line({-200, 120}, {-160, 80}, 0xff0000ff)  -- for reference
local orange_line = mesh1:new_line({-200, 120}, {-160, 80}, 0xff5000ff)
orange_line:move(20, 0, 0)
orange_line:rotate(35/36*math.pi)
orange_line:scale(5)
orange_line:shear(1.5, 2)
-- print(inspect(line:compile()))



print_memory_usage("after creating a line with transforms")


-- Performance stuff
if TEST_PERFORMANCE then
  for i=0, 1000 do
    mesh1:new_line({-200+i/2, 40}, {-180+i/2, 0}, 0x00ffff20)
  end
  print_memory_usage("after adding 1000 simple lines")
end


-- print(inspect(mesh1))
local mesh1_compiled = mesh1:compile()

meshes = {mesh1_compiled}

-- print(inspect(meshes))
