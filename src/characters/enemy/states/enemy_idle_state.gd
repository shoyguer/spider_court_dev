class_name EnemyIdleState
extends State
## Enemy wanders randomly until it spots the player.


var _direction: Vector3 = Vector3.ZERO


## Starts walking, hooks the wander timer and picks a first direction.
func enter() -> void:
	context.play_animation(context.walk_anim)
	context.wander_timer.timeout.connect(_pick_direction)
	_pick_direction()


## Unhooks the wander timer and stops moving.
func exit() -> void:
	context.wander_timer.timeout.disconnect(_pick_direction)
	context.wander_timer.stop()
	context.velocity = Vector3.ZERO


## Chases the player if in range, otherwise keeps wandering.
func physics_update() -> State:
	var player: Player = context.get_tree().get_first_node_in_group("player") as Player
	if player and context.global_position.distance_to(player.global_position) <= context.aggro_range:
		context.combat_target = player
		return context.chase_state

	context.velocity.x = _direction.x * context.wander_speed
	context.velocity.z = _direction.z * context.wander_speed
	if _direction.length() > 0.01:
		context.face_direction(_direction.x)
	context.move_and_slide()
	return null


## Picks a new random direction (or a pause) and restarts the wander timer.
func _pick_direction() -> void:
	# 35% chance to stand still, otherwise pick a random heading.
	if randf() < 0.35:
		_direction = Vector3.ZERO
	else:
		var ang: float = randf() * TAU
		_direction = Vector3(cos(ang), 0.0, sin(ang))
	context.wander_timer.start(randf_range(context.wander_change_min, context.wander_change_max))
