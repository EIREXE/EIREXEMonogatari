extends WindowDialog

func _ready():
	resizable = true
	connect("modal_closed", self, "_on_modal_closed")
func _on_modal_closed() -> void:
	queue_free()