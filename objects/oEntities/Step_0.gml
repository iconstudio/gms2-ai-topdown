/// @description 동작
if attack_delay_time < attack_delay_period
	attack_delay_time++
if attacking {
	if attacking_time < attacking_period {
		attacking_time++
	} else {
		attacking = false
		attack_delay_time = 0
	}
}

/*
	 은엄폐엔 최대 시도 시간이 존재합니다.
*/
if cover_time < cover_period
	cover_time++
else
	covering = false

/*
	 체력은 천천히 회복됩니다.
*/
if hp < hp_max
	hp += hp_regen_value
else
	hp = hp_max
var hp_ratio = hp / hp_max

/*
	 한 개체의 전략은 바로 변하지 않습니다. 전략 행동을 취하기도 전에 너무 이른 때에 
	전략이 변해서 개체의 행동이 불규칙하게 변하는 것을 막기 위함입니다.
*/
if strategy_change_time < strategy_change_period {
	strategy_change_time++
} else {
	if strategy_index != strategy_change_next
		strategy_index = strategy_change_next
}

// 적군이 없다면 작동하지 않습니다.
//
if !instance_exists(attack_enemy)
	exit

/*
	 인공지능의 행동을 정의하기 전에 필요한 변수들을 선언하는 부분입니다.
*/
event_user(0)
var motion_planning_noise = [attack_range_risk - random(attack_range_risk * 2), attack_range_risk - random(attack_range_risk * 2)]
ds_list_clear(attack_target_list)

/*
	 적 탐색은 항상 이루어져야 더 매끄러운 행동을 보장합니다.
*/
var search_circle = collision_circle_list(x, y, attack_sight, attack_enemy, false, true, attack_target_list, true)

if strategy_index != strategy.rush and search_circle == 0
	// 만약 돌격 중이 아니고 주변에 적이 없으면 공격 준비를 해제합니다.

	attack_ready = false

/*
	 가장 가까운 아군과 장애물들을 갱신하는 부분입니다.
*/
var support_distance = 0
ds_list_clear(cover_list)
var search_obstacles = collision_circle_list(x, y, attack_range, cover_object, false, true, cover_list, true)
if strategy_target_update_time < strategy_target_update_period {
	strategy_target_update_time++
} else {
	if number_ally > 1 {
		xprevious = x
		x = -100000
		support_target = instance_nearest(xprevious, y, support_ally)
		support_distance = point_distance(xprevious, y, support_target.x, support_target.y)
		x = xprevious
	} else {
		support_target = noone
	}

	strategy_target_update_time = 0
}

/*
	 주변에 적이 있어야 공격 목표가 갱신됩니다. 그러나 검색된 적이 없다고해서 목표를 가장 
	가까운 적으로 정하지는 않습니다. 각 전략에 맞게 때에 따라 목표를 수정합니다.
*/
var attack_distance = 9999, check_line = noone
if 0 < search_circle {
	attack_target = ds_list_find_value(attack_target_list, 0)
	attack_distance = point_distance(x, y, attack_target.x, attack_target.y)
	check_line = collision_line(x, y, attack_target.x, attack_target.y, cover_object, false, true)
	strategy_attack_distance = path_get_length(motion_planning_path)
}

