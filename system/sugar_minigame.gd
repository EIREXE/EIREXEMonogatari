extends Node

class_name SugarMinigame

onready var game = GameManager.game

func _ready():
	# Ensure game is shown, for debugging within the editor
	game.show()
	game.vn.show()
	game.vn.tie.hide()
	game.vn.tie.hide_buttons()
	game.vn.connect("scene_finished", self, "_on_scene_finished")
func _on_scene_finished():
	game.vn.tie.hide()
func play_random_subscene_from_file(path: String):
	play_random_subscene(SJSON.from_file(path))
func play_random_subscene(scene: Dictionary):
	game.vn.tie.show()
	var scene_start = 0
	
	var found_subscenes = []
	
	for i in range(scene.lines.size()):
		var line = scene.lines[i]
		if line.__format == "random_end":
			# We intentionally leave the random_end out, although this isn't really necessary...
			found_subscenes.append(get_subscene(scene_start, i-1, scene))
			scene_start = i + 1
	game.run_vn_scene(found_subscenes[randi() % found_subscenes.size()])
func get_subscene(start: int, end: int, scene: Dictionary):
	var subscene = SJSON.get_format_defaults("scene")
	for i in range(start, end+1):
		subscene.lines.append(scene.lines[i])
	return subscene