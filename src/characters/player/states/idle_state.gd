class_name PlayerIdleState
extends State
## Player is standing still and waiting for movement input.


## Stops the player and plays the idle animation.
func enter() -> void:
	context.velocity = Vector3.ZERO
	context.play_animation(context.idle_anim)


## Switches to the move state as soon as there is input.
func physics_update() -> State:
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO:
		return context.move_state
	return null
