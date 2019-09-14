/// @description 피해
if --hp <= 0 {
	oGameGlobal.kills_red++
	instance_destroy()
}

instance_destroy(other.id)
