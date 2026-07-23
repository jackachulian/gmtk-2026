class_name PauseMenu
extends Control

static var instance: PauseMenu

func _enter_tree() -> void:
	instance = self
	hide()

func pause() -> void:
	RunManager.paused = true
	show()
	
func unpause() -> void:
	RunManager.paused = false
	hide()

func _on_resume_button_pressed() -> void:
	unpause()
	
func _on_new_run_button_pressed() -> void:
	pass
