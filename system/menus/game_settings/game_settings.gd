extends MarginContainer
onready var options_container = get_node("ScrollContainer/VBoxContainer")
func _ready():
	for option in options_container.get_children():
		if option.user_settings_key_name in GameManager.user_settings:
			option.value = GameManager.user_settings[option.user_settings_key_name]
			option.connect("value_changed", self, "_on_value_changed", [option.user_settings_key_name])

func _on_value_changed(new_value, user_settings_key_name):
	GameManager.user_settings[user_settings_key_name] = new_value
	
func _submenu_back():
	GameManager.save_user_settings()