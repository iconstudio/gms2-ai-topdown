/// @description 처치 수 표시
draw_set_color(c_lime)

draw_set_halign(0)
draw_set_valign(0)
draw_text(10, 10, "Red's Score: " + string(kills_red))
draw_text(10, 30, "Blue's Score: " + string(kills_blue))

