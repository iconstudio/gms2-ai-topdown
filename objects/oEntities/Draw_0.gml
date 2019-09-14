/// @description 자신과 장전 표시기 그리기
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, draw_angle, $ffffff, 1)
if attacking
	draw_sprite_ext(sprite_index, 1, x, y, 1, 1, draw_angle, $ffffff, attacking_time / attacking_period)
