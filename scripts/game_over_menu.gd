extends Control

func _ready() -> void:
	visible = (RunManager.run.phase == Run.Phase.GAME_LOST)

func _physics_process(_delta: float) -> void:
	if RunManager.run.phase == Run.Phase.GAME_LOST:
		show()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
