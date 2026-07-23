class_name RoundInfoPanel
extends PanelContainer

@export var round_number_label: Label
@export var round_progess_bar: ProgressBar
@export var tick_rate_label: Label
@export var tick_amount_label: Label

func _ready() -> void:
	round_progess_bar.max_value = Run.ROUND_DURATION

func _physics_process(_delta: float) -> void:
	var run := RunManager.run
	round_number_label.text = "Round %d" % run.round_number
	round_progess_bar.value = (Run.ROUND_DURATION - run.round_timer)
	tick_rate_label.text = "Tick Rate: %s" % str(run.tick_rate).trim_suffix(".0").trim_suffix("0")
	tick_amount_label.text = "-%d %s per tick" % [run.tick_amount, "second" if run.tick_amount == 1 else "seconds"]
