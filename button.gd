extends Button


func _on_button_down() -> void:
	SignalBus.StartGame.emit()
