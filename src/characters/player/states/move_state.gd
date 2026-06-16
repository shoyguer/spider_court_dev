class_name PlayerMoveState
extends State
## Player is walking on the ground plane.


## Plays the walk animation.
func enter() -> void:
	context.play_animation(context.walk_anim)


## Moves the player and returns to idle when there is no input.
func physics_update() -> State:
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir == Vector2.ZERO:
		return context.idle_state
	# Input y maps to world Z so up/down moves into/out of the screen.
	var dir: Vector3 = Vector3(input_dir.x, 0.0, input_dir.y)
	context.velocity.x = dir.x * context.speed
	context.velocity.z = dir.z * context.speed
	context.face_direction(input_dir.x)
	context.move_and_slide()
	return null
