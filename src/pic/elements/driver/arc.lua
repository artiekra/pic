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


--- Add an arc of an ellipse to a mesh.
-- This function creates an arc by sampling points along an ellipse.
-- For a wide arc (width > 1) the function draws several complete arcs
-- with slightly modified radii. This produces proper joints.
--
-- @param mesh Existing mesh or nil (mesh is a table: {vertices, segments, colors})
-- @param cx Center x coordinate of the ellipse.
-- @param cy Center y coordinate of the ellipse.
-- @param rx Horizontal radius of the ellipse.
-- @param ry Vertical radius of the ellipse.
-- @param start_angle Starting angle (in radians).
-- @param end_angle Ending angle (in radians).
-- @param segments Number of segments to approximate the arc (default 36).
-- @param colors Either a single color (table) or a table of colors (one per point).
-- @param constants Table with constants to use (e.g., FAKE_WIDTH_LINE_GAP).
-- @param options Options table (e.g., is_closed, width, etc.).
--                options.width determines how many arcs are drawn.
-- @return Mesh with the added arc.
function arc.add_arc(mesh, cx, cy, rx, ry, start_angle, end_angle, segments, colors, constants, options)
  local mesh = mesh or {{}, {}, {}}
  segments = segments or 36
  options = options or {}
  local width = options.width or 1
  local gap = (constants and constants.FAKE_WIDTH_LINE_GAP) or 1

  -- Build a list of offsets for the arcs.
  -- For a single-width arc, only one pass is drawn (offset 0).
  -- For odd widths, we draw the center arc (offset 0) plus symmetric pairs.
  -- For even widths, we draw symmetric pairs using half-gap offsets.
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

  -- For each offset, compute and draw the complete arc.
  -- The arc is computed by sampling (segments+1) points along the ellipse,
  -- using (rx + offset) and (ry + offset) as the effective radii.
  for _, offset in ipairs(offsets) do
    local arc_points = {}
    local arc_colors = {}
    local angle_step = (end_angle - start_angle) / segments

    for i = 0, segments do
      local angle = start_angle + i * angle_step
      local x = cx + (rx + offset) * math.cos(angle)
      local y = cy + (ry + offset) * math.sin(angle)
      table.insert(arc_points, {x, y, 0})
      if type(colors) == "table" and #colors > 1 then
        table.insert(arc_colors, colors[(i % #colors) + 1])
      else
        table.insert(arc_colors, colors or {1, 1, 1})  -- default white
      end
    end

    if options.is_closed then
      -- If the arc should be closed, add the first point at the end.
      table.insert(arc_points, arc_points[1])
      table.insert(arc_colors, arc_colors[1])
    end

    -- Draw the arc segment-by-segment.
    for i = 2, #arc_points do
      local segment_points = {arc_points[i - 1], arc_points[i]}
      local segment_colors = {arc_colors[i - 1], arc_colors[i]}
      mesh = basic.add_line(mesh, segment_points, segment_colors)
    end
  end

  return mesh
end


return arc
