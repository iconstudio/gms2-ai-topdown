/// @description 피해
if --hp <= 0 {
	oGameGlobal.kills_blue++
	instance_destroy()
}

instance_destroy(other.id)
