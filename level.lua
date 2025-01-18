pewpew.set_level_size(500fx, 500fx)


-- Create test meshes
local function create_meshes()

  local mesh = pewpew.new_customizable_entity(0fx, 0fx)
  pewpew.customizable_entity_start_spawning(mesh, 0)
  pewpew.customizable_entity_set_mesh(mesh, "/dynamic/mesh.lua", 0)

end


local camera_current_x_override = 0fx
local camera_current_y_override = 0fx
local camera_current_distance = 0fx


-- Execute every tick
local function level_tick()
  local camera_movement_speed = 5
  local camera_zoom_speed = 10fx

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
