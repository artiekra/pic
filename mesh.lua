local pic = require("/dynamic/pic/.lua")
local inspect = require("/dynamic/inspect.lua")

local TEST_PERFORMANCE = false


local function print_memory_usage(title)
  print("🕑" .. " Memory used " .. collectgarbage("count") ..
   " - " .. title)
end


print_memory_usage("after import")


local mesh1 = pic.Mesh:new({FAKE_WIDTH_LINE_GAP = 0.65})
local mesh2 = pic.Mesh:new()
local mesh3 = pic.Mesh:new()


mesh1:new_line({10, 200}, {50, 160}, {0xff0000ff,0x0000ffff, 0xffff00ff},
  {width=5, no_gradient=true})


print_memory_usage("after creating a mesh")


-- Test basic Line creation
mesh1:new_line({-200, 200}, {-160, 160}, {0xff0000ff})

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

-- Test for the no_gradient option
local no_gradient = mesh1:new_line({-80, 180}, {-20, 180}, {0x0000ffff,
  0xff0000ff, 0xffff00ff}, {no_gradient=true})
-- print(inspect(no_gradient:compile()))

-- Test for wider lines (width option)
mesh1:new_line({-10, 200}, {30, 160}, {0xff0000ff,0x0000ffff, 0xffff00ff},
  {width=2, no_gradient=true})  -- combining options too
mesh1:new_line({10, 200}, {50, 160}, {0xff0000ff,0x0000ffff, 0xffff00ff},
  {width=5, no_gradient=true})
mesh1:new_line({30, 200}, {70, 160},
  {0xff0000ff,0x0000ffff, 0xffff00ff}, {width=5})


print_memory_usage("after creating basic lines")


-- Test transforms
mesh3:new_line({-200, 120}, {-160, 80}, 0xff0000ff)  -- for reference
local orange_line = mesh3:new_line({-200, 120}, {-160, 80}, 0xff5000ff)
orange_line:move(20, 5, -20)
orange_line:rotate({32/36*math.pi, 32/36*math.pi,
  32/36*math.pi}, {-160, 105, -20})
orange_line:scale(5)
orange_line:shear(1.5, 2)
-- print(inspect(line:compile()))


print_memory_usage("after creating a line with transforms")


-- Test basic polygons
mesh2:new_polygon({{-200, 40}, {-160, 0}, {-180, 35}},
  {0xff0000ff, 0xff0000ff, 0xff0000ff})
mesh2:new_polygon({{-160, 40}, {-120, 0}, {-140, 35}},
  {0x0000ffff, 0xff0000ff, 0xffff00ff})
mesh2:new_polygon({{-120, 40}, {-80, 0}, {-100, 35}},
  0x00ff00ff, {is_closed=false})
mesh2:new_polygon({{-115, 40}, {-75, 0}, {-95, 35}})  -- should not be visible

-- Polygons with different width and joint style
mesh2:new_polygon({{-75, 40}, {-25, 0}, {-45, 35}},
  {0xff0000ff, 0x00ff00ff, 0x0000ffff}, {width=10, joint="round"})


print_memory_usage("after creating basic polygons")


-- Performance stuff
if TEST_PERFORMANCE then
  for i=0, 1000 do
    mesh1:new_line({-200+i/2, 40}, {-180+i/2, 0}, 0x00ffff20)
  end
  print_memory_usage("after adding 1000 simple lines")
end


-- print(inspect(mesh1))
local mesh1_compiled = mesh1:compile()
local mesh2_compiled = mesh2:compile()
local mesh3_compiled = mesh3:compile()

print_memory_usage("after mesh compilation")

meshes = {mesh1_compiled, mesh2_compiled, mesh3_compiled}

-- print(inspect(meshes))
