/// @description 개체 재생성
if !instance_exists(spawn_instance) {
	if spawn_time < spawn_period {
		spawn_time++
	} else {
		event_user(0)

		spawn_time = 0
	}
}
