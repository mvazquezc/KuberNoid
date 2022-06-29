extends Node

export var empty_heart_texture : Texture
export var canvas_layer_path : NodePath

onready var canvas_layer = get_node(canvas_layer_path)

var lifes = 3
var ball_start_position = Vector2(169, 561)
var ball_start_linear_velocity = Vector2(0, 0)

func _on_Area2D_body_entered(body):
	if body.is_in_group("ball"):
		if lifes >= 2:	
			var cl = canvas_layer.get_node("Life" + str(lifes))
			cl.texture = empty_heart_texture
			# Below line depends on canvas order, so it's better to get the node by name
			#canvas_layer.get_child(lifes-1).texture = empty_heart_texture
			body.reposition_ball()
			lifes -= 1
		else:
			GameOptions.game_win = false
			print("game over")
			GameOptions.load_scene("res://Scenes/GameFinished.tscn")

