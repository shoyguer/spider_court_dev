class_name BaseEnemy
extends CharacterBody3D
## Base class for every enemy. Handles vision, animation, facing and clicks.


## Speed used while wandering idly.
@export var wander_speed: float = 1.5
## Minimum seconds before picking a new wander direction.
@export var wander_change_min: float = 1.0
## Maximum seconds before picking a new wander direction.
@export var wander_change_max: float = 3.0
## Distance at which the enemy notices the player.
@export var aggro_range: float = 6.0
## Distance at which the enemy enters combat.
@export var combat_range: float = 1.5
## Speed used while chasing the player.
@export var speed: float = 3.0
## How fast the sprite flips when changing direction.
@export var turn_speed: float = 12.0
## Health pool of this enemy.
@export var health: StatPool = null

var combat_target: Player = null
var _current_anim: String = ""
var _facing: float = 1.0
var _scale_x: float = 1.0
var enemy_name: String = "Enemy"
var idle_anim: String = "idle"
var walk_anim: String = "walk"
var combat_anim: String = "combat"

@onready var spine: SpineSprite3D = $SpineSprite3D
@onready var state_machine: StateMachine = $StateMachine
@onready var initial_state: State = $StateMachine/IdleState
@onready var idle_state: EnemyIdleState = $StateMachine/IdleState
@onready var chase_state: EnemyChaseState = $StateMachine/ChaseState
@onready var combat_state: EnemyCombatState = $StateMachine/CombatState
@onready var wander_timer: Timer = $WanderTimer


## Registers the enemy, starts the state machine and hooks health changes.
func _ready() -> void:
	add_to_group("enemy")
	state_machine.init(self, initial_state)
	if health:
		# Duplicate so each instance owns its own pool instead of sharing one.
		health = health.duplicate()
		health.value_changed.connect(_on_health_changed)


## Drives the state machine and the facing interpolation each physics frame.
func _physics_process(delta: float) -> void:
	state_machine.physics_update()
	_update_facing(delta)


## Adjusts health with keys 1 (decrease) and 2 (increase) for testing.
func _unhandled_input(event: InputEvent) -> void:
	if not health: return
	
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_1:
			health.decrease(10)
		elif key_event.keycode == KEY_2:
			health.increase(10)


## Logs whether health went up or down.
func _on_health_changed(old_value: int, new_value: int, increased: bool) -> void:
	var verb: String = "increased" if increased else "decreased"
	print("%s health %s: %d -> %d" % [enemy_name, verb, old_value, new_value])


## Plays an animation, resolving fallbacks and skipping if already playing.
func play_animation(anim_name: String, loop: bool = true) -> void:
	if not spine: return
	
	var anim_state: SpineAnimationState = spine.get_animation_state()
	
	if not anim_state: return
	anim_name = _resolve_anim(anim_name)
	
	if anim_name == "" or anim_name == _current_anim: return
	_current_anim = anim_name
	anim_state.set_animation(anim_name, loop, 0)


## Returns the requested animation, or the first available one if missing.
func _resolve_anim(anim_name: String) -> String:
	var data: SpineSkeletonDataResource = spine.get_skeleton_data_res()
	if not data: return ""
	
	if data.find_animation(anim_name):
		return anim_name
	# This skeleton lacks the requested animation, fall back to the first one.
	var anims: Array = data.get_animations()
	
	if anims.size() > 0:
		return anims[0].get_name()
	return ""


## Sets the target facing based on horizontal movement.
func face_direction(dir_x: float) -> void:
	if absf(dir_x) < 0.01: return
	_facing = -1.0 if dir_x < 0.0 else 1.0


## Smoothly interpolates the sprite scale toward the target facing.
func _update_facing(delta: float) -> void:
	var skeleton: SpineSkeleton = spine.get_skeleton()
	
	if not skeleton: return
	# Frame-rate independent smoothing; passing through 0 gives a paper flip.
	_scale_x = lerpf(_scale_x, _facing, 1.0 - exp(-turn_speed * delta))
	skeleton.set_scale_x(_scale_x)


## Enters combat when the player left-clicks this enemy.
func _on_clickable_area_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape: int) -> void:
	if not event is InputEventMouseButton: return
	
	var mb: InputEventMouseButton = event as InputEventMouseButton
	
	if not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT: return
	
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	
	if not player: return
	combat_target = player
	state_machine.change_state(combat_state)
	get_viewport().set_input_as_handled()
