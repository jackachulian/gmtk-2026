class_name CountdownTimer
extends Node

@export var time_label: Label
@export var normal_color: Color = Color.WHITE
@export var danger_color: Color = Color.RED

func _ready() -> void:
	time_label.text = format_time(RunManager.run.time)
	time_label.label_settings.font_color = normal_color if RunManager.run.time > 10 else danger_color

func _physics_process(_delta: float) -> void:
	time_label.text = format_time(RunManager.run.time)
	time_label.label_settings.font_color = normal_color if RunManager.run.time > 10 else danger_color
	
static func format_time(total_seconds: int) -> String:
	total_seconds = max(total_seconds, 0)

	@warning_ignore("integer_division")
	var days := total_seconds / 86400
	@warning_ignore("integer_division")
	var hours := (total_seconds % 86400) / 3600
	@warning_ignore("integer_division")
	var minutes := (total_seconds % 3600) / 60
	var seconds := total_seconds % 60

	if days > 0:
		return "%d:%02d:%02d:%02d" % [days, hours, minutes, seconds]
	elif hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	else:
		return "%02d:%02d" % [minutes, seconds]
