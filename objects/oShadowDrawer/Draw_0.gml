/// @description 모든 개체들의 그림자 그려주기
draw_set_alpha(0.5)
draw_set_color(0)
with oEntities
	draw_rectangle(bbox_left - 4, bbox_bottom - 2, bbox_right + 4, bbox_bottom + 4, false)
draw_set_alpha(1)
