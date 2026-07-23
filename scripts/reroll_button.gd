extends Button

@export var cost_label: Label

func _physics_process(_delta: float) -> void:
	cost_label.text = "$%d" % RunManager.run.reroll_price

func _on_pressed() -> void:
	RunManager.run.pay_to_reroll_shop()