/*
	 이 개체가 선택한 전략에 따라 작동하는 부분입니다. 전략 변수 strategy는 무조건 이 
	 단락에서만 변경되어야 합니다.
*/
switch strategy_index {
	case strategy.hold:
		if hp_ratio < 0.5 or number_ally < number_enemy
			// 적의 숫자가 아군보다 많으면 후퇴를 시도합니다.

			strategy_change(strategy.retreat)
		else
			// 그 외에는 다시 공격과 은엄폐를 시도합니다.

			strategy_change(strategy.attack)

		strategy_set_target(x, y)
	break

	case strategy.attack:
		if !instance_exists(attack_target) {
			// 시야 안에 들어온 적이 없다면 다른 적을 찾아갑니다.

			attack_target = instance_find(attack_enemy, irandom(number_enemy - 1))
		}
		attack_distance = point_distance(x, y, attack_target.x, attack_target.y)
		check_line = collision_line(x, y, attack_target.x, attack_target.y, cover_object, false, true)
		strategy_set_target(attack_target.x + motion_planning_noise[0], attack_target.y + motion_planning_noise[1])

		if (attack_distance <= attack_range_risk and hp < attack_target.hp)
		or (check_line and strategy_attack_distance < attack_range_risk and hp_ratio < 0.2) and !covering {
			// 적과 너무 가까우면서 체력이 적다면 후퇴를 시도합니다. 하지만 은엄폐도 잠깐 시도합니다.

			strategy_change(strategy.retreat)
		} else if 0.9 < hp_ratio and support_distance < attack_range * 0.5 and irandom(24) == 0 and irandom(number_enemy) < number_ally and !covering {
			// 아군과 붙어있고 체력이 충분하다면 돌격을 시도합니다. 하지만 은엄폐도 잠깐 시도합니다.

			strategy_change(strategy.rush)
		}

		var condition_recover = (hp_ratio < 0.4 and 0 < search_obstacles)
		or (hp_ratio < 0.8 and 1 < search_circle and number_ally < number_enemy)
		or (hp_ratio < 0.6 and !check_line and attacking)

		/*
			  은엄폐는 가장 가까운 적을 중심으로 주변 장애물을 검사함으로써 가장 적절한 
			 장애물을 찾는 것으로 행해집니다.
			  분량은 매우 많지만 covering 변수에 의해 일정 시간마다만 실행되도록 제한되어 
			 있기 때문에 최적화는 큰 문제가 아닙니다.
		*/
		if condition_recover and !covering {
			// 은엄폐를 시도합니다.

			if sprite_width * 2 < support_distance and irandom(3) == 0 and hp < support_target.hp {
				// 아군과의 거리가 멀고 대신 맞아줄 수 있는 아군이라면 집결을 시도합니다.

				strategy_set_target(support_target.x + motion_planning_noise[0], support_target.y + motion_planning_noise[1])
			} else if 0 < search_obstacles {
				// 주변에 장애물이 있다면 그 뒤로 숨습니다.

				var obstacle, obstacle_back_x, obstacle_back_y, obstacle_direction, obstacle_range
				var direction_flag = choose(-1, 1)
				for (var i = 0; i < search_obstacles; ++i) {
					obstacle = cover_list[| i]
					obstacle_direction = point_direction(obstacle.x, obstacle.y, attack_target.x, attack_target.y) + direction_flag * 180

					obstacle_range = 16
					for (var j = 0; j < 4; ++j) {
						// 엄폐물 뒤로 4번 더 진행하면서 빈 공간을 찾아냅니다.

						obstacle_back_x = obstacle.x + lengthdir_x(obstacle_range, obstacle_direction)
						obstacle_back_y = obstacle.y + lengthdir_y(obstacle_range, obstacle_direction)

						// 찾은 위치에는 장애물이 닿으면 안됩니다.
						//
						if place_meeting(obstacle_back_x, obstacle_back_y, cover_object) and collision_line(obstacle_back_x, obstacle_back_y, attack_target.x, attack_target.y, cover_object, true, true) {
							ds_list_add(cover_target_list, [obstacle_back_x, obstacle_back_y])
							break
						}
						obstacle_range += 16
					}
				}

				var result = cover_target_list[| 0]
				strategy_set_target(result[0], result[1])
				ds_list_clear(cover_target_list)
			} else {
				// 주변에 장애물이 없다면 일직선 상의 후퇴 혹은 재생성 구역으로 후퇴, 혹은 공격을 시도합니다.

				var direction_flag = choose(-1, 1)
				var enemy_seeing_direction = point_direction(x, y, attack_target.x, attack_target.y) + direction_flag * 180
				var retreat_destinatio_distance = attack_range_risk * (random(0.2) + 0.8)
				var retreat_destination_x = lengthdir_x(retreat_destinatio_distance, enemy_seeing_direction)
				var retreat_destination_y = lengthdir_y(retreat_destinatio_distance, enemy_seeing_direction)
				strategy_set_target(attack_target.x + retreat_destination_x + motion_planning_noise[0], attack_target.y + retreat_destination_y + motion_planning_noise[1])
			}

			cover_time = 0
			covering = true
		}

		// 은엄폐 시도 중이 아닐 때
		//
		if !covering {
			if attacking {
				strategy_set_target(x + motion_planning_noise[0], y + motion_planning_noise[1])
			}
		}
	break

	case strategy.rush:
		if !instance_exists(attack_target) {
			// 시야 안에 들어온 적이 없다면 다른 적을 찾아갑니다.

			attack_target = instance_find(attack_enemy, irandom(number_enemy - 1))
			strategy_set_target(attack_target.x + motion_planning_noise[0], attack_target.y + motion_planning_noise[1])

			if attack_range < support_distance and attack_range < strategy_attack_distance
				// 아군과의 거리가 멀고, 적과의 거리도 멀다면 집결을 시도합니다.

				strategy_change(strategy.gather)
			else if hp_ratio < 0.2
				// 체력이 너무 적다면 후퇴를 시도합니다.

				strategy_change(strategy.retreat)
		} else {
			strategy_change(strategy.attack)
		}
	break

	case strategy.retreat:
		attack_target = instance_nearest(x, y, attack_enemy)
		attack_distance = point_distance(x, y, attack_target.x, attack_target.y)

		var retreat_accesible_ratio = strategy_attack_distance / attack_target.attack_range
		if 0.3 <= hp_ratio and (number_enemy <= number_ally or attack_target.hp < attack_target.hp_max * 0.2) {
			// 만약 체력이 충분하고, 적의 수가 아군보다 적거나 적의 체력이 적다면 싸웁니다.

			if attack_range * 0.5 < support_distance
				// 아군과의 거리가 멀다면 집결을 시도합니다.

				strategy_change(strategy.gather)
			else
				// 그 외엔 공격을 시도합니다.

				strategy_change(strategy.attack)

			strategy_set_target(attack_target.x + motion_planning_noise[0], attack_target.y + motion_planning_noise[1])
		} else if 1 <= retreat_accesible_ratio {
			// 안전하게 도망갈 수 있다면 그냥 도망갑니다.

			strategy_set_target(motion_planning_x_spawned, motion_planning_y_spawned)
		} else {
			// 무작위 확률을 섞어서 임전무퇴 상황에서 변수를 만들어줍니다.
			//
			if random(0.3) + 0.4 <= hp_ratio {
				if 1 <= search_circle or attack_target.hp < attack_target.hp_max * 0.2
					// 적의 체력이 적으면 맞서 싸웁니다.

					strategy_set_target(attack_target.x + motion_planning_noise[0], attack_target.y + motion_planning_noise[1])
				else
					strategy_set_target(motion_planning_x_spawned, motion_planning_y_spawned)
			} else {
				strategy_set_target(motion_planning_x_spawned, motion_planning_y_spawned)
			}
		}
	break

	case strategy.gather:
		if !instance_exists(support_target) {
			// 적이 훨씬 많고 아군이 자기 혼자뿐이라면 후퇴합니다.

			if 2 < irandom(number_enemy) {
				// 적의 수가 많으면 재생성 구역으로 돌아갑니다.

				strategy_change(strategy.retreat)

				strategy_set_target(motion_planning_x_spawned, motion_planning_y_spawned)
			} else {
				// 하지만 그 외의 경우에는 공격을 시도합니다.

				strategy_change(strategy.rush)
			}
		} else {
			// 집결에는 제한 시간이 존재합니다. 인공지능끼리 과도하게 뭉치는 것을 방지합니다.

			if strategy_gather_period <= strategy_gather_time++ or support_distance < attack_range {
				strategy_gather_time = random(strategy_gather_period) // 거기에 집결 시간을 더 짧게 만듭니다.
				strategy_change(strategy.attack)
			}

			strategy_set_target(support_target.x + motion_planning_noise[0], support_target.y + motion_planning_noise[1])
		}
	break

	default:
	break
}

