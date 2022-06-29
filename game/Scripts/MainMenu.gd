extends Control

func _ready():
	
	if OS.get_name() == "HTML5":
		var file = File.new()
		file.open("res://podlister.url", File.READ)
		GameOptions.pod_lister_url = file.get_as_text()
		file.close()
		print("Pod Lister URL: " + GameOptions.pod_lister_url)
	else:
		GameOptions.pod_lister_url = "http://127.0.0.1:9000"
		print("Pod Lister URL: " + GameOptions.pod_lister_url)

func _on_NewGame_pressed():
	GameOptions.load_scene("res://Scenes/World.tscn")


func _on_Credits_pressed():
	GameOptions.load_scene("res://Scenes/Credits.tscn")


func _on_Exit_pressed():
	get_tree().quit()


func _on_DifficultySelector_value_changed(value):
	GameOptions.difficulty = value
	print("Difficulty set to " + str(value))
