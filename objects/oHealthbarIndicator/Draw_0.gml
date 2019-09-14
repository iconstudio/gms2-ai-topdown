/// @description 모든 개체들의 체력 표시막대 그려주기
with oEntities {
	draw_healthbar(bbox_left - 2, bbox_bottom + 2, bbox_right + 2, bbox_bottom + 10, hp / hp_max * 100, 0, c_red, c_green, 0, true, true)
}
