local arc = {}


-- Get current path for relative imports
local current_file = ...


-- Deduct the path of the library for relative imports
local function relative_import(file)

  local library_folder = current_file:match("(.+)/[^/]*$") .. "/"
  local lib = require(library_folder .. file)

  return lib
end


local basic = relative_import("basic.lua")
local polygon = relative_import("polygon.lua")


--- Add an arc of an ellipse to a mesh.
-- This function creates an arc by sampling points along an ellipse.
-- For a wide arc (width > 1) the function draws several complete arcs
-- with slightly modified radii. If options.is_closed is true, a closing
-- polygon is inserted so that the final joining segment uses the same width.
--
-- Parameters:
--   mesh        - Existing mesh or nil (mesh is a table: {vertices, segments, colors})
--   cx, cy      - Center of the ellipse
--   rx, ry      - Horizontal and vertical radii
--   start_angle - Starting angle (in radians)
--   end_angle   - Ending angle (in radians)
--   segments    - Number of segments to approximate the arc (default 36)
--   colors      - Either a single color (table) or a table of colors (one per point)
--   constants   - Table with constants (e.g., FAKE_WIDTH_LINE_GAP)
--   options     - Options table. Recognized fields:
--                   is_closed (boolean) to close the arc,
--                   width (number) to draw a wide arc.
--
-- Returns: the updated mesh.
function arc.add_arc(mesh, cx, cy, rx, ry, start_angle, end_angle, segments, colors, constants, options)
  local mesh = mesh or {{}, {}, {}}
  segments = segments or 36
  options = options or {}
  local width = options.width or 1
  local gap = (constants and constants.FAKE_WIDTH_LINE_GAP) or 1

  -- Determine which offsets to use for a wide arc.
  local offsets = {}
  if width == 1 then
    offsets = {0}
  elseif width % 2 == 1 then
    offsets = {0}
    local half = (width - 1) / 2
    for i = 1, half do
      table.insert(offsets, i * gap)
      table.insert(offsets, -i * gap)
    end
  else
    offsets = {}
    local half = width / 2
    for i = 1, half do
      table.insert(offsets, (i - 0.5) * gap)
      table.insert(offsets, -(i - 0.5) * gap)
    end
  end

  for _, offset in ipairs(offsets) do
    local arc_points = {}
    local arc_colors = {}
    local angle_step = (end_angle - start_angle) / segments

    -- Sample points along the arc using the modified radii.
    for i = 0, segments do
      local angle = start_angle + i * angle_step
      local x = cx + (rx + offset) * math.cos(angle)
      local y = cy + (ry + offset) * math.sin(angle)
      table.insert(arc_points, {x, y, 0})
      if type(colors) == "table" and #colors > 1 then
        table.insert(arc_colors, colors[(i % #colors) + 1])
      else
        table.insert(arc_colors, colors or {1, 1, 1})
      end
    end

    -- Draw the arc segment-by-segment.
    for i = 2, #arc_points do
      local segment_points = {arc_points[i - 1], arc_points[i]}
      local segment_colors = {arc_colors[i - 1], arc_colors[i]}
      mesh = basic.add_line(mesh, segment_points, segment_colors)
    end

    -- If the arc should be closed, draw a closing polygon
    -- so that the joining segment gets proper width and joint handling.
    if options.is_closed then
      local A = arc_points[1]
      local B = arc_points[#arc_points]
      local cA = arc_colors[1]
      local cB = arc_colors[#arc_colors]
      -- Compute the angle of the closing segment.
      local angle = math.atan(B[2] - A[2], B[1] - A[1])
      -- A very small offset used to create short connecting segments.
      local epsilon = gap * 0.1
      -- Build four vertices:
      --   v1: exactly at A (the arc’s start)
      --   v2: a very short distance from A in the direction toward B
      --   v3: a very short distance from B in the opposite direction
      --   v4: exactly at B (the arc’s end)
      local v1 = A
      local v2 = { A[1] + epsilon * math.cos(angle), A[2] + epsilon * math.sin(angle), A[3] }
      local v3 = { B[1] - epsilon * math.cos(angle), B[2] - epsilon * math.sin(angle), B[3] }
      local v4 = B
      local poly_points = {v1, v2, v3, v4}
      local poly_colors = {cA, cA, cB, cB}

      -- Use the polygon module to add the closing polygon.
      mesh = polygon.add_polygon(mesh, poly_points, poly_colors, constants, {is_closed = true, width = width})
    end

  end

  return mesh
end


return arc
