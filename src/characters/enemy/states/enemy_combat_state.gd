class_name EnemyCombatState
extends State
## Enemy is in combat. Currently just stops and logs.


## Stops the enemy, plays the combat animation and logs the state.
func enter() -> void:
	context.velocity = Vector3.ZERO
	context.play_animation(context.combat_anim)
	print("Combat state!")
