extends Relic

func modify_bullet(_player: Player, bullet: Bullet):
	bullet.bounces = true
	return bullet
