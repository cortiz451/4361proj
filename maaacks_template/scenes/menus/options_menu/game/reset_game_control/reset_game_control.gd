extends HBoxContainer

const RESET_STRING := "Reset Game:"
const CONFIRM_STRING := "Confirm Reset:"

signal diff(d: int)

func _on_h_slider_value_changed(value: float) -> void:
	var d=int(value)
	diff.emit(d)