/*
	 공격을 수행하는 부분입니다.
*/
if instance_exists(attack_target) {
	check_line = collision_line(x, y, attack_target.x, attack_target.y, cover_object, false, true)
	if attack_distance <= attack_range and !check_line {
		if !attacking and attack_delay_period <= attack_delay_time {
			// 공격을 행하는 데에는 공격 시전 시간과 공격 주기 두 개가 필요합니다.

			if attack_ready_time < attack_ready_period
				// 또한 적을 처음 만날 때에는 공격에 더 오랜 시간이 걸립니다.

				attack_ready_time++
			else
				attack_ready = true

			if attack_ready {
				with instance_create_layer(x, y, "Bullets", attack_projectile) {
					destination_x = other.attack_target.x
					destination_y = other.attack_target.y
					direction = point_direction(x, y, destination_x, destination_y)
					image_angle = direction
					speed = other.attack_projectile_speed
					alarm[0] = other.attack_projectile_life
				}
				attacking = true
				attacking_time = 0
			}
		}
	}
}

/*
	 격자 경로를 갱신하는 부분입니다.
*/
if strategy_x != x or strategy_y != y {
	mp_grid_path(oGameGlobal.motion_planning_grid, motion_planning_path, x, y, strategy_x, strategy_y, true)
	motion_planning_x = path_get_point_x(motion_planning_path, 1)
	motion_planning_y = path_get_point_y(motion_planning_path, 1)
}

