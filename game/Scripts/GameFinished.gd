extends Control

export var score_label_path : NodePath
onready var score_label = get_node(score_label_path)
export var result_label_path : NodePath
onready var result_label = get_node(result_label_path)


func _ready():
	score_label.text = "Score " + str(GameOptions.score)
	var result = "Lose"
	if GameOptions.game_win:
		result = "Win"
	result_label.text = "You " + result

func _on_PlayAgain_pressed():
	GameOptions.load_scene("res://Scenes/World.tscn")


func _on_MainMenu_pressed():
	GameOptions.load_scene("res://Scenes/MainMenu.tscn")


func _on_Exit_pressed():
	get_tree().quit()
