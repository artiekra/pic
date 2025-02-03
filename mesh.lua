local pic = require("/dynamic/pic/init.lua")
local inspect = require("/dynamic/inspect.lua")


local function print_memory_usage(title)

  local value = string.format("%.3f", collectgarbage("count"))
  print("🕑" .. " Memory used " .. value ..
   ' - after test "' .. title .. '"')

end


pic.print_memory_usage()
print_memory_usage("import libs")


-- Test creating mesh objects, both normally and
-- specifying custom constants
local mesh1 = pic.Mesh:new({FAKE_WIDTH_LINE_GAP = 0.65})
local mesh2 = pic.Mesh:new()
local mesh3 = pic.Mesh:new()
local mesh4 = pic.Mesh:new()
local mesh5 = pic.Mesh:new()
local mesh6 = pic.Mesh:new()
local mesh7 = pic.Mesh:new()


print_memory_usage("create Mesh objects")


-- Test basic Line creation
mesh1:new_line({0, 30}, {60, -30}, 0xff0000ff)

-- Test different number of colors being used
mesh1:new_line({80, 30}, {140, -30}, {0xff0000ff, 0x0000ffff})
mesh1:new_line({160, 30}, {220, -30}, {0x0000ffff, 0xff0000ff, 0xffff00ff})

-- Lots of colors and z-axis involved
mesh1:new_line({240, 30}, {300, -30, -50}, {0x0000ffff, 0xff0000ff,
  0xffff00ff, 0x00ff00ff, 0xffffffff, 0xff00ffff})

-- Test for the no_gradient option
local no_gradient = mesh1:new_line({320, 30}, {380, -30}, {0x0000ffff,
  0xff0000ff, 0xffff00ff}, {no_gradient=true})
-- print(inspect(no_gradient:compile()))

-- Test for wider lines (width option)
mesh1:new_line({400, 30}, {460, -30}, 0xff0000ff, {width=5})
mesh1:new_line({480, 30}, {540, -30}, {0xff0000ff, 0x0000ffff, 0xffff00ff},
  {width=2, no_gradient=true})  -- combining options too
mesh1:new_line({560, 30}, {620, -30}, {0xff0000ff, 0x0000ffff, 0xffff00ff},
  {width=5, no_gradient=true})
mesh1:new_line({640, 30}, {700, -30}, {0xff0000ff,
  0x0000ffff, 0xffff00ff}, {width=5})


print_memory_usage("object Line")


-- Test basic Polygons
mesh2:new_polygon({{0, 30}, {30, -30}, {60, 0}}, 0xff0000ff)
mesh2:new_polygon({{80, 30}, {110, -30}, {140, 0}},
  {0x0000ffff, 0xff0000ff, 0xffff00ff})
mesh2:new_polygon({{160, 30}, {190, -30}, {220, 0}},
  0x00ff00ff, {is_closed=false})

-- Polygons with different width and joint style
mesh2:new_polygon({{240, 30}, {270, -30}, {300, 0}},
  {0xff0000ff, 0x00ff00ff, 0x0000ffff}, {width=10, joint="round"})

-- More complex polygonal chain
mesh2:new_polygon({{320, 30}, {340, 0}, {320, -30}, {360, -15, -50},
  {380, 15, -50}}, 0xff0000ff)


-- Test transforms, since separate transform tests are
--  only performed on Line object
mesh2:new_polygon({{400, 10}, {430, -50}, {460, -20}},
  {0xff8000ff, 0xff8000ff, 0xff8000ff}):move({0, 20, 0})


print_memory_usage("object Polygon")


-- Test transforms
mesh3:new_line({0, 30}, {60, -30}, 0xff0000ff)  -- for reference
mesh3:new_line({10, 25, 20}, {70, -35, 20}, 0xff8000ff):move({70, 5, -20})
mesh3:new_line({0, 30}, {60, -30}, 0xffff00ff):move(pic.PointPolar(160, 0))
mesh3:new_line({240, 30}, {300, -30}, 0x80ff00ff):rotate(
  {32/36*math.pi, 32/36*math.pi, 32/36*math.pi}, {270, 0}
)
mesh3:new_line({335, 15}, {365, -15}, 0x00ff00ff):scale({2, 2.5, 0}, {350, 0})
mesh3:new_line({430, 30}, {430, -30}, 0x00ff80ff):shear({-1, 0, 10}, {430, 0})


print_memory_usage("transforms")


-- Test mesh-wide transforms
mesh4:new_line({0, 30}, {60, -30}, 0xff0000ff)
mesh4:move({80, 0})


print_memory_usage("mesh transforms")



-- test different point types
-- mesh5:new_line(pic.Point(0, 30), pic.PointPolar(180, 2.05, 10), 0x00ff00ff)


print_memory_usage("point types")


-- Test different Color types
mesh6:new_line({0, 30}, {60, -30, -25}, {pic.Color(0xff0000ff),
  pic.ColorRGB(0, 0, 255), pic.ColorRGBA(255, 255, 0, 50),
  pic.ColorHSV(180, 1, 0.5)})


print_memory_usage("color types")


-- Line should not be visible (test for implying default value,
-- when no colors specified)
mesh7:new_line({0, 30}, {60, -30})
mesh7:new_line({0, 30}, {30, 0}, 0xffffffff)  -- for reference
mesh7:new_polygon({{80, 30}, {110, -30}, {140, 0}})
mesh7:new_line({80, 30}, {110, 0}, 0xffffffff)  -- for reference


print_memory_usage("extra tests")


-- Test different methods of compiling meshes
local mesh1_compiled = mesh1:compile()
local mesh2_compiled = mesh2:compile()
local mesh3_compiled = mesh3:compile()
local mesh4_compiled = mesh4:compile()
local mesh5_compiled, mesh6_compiled = table.unpack(
  pic.compile_meshes(mesh5, mesh6)
)
local mesh7_compiled = mesh7:compile()

print_memory_usage("mesh compilation")

meshes = {mesh1_compiled, mesh2_compiled, mesh3_compiled,
  mesh4_compiled, mesh5_compiled, mesh6_compiled, mesh7_compiled}

-- print(inspect(meshes))
