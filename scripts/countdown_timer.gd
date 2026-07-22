class_name CountdownTimer
extends Node

@export var time_label: Label

var reset_time: int = 600

## Time remaining on the timer, in seconds
var time: int

## The delay between ticks, in real-world seconds
var tick_time: float = 0.25

## Counts how much real-world seconds until the next tick
var tick_time_remaining: float

signal finished()

func _ready() -> void:
	tick_time_remaining = tick_time

func _physics_process(delta: float) -> void:
	tick_time_remaining -= delta
	while tick_time_remaining < 0:
		tick_time_remaining += tick_time
		count_down()

func count_down() -> void:
	time -= 1
	if time <= 0:
		time = reset_time
		finished.emit()
	update_ui()
	
func update_ui() -> void:
	time_label.text = format_time(time)
	
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