/*
	 좌표를 갱신하는 부분입니다.
*/
if motion_planning_x != x or motion_planning_y != y {
	// 목표 좌표와 현재 좌표가 다를 경우에 이동합니다.

	if strategy_index != strategy.rush {
		// 돌격 전략을 시도하는 경우에는 회피 기동을 하지 않습니다.

		dodge_target = instance_nearest(x, y, dodge_object)
		var dodge_distance = distance_to_object(dodge_object)
		if dodge_distance < 16 {
			// 너무 가까워서 피할 수 없는 총알은 무시합니다.

			mp_potential_step_object(motion_planning_x, motion_planning_y, move_speed, cover_object)
		} else if dodge_distance < dodge_distance_min and !collision_line(x, y, dodge_target.x, dodge_target.y, cover_object, true, true) {
			// 총알을 단순히 반대 방향으로 움직임으로써 피할 수 있느냐 없느냐를 판정합니다.

			var vx1 = lengthdir_x(1, dodge_target.direction)
			var vy1 = lengthdir_y(1, dodge_target.direction)
			var vx2 = dodge_target.x - x
			var vy2 = dodge_target.y - y

			// 두 벡터의 내적은 사잇값을 반영합니다. 이 예제에서 dodge_width는 15도로 정해져 있습니다.
			//
			if dot_product(vx1, vy1, vx2, vy2) > dodge_width * dodge_distance {
				// 만약 사잇각이 15도 이하라면 단순히 뒤로 감으로써 피할 수 없습니다.

				var angle_vector = dodge_target.direction - point_direction(x, y, dodge_target.x, dodge_target.y)
				var dodge_destination_factor = dodge_distance_min * (random(0.5) + 0.5)
				var dodge_destination_x, dodge_destination_y

				if angle_vector < 0 {
					// 이 개체가 총알의 방향 기준으로 왼쪽에 있습니다. 그러므로 오른쪽으로 피합니다.

					dodge_destination_x = x - lengthdir_x(dodge_destination_factor, dodge_target.direction + 90)
					dodge_destination_y = y - lengthdir_y(dodge_destination_factor, dodge_target.direction + 90)
				} else if angle_vector > 0 {
					// 이 개체가 총알의 방향 기준으로 오른쪽에 있습니다. 그러므로 왼쪽으로 피합니다.

					dodge_destination_x = x - lengthdir_x(dodge_destination_factor, dodge_target.direction - 90)
					dodge_destination_y = y - lengthdir_y(dodge_destination_factor, dodge_target.direction - 90)
				} else {
					// 이 개체가 총알의 진행 방향과 정확하게 같은 쪽으로 가고 있습니다. 무작위로 피합니다.

					var dodge_destination_direction = choose(-90, 90)
					dodge_destination_x = x - lengthdir_x(dodge_destination_factor, dodge_target.direction + dodge_destination_direction)
					dodge_destination_y = y - lengthdir_y(dodge_destination_factor, dodge_target.direction + dodge_destination_direction)	
				}
					
				// 한편 회피 기동을 할 때에는 실제 목표 좌표는 변하지 않습니다.
				mp_potential_step_object(dodge_destination_x, dodge_destination_y, move_speed, cover_object)
			} else {
				if number_ally <= number_enemy
					// 아군의 숫자보다 적의 숫자가 더 많다고 판단되면 더 적극적으로 피합니다.

					mp_potential_step_object(dodge_target.x, dodge_target.y, -move_speed, cover_object)
				else
					// 그 외에는 일반적인 이동을 합니다.

					mp_potential_step_object(motion_planning_x, motion_planning_y, move_speed, cover_object)
			}
		} else {
			// 만약 장애물이 고체가 아니더라도 밟지 않고 지나다닙니다.

			mp_potential_step_object(motion_planning_x, motion_planning_y, move_speed, cover_object)
		}
	} else {
		mp_potential_step_object(motion_planning_x, motion_planning_y, move_speed, cover_object)
	}
}

// 표시되는 각도를 변경합니다.
draw_angle = direction
