/// @description 인공지능 초기화
entity_properties_initialize(10, seconds(3))
number_ally = 0 // 아군의 수
number_enemy = 0 // 적군의 수

/*
	 인공지능을 수준을 결정하는 지표들입니다.
	 이 변수들은 인공지능의 행동에 영향을 끼치지만 실시간으로 반영되는 것이 아니라 
	인공지능의 각종 계수들에만 반영됩니다.
*/
intelligence = 50 // 0 ~ 100
intelligence_factor = intelligence / 100
intelligence_factor_inverse = 1 - intelligence_factor

/*
	인공지능의 행동을 정의하는 변수들입니다.
*/
strategy_index = strategy.gather // 처음에는 서로 뭉칩니다.
strategy_change_next = strategy.attack
strategy_change_time = 0
strategy_change_period = seconds(3 - intelligence_factor) + 1
strategy_target_update_time = 0
strategy_target_update_period = seconds(intelligence_factor_inverse * 0.7) + 1
strategy_x = x
strategy_y = y
strategy_attack_distance = 9999
strategy_gather_time = 0
strategy_gather_period = seconds(3)

/*
	이동에 필요한 변수들입니다.
*/
motion_planning_path = path_add()
motion_planning_x = x
motion_planning_y = y
motion_planning_x_spawned = xstart
motion_planning_y_spawned = ystart
move_speed = 2
covering = false
cover_time = 0
cover_period = seconds(3)																								// 회피 기동을 실시할 시간 간격
dodge_distance_min = move_speed * seconds(2) + intelligence_factor * 16	// 가까운 총알을 감지하는 최소 거리
dodge_width = lengthdir_x(1, 15) * dodge_distance_min * 0.5							// 총알 판정을 검사할 호의 길이

/*
	전술적 목표 목록
*/
attack_target_list = ds_list_create()	// 찾아낸 적 개체의 목록
support_list = ds_list_create()				// 지원을 받을 개체의 목록
cover_target_list = ds_list_create()	// 은엄폐할 수 있는 좌표의 목록
cover_list = ds_list_create()					// 찾아낸 숨을 객체의 목록

/*
	공격 주기
*/
attacking = false											// 현재 공격 중인지 여부
attacking_time = 0										// 공격 완료 카운터
attacking_period = seconds(0.1)				// 한 공격을 완료하기까지 걸리는 시간
attack_delay_time = 0									// 공격 주기 카운터
attack_delay_period = seconds(1)			// 공격 주기
attack_ready = false									// 첫 공격 시도
attack_ready_time = 0									// 첫 공격을 하기 전까지 걸리는 지연 시간
attack_ready_period = seconds(intelligence_factor_inverse) * 0.5 + 1

/*
	그리기 속성
*/
image_speed = 0
draw_angle = 0
