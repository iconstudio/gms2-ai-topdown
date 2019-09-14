/// @description entity_properties_initialize(hp, regen_time_per_hp)
/// @function entity_properties_initialize
/// @param hp { real }
/// @param regen_time_per_hp { integer }
hp_max = argument0
hp = hp_max
hp_regen_value = 1 / argument1
var gh = oGameGlobal.motion_planning_grid_size_horizontal
var gv = oGameGlobal.motion_planning_grid_size_vertical
x = floor(x / gh) * gh + gh * 0.5
y = floor(y / gv) * gv + gv * 0.5
