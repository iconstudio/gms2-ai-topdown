/// @description 인공지능 변수 특수화
event_inherited()

/*
	전술적 목표
*/
attack_enemy = oRed										// 공격의 목표가 되는 객체의 종류
attack_target = noone									// 공격의 목표 개체
support_ally = oBlue									// 지원의 목표가 되는 객체의 종류
support_target = noone								// 지원을 받을 개체
cover_object = oBlock									// 숨을 객체의 종류
cover_target = noone									// 숨을 개체
dodge_object = oRedBullet							// 피할 객체의 종류

/*
	공격 속성
*/
attack_projectile = oBlueBullet				// 공격 수단
attack_projectile_speed = 6						// 공격 투사체의 속도
attack_sight = 480										// 시야
attack_range = 320										// 사정거리
attack_range_risk = 256								// 위협 사정거리
attack_projectile_life = attack_range /	attack_projectile_speed // 공격 투사체의 수명
