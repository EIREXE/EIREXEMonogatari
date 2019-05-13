extends Control

const font = preload("res://system/fonts/RobotoSlabRegular-22.tres")
const theme_s = preload("res://system/theme.tres")
const main_menu_scene = preload("res://system/menus/main_menu.tscn")
onready var language_container = get_node("LanguageContainer")

func add_option(locale):
	var button := Button.new()
	button.text = TranslationServer.get_locale_name(locale)
	button.theme = theme_s
	language_container.add_child(button)
	button.add_font_override("font", font)
	button.connect("pressed", self, "on_locale_selected", [locale])
	
func on_locale_selected(locale: String):
	GameManager.user_settings.locale = locale
	GameManager.save_user_settings()
	TranslationServer.set_locale(locale)
	GameManager.change_scene_to(main_menu_scene)
	
func _ready():
	for locale in GameManager.game.game_info.supported_languages:
		add_option(locale)