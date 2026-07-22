class_name CountdownTimer
extends Node

@export var time_label: Label

#var reset_time: int = 600
#
### Time remaining on the timer, in seconds
#var time: int
#
### The delay between ticks, in real-world seconds
#var tick_time: float = 0.25
#
### Counts how much real-world seconds until the next tick
#var tick_time_remaining: float

func _physics_process(_delta: float) -> void:
	time_label.text = format_time(RunManager.run.time)
	
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
