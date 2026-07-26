extends Control

@export var lost_sfx: AudioStreamPlayer

func _ready() -> void:
	visible = (RunManager.run.phase == Run.Phase.GAME_LOST)

func _physics_process(_delta: float) -> void:
	if RunManager.run.phase == Run.Phase.GAME_LOST:
		if (!is_visible_in_tree()): lost_sfx.play()
		show()
		

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
