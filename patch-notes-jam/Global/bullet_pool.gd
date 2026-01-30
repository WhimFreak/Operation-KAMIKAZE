extends Node2D

const HOSTILE_BULLET = preload("uid://6oa8kg27uuq4")
const START_AMOUNT: int = 0

var pool: Array[HostileBullet]

func _ready() -> void:
	for i in START_AMOUNT:
		var bullet = HOSTILE_BULLET.instantiate()
		add_child(bullet)
		bullet.recycle()
		
		
func add_to_pool(bullet: HostileBullet):
	if not pool.has(bullet):
		pool.append(bullet)
	clean_pool()
		
func take_from_pool():
	clean_pool()
	if pool.is_empty():
		var new_bullet = HOSTILE_BULLET.instantiate()
		call_deferred("add_child", new_bullet)
		new_bullet.recycle()
		
		return pool.pop_at(pool.find(new_bullet))
		
	var bullet: HostileBullet = pool.pop_front()
	return bullet
		
		
func clean_pool():
	pool = pool.filter(func(bullet): return bullet != null)
