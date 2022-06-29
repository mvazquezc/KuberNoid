extends Node

var sound_muted = false
var difficulty = 1

var pod_lister_url : String
var game_win : bool
var score : float

func load_scene(scene: String) -> void:
	var result = get_tree().change_scene(scene)
	if result != 0:
		print("Error loading scene: ", result)
