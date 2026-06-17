class_name Hud
extends CanvasLayer
## HUD that mirrors the player's health on a ProgressBar.


@onready var health_bar: ProgressBar = %HealthBar


## Binds the bar to a StatPool and does the first sync.
func setup_health(pool: StatPool) -> void:
	pool.value_changed.connect(_on_health_changed)
	health_bar.min_value = pool.get_min_value()
	health_bar.max_value = pool.get_max_value()
	health_bar.value = pool.get_value()


## Updates the bar whenever the health changes.
func _on_health_changed(_old_value: int, new_value: int, _increased: bool) -> void:
	health_bar.value = new_value
