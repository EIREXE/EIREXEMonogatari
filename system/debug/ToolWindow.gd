extends WindowDialog

func _ready():
	connect("modal_closed", self, "on_modal_closed")
func on_modal_closed():
	queue_free()