class_name StateMachine
extends Node
## Runs the active state and handles transitions between states.


var current_state: State = null
var context: Node = null


## Injects the context into all child states and enters the first state.
func init(new_context: Node, new_state: State) -> void:
	context = new_context
	for child: State in get_children():
		child.init(context)
	change_state(new_state)


## Exits the current state and enters the new one.
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()


## Updates the active state and transitions if it returns a new one.
func update() -> void:
	var new_state: State = current_state.update()
	if new_state:
		change_state(new_state)


## Physics-updates the active state and transitions if it returns a new one.
func physics_update() -> void:
	var new_state: State = current_state.physics_update()
	if new_state:
		change_state(new_state)


## Forwards input to the active state and transitions if it returns a new one.
func input() -> void:
	var new_state: State = current_state.input()
	if new_state:
		change_state(new_state)
