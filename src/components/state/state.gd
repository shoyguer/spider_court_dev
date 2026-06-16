class_name State
extends Node
## Base class for every state in a state machine.


var state_machine: StateMachine = null
var context: Node = null


## Stores the actor reference for later use.
func init(new_context: Node) -> void:
	context = new_context


## Called once when this state becomes active.
func enter() -> void:
	pass


## Called once when leaving this state.
func exit() -> void:
	pass


## Per-frame update. Return a State to transition, or null to stay.
func update() -> State:
	return null


## Per-physics-frame update. Return a State to transition, or null to stay.
func physics_update() -> State:
	return null


## Input handling. Return a State to transition, or null to stay.
func input() -> State:
	return null
