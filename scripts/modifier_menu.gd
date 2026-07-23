class_name ModifierMenu
extends Control

static var instance: ModifierMenu

func _ready() -> void:
	visible = RunManager.run.phase == Run.Phase.CHOOSE_MODIFIER
	RunManager.run.phase_changed.connect(_on_phase_changed)

func _on_phase_changed() -> void:
	visible = RunManager.run.phase == Run.Phase.CHOOSE_MODIFIER
