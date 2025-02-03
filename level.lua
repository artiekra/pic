pewpew.set_level_size(500fx, 500fx)


-- Create a label
local function create_label(x, y, text, scale)
  local label = pewpew.new_customizable_entity(x, y)
  pewpew.customizable_entity_start_spawning(label, 0)
  pewpew.customizable_entity_set_string(label, text)
  pewpew.customizable_entity_set_mesh_scale(label, scale)
  return label
end


-- Create test meshes
local function create_meshes()

  -- Create a single test mesh with a label
  local function create_mesh(text, index)
    create_label(-175fx, -80*fmath.to_fixedpoint(index),
      "#808080ff"..index, 4fx/5fx)
    create_label(0fx, -80*fmath.to_fixedpoint(index),
      text, 4fx/5fx)

    local mesh = pewpew.new_customizable_entity(
      150fx, -80*fmath.to_fixedpoint(index))
    pewpew.customizable_entity_start_spawning(mesh, 0)
    pewpew.customizable_entity_set_mesh(mesh, "/dynamic/mesh.lua", index)
  end

  mesh_names = {"Line object", "Polygon object", "Transforms",
    "Mesh transforms", "Point types", "Color types", "Extra tests"}
  for i, mesh_name in ipairs(mesh_names) do
    create_mesh(mesh_name, i-1)
  end

end


create_label(40fx, 125fx, "Tests for #a81c44ffpic #ffffffff(v1.0.0)", 3fx/2fx)


local camera_current_x_override = 300fx
local camera_current_y_override = -200fx
local camera_current_distance = -400fx


-- Execute every tick
local function level_tick()
  local camera_movement_speed = (1050fx - camera_current_distance) / 80fx
  local camera_zoom_speed = 12fx

  local player_amount = pewpew.get_number_of_players()
  for player_id = 0, player_amount-1 do

    local ma, md, sa, sd = pewpew.get_player_inputs(player_id)
    
    local delta_y, delta_x = fmath.sincos(ma)
    local camera_sign = 1
    if sa > fmath.tau() / 2 then
      camera_sign = -1
    end
    if sd == 0fx then
      camera_sign = 0
    end

    camera_current_x_override = camera_current_x_override +
      delta_x * md * camera_movement_speed
    camera_current_y_override = camera_current_y_override +
      delta_y * md * camera_movement_speed
    camera_current_distance = camera_current_distance +
      camera_sign * sd * camera_zoom_speed

    if camera_current_distance > 990fx then
      camera_current_distance = 990fx
    end

    pewpew.configure_player(player_id,
      {
        camera_x_override = camera_current_x_override,
        camera_y_override = camera_current_y_override,
        camera_distance = camera_current_distance,
      }
    )

  end

end


-- Set up camera and level size
local function game_setup()

  pewpew.set_level_size(500fx, 500fx)

  local player_amount = pewpew.get_number_of_players()
  for player_id = 0, player_amount-1 do
    pewpew.configure_player(player_id,
      {shoot_joystick_color = 0x000020ff,
        move_joystick_color = 0x000020ff})
  end

  pewpew.add_update_callback(level_tick)

  return true
end


game_setup()
create_meshes()
