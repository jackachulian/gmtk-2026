extends Button

@export var cost_label: Label
@export var audio_player: AudioStreamPlayer

func _physics_process(_delta: float) -> void:
	cost_label.text = "$%d" % RunManager.run.reroll_price

func _on_pressed() -> void:
	RunManager.run.pay_to_reroll_shop()
	if RunManager.run.reroll_price <= RunManager.run.cash:
		audio_player.play()
