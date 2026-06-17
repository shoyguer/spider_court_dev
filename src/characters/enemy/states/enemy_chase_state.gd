class_name EnemyChaseState
extends State
## Enemy moves toward the player until it is close enough to fight.


## Plays the walk animation.
func enter() -> void:
	context.play_animation(context.walk_anim)


## Moves toward the target; enters combat in range, idles if target is lost.
func physics_update() -> State:
	if not is_instance_valid(context.combat_target):
		return context.idle_state

	var target: Player = context.combat_target
	# Flatten Y so chasing stays on the ground plane.
	var to_target: Vector3 = target.global_position - context.global_position
	to_target.y = 0.0

	if to_target.length() <= context.combat_range:
		return context.combat_state

	var dir: Vector3 = to_target.normalized()
	context.velocity.x = dir.x * context.speed
	context.velocity.z = dir.z * context.speed
	context.face_direction(dir.x)
	context.move_and_slide()
	return null
