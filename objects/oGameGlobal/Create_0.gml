/// @description 초기화
motion_planning_grid_size_horizontal = 32
motion_planning_grid_size_vertical = 32
motion_planning_grid = mp_grid_create(0, 0, room_width / motion_planning_grid_size_horizontal, room_height / motion_planning_grid_size_vertical, motion_planning_grid_size_horizontal, motion_planning_grid_size_vertical)
mp_grid_add_instances(motion_planning_grid, oBlock, false)

is_early_game = true
number_red = 0
number_blue = 0
kills_red = 0
kills_blue = 0

instance_create_layer(0, 0, "UI", oHealthbarIndicator)
instance_create_layer(0, 0, "UI_Below", oShadowDrawer)

alarm[0] = seconds(30)
