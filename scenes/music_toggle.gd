extends CheckButton

@export var source: AudioStreamPlayer

func _toggled(toggled_on: bool) -> void:
	source.volume_db = (4 if toggled_on else -100)
