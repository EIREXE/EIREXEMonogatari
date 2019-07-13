extends Control

export(PackedScene) var next_scene

func _ready():
	$AnimationPlayer.play("fade_in_out")
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
	
func _on_animation_finished(animation):
	next_scene()
	
func _input(event):
	if event.is_action_pressed("skip_text") and not event.is_echo():
		get_tree().set_input_as_handled()
		next_scene()
	
func next_scene():
	if next_scene:
		GameManager.set_node_as_current_scene(next_scene.instance())