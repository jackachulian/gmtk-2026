extends Button

@export var cost_label: Label
@export var audio_player: AudioStreamPlayer
@export var normal_color: Color = Color("#fcffde")
@export var broke_color: Color = Color("#e04646")

func _physics_process(_delta: float) -> void:
	cost_label.text = "$%d" % RunManager.run.reroll_price
	cost_label.label_settings.font_color = broke_color if RunManager.run.reroll_price > RunManager.run.cash else normal_color

func _on_pressed() -> void:
	RunManager.run.pay_to_reroll_shop()
	if RunManager.run.reroll_price <= RunManager.run.cash:
		audio_player.play()
