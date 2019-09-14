/// @description strategy_set_target(x, y)
/// @function strategy_set_target
/// @param x { real }
/// @param y { real }
var gh = oGameGlobal.motion_planning_grid_size_horizontal
var gv = oGameGlobal.motion_planning_grid_size_vertical
strategy_x = floor(argument0 / gh) * gh + gh * 0.5
strategy_y = floor(argument1 / gv) * gv + gv * 0.5
