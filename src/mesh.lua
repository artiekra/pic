local pic = require("/dynamic/pic/init.lua")
local inspect = require("/dynamic/inspect.lua")


pic.print_memory_usage("After importing libs")


-- Test creating mesh objects, both normally and
--  specifying custom constants; test pic.define_meshes()
local mesh = pic.define_meshes(9, {FAKE_WIDTH_LINE_GAP = 0.7})


pic.print_memory_usage("Creating Mesh objects")


-- Test basic Line creation
mesh[1]:new_line({0, 30}, {60, -30}, 0xff0000ff)

-- Test different number of colors being used
mesh[1]:new_line({80, 30}, {140, -30}, {0xff0000ff, 0x0000ffff})
mesh[1]:new_line({160, 30}, {220, -30}, {0x0000ffff, 0xff0000ff, 0xffff00ff})

-- Lots of colors and z-axis involved
mesh[1]:new_line({240, 30}, {300, -30, -50}, {0x0000ffff, 0xff0000ff,
  0xffff00ff, 0x00ff00ff, 0xffffffff, 0xff00ffff})

-- Test for the no_gradient option
local no_gradient = mesh[1]:new_line({320, 30}, {380, -30}, {0x0000ffff,
  0xff0000ff, 0xffff00ff}, {no_gradient=true})
-- print(inspect(no_gradient:compile()))

-- Test for wider lines (width option)
mesh[1]:new_line({400, 30}, {460, -30}, 0xff0000ff, {width=5})
mesh[1]:new_line({480, 30}, {540, -30}, {0xff0000ff, 0x0000ffff, 0xffff00ff},
  {width=2, no_gradient=true})  -- combining options too
mesh[1]:new_line({560, 30}, {620, -30}, {0xff0000ff, 0x0000ffff, 0xffff00ff},
  {width=5, no_gradient=true})
mesh[1]:new_line({640, 30}, {700, -30}, {0xff0000ff,
  0x0000ffff, 0xffff00ff}, {width=5})


pic.print_memory_usage("Line object tests")


-- Test basic Polygons
mesh[2]:new_polygon({{0, 30}, {30, -30}, {60, 0}}, 0xff0000ff)
mesh[2]:new_polygon({{80, 30}, {110, -30}, {140, 0}},
  {0x0000ffff, 0xff0000ff, 0xffff00ff})
mesh[2]:new_polygon({{160, 30}, {190, -30}, {220, 0}},
  0x00ff00ff, {is_closed=false})

-- Polygons with different width and joint style
mesh[2]:new_polygon({{240, 30}, {270, -30}, {300, 0}},
  {0xff0000ff, 0x00ff00ff, 0x0000ffff}, {width=10, joint="round"})

-- More complex polygonal chain
mesh[2]:new_polygon({{320, 30}, {340, 0}, {320, -30}, {360, -15, -50},
  {380, 15, -50}}, 0xff0000ff)

-- Test transforms, since separate transform tests are
--  only performed on Line object
mesh[2]:new_polygon({{400, 10}, {430, -50}, {460, -20}},
  {0xff8000ff, 0xff8000ff, 0xff8000ff}):move({0, 20, 0})

-- Test Chain as a Polygon alias
mesh[2]:new_chain({{480, 30}, {510, -30}, {540, 0}}, 0x00ff00ff)


pic.print_memory_usage("Polygon object tests")


-- Test Arc object
mesh[3]:new_arc(30, -20, 30, 30, 0, math.pi, 36, 0xff0000ff)
mesh[3]:new_arc(110, -20, 30, 30, 0, math.pi, 36, 0xff0000ff,
  {width=5})
mesh[3]:new_arc(190, -20, 30, 30, 0, math.pi, 36, 0x00ff00ff,
  {is_closed=true})
mesh[3]:new_arc(270, -20, 30, 30, 0, math.pi, 36, 0x00ff00ff,
  {width=10, is_closed=true})

pic.print_memory_usage("Arc object tests")


-- Test other shapes
mesh[4]:new_ellipse(30, 0, 30, 15, 80, 0xff0000ff, {width=5}):rotate(
  {0, 0, -math.pi/6}, {30, 0}
)

pic.print_memory_usage("Testing other shapes")


-- Test transforms
mesh[5]:new_line({0, 30}, {60, -30}, 0xff0000ff)  -- for reference
mesh[5]:new_line({10, 25, 20}, {70, -35, 20}, 0xff8000ff):move({70, 5, -20})
mesh[5]:new_line({0, 30}, {60, -30}, 0xffff00ff):move(pic.PointPolar(160, 0))
mesh[5]:new_line({240, 30}, {300, -30}, 0x80ff00ff):rotate(
  {32/36*math.pi, 32/36*math.pi, 32/36*math.pi}, {270, 0}
)
mesh[5]:new_line({335, 15}, {365, -15},0x00ff00ff):scale(
  {2, 2.5, 0}, {350, 0})
mesh[5]:new_line({430, 30}, {430, -30}, 0x00ff80ff):shear(
  {-1, 0, 10}, {430, 0})


pic.print_memory_usage("Transformations")


-- Test mesh-wide transforms
mesh[6]:new_line({0, 30}, {60, -30}, 0xff0000ff)
mesh[6]:move({80, 0})


pic.print_memory_usage("Mesh transformations")



-- test different point types
-- mesh[7]:new_line(pic.Point(0, 30), pic.PointPolar(180, 2.05, 10), 0x00ff00ff)


pic.print_memory_usage("Point types")


-- Test different Color types
mesh[8]:new_line({0, 30}, {60, -30, -25}, {pic.Color(0xff0000ff),
  pic.ColorRGB(0, 0, 255), pic.ColorRGBA(255, 255, 0, 50),
  pic.ColorHSV(180, 1, 0.5)})


pic.print_memory_usage("Color types")


-- Line should not be visible (test for implying default value,
-- when no colors specified)
mesh[9]:new_line({0, 30}, {60, -30})
mesh[9]:new_line({0, 30}, {30, 0}, 0xffffffff)  -- for reference
mesh[9]:new_polygon({{80, 30}, {110, -30}, {140, 0}})
mesh[9]:new_line({80, 30}, {110, 0}, 0xffffffff)  -- for reference


pic.print_memory_usage("Extra tests")


-- Compile the meshes

meshes = pic.compile_meshes(mesh)
pic.print_memory_usage("Mesh compilation")

-- print(inspect(meshes))
