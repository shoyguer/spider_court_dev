class_name Player
extends CharacterBody3D
## Player actor. Owns the state machine and handles animation and facing.


## Movement speed in units per second.
@export var speed: float = 5.0
## Animation name played while idle.
@export var idle_anim: String = "idle"
## Animation name played while moving.
@export var walk_anim: String = "walk"
## How fast the sprite flips when changing direction.
@export var turn_speed: float = 12.0
## Health pool of this player.
@export var health: StatPool = null
## Base attributes of this player.
@export var stats: Stats = null

var _current_anim: String = ""
var _facing: float = 1.0
var _scale_x: float = 1.0

@onready var spine: SpineSprite3D = $SpineSprite3D
@onready var state_machine: StateMachine = $StateMachine
@onready var initial_state: State = $StateMachine/IdleState
@onready var idle_state: PlayerIdleState = $StateMachine/IdleState
@onready var move_state: PlayerMoveState = $StateMachine/MoveState
@onready var hud: Hud = $Hud


## Registers the player, starts the state machine and prepares health.
func _ready() -> void:
	add_to_group("player")
	state_machine.init(self, initial_state)
	if health:
		# Duplicate so each instance owns its own pool instead of sharing one.
		health = health.duplicate()
		health.value_changed.connect(_on_health_changed)
		hud.setup_health(health)
	_print_stats()


## Drives the state machine and the facing interpolation each physics frame.
func _physics_process(delta: float) -> void:
	state_machine.physics_update()
	_update_facing(delta)


## Handles test keys: 1/2 change health, P prints stats.
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key_event: InputEventKey = event as InputEventKey

	if key_event.keycode == KEY_P:
		_print_stats()
		return

	if not health:
		return
	if key_event.keycode == KEY_1 or key_event.keycode == KEY_KP_1:
		health.decrease(10)
	elif key_event.keycode == KEY_2 or key_event.keycode == KEY_KP_2:
		health.increase(10)


## Logs whether health went up or down.
func _on_health_changed(old_value: int, new_value: int, increased: bool) -> void:
	var verb: String = "increased" if increased else "decreased"
	print("%s health %s: %d -> %d" % [name, verb, old_value, new_value])


## Prints the player's stats to validate the Stats resource.
func _print_stats() -> void:
	if stats == null:
		print("%s has no Stats assigned." % name)
		return
	print("%s stats -> HP:%d WIL:%d STR:%d INT:%d DEF:%d LCK:%d SPD:%d" % [
		name, stats.hp, stats.will, stats.strength,
		stats.intelligence, stats.defense, stats.luck, stats.speed])


## Plays an animation, resolving fallbacks and skipping if already playing.
func play_animation(anim_name: String, loop: bool = true) -> void:
	if spine == null:
		return
	var anim_state: SpineAnimationState = spine.get_animation_state()
	if anim_state == null:
		return
	anim_name = _resolve_anim(anim_name)
	if anim_name == "" or anim_name == _current_anim:
		return
	_current_anim = anim_name
	anim_state.set_animation(anim_name, loop, 0)


## Returns the requested animation, or the first available one if missing.
func _resolve_anim(anim_name: String) -> String:
	var data: SpineSkeletonDataResource = spine.get_skeleton_data_res()
	if data == null:
		return ""
	if data.find_animation(anim_name) != null:
		return anim_name
	# This skeleton lacks the requested animation, fall back to the first one.
	var anims: Array = data.get_animations()
	if anims.size() > 0:
		return anims[0].get_name()
	return ""


## Sets the target facing based on horizontal movement.
func face_direction(dir_x: float) -> void:
	if absf(dir_x) < 0.01:
		return
	_facing = -1.0 if dir_x < 0.0 else 1.0


## Smoothly interpolates the sprite scale toward the target facing.
func _update_facing(delta: float) -> void:
	var skeleton: SpineSkeleton = spine.get_skeleton()
	if skeleton == null:
		return
	# Frame-rate independent smoothing; passing through 0 gives a paper flip.
	_scale_x = lerpf(_scale_x, _facing, 1.0 - exp(-turn_speed * delta))
	skeleton.set_scale_x(_scale_x)
