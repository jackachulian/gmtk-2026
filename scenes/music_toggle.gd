extends CheckButton

func _toggled(toggled_on: bool) -> void:
	MusicPlayer.volume_db = (4 if toggled_on else -100)
