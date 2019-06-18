extends Control

onready var language_container = get_node("LanguageContainer")

func add_option(locale):
	var button := Button.new()
	button.text = TranslationServer.get_locale_name(locale)
	language_container.add_child(button)
	button.connect("pressed", self, "on_locale_selected", [locale])
	
func on_locale_selected(locale: String):
	GameManager.user_settings.locale = locale
	GameManager.save_user_settings()
	TranslationServer.set_locale(locale)
	
func _ready():
	for locale in GameManager.game.game_info.supported_languages:
		add_option(locale)