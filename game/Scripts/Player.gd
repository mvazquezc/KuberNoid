extends KinematicBody2D

const MOVE_SPEED = 550
var motion = Vector2(0,0)


func _physics_process(_delta) -> void:
	motion = Vector2(0,0)
	if Input.is_action_pressed("ui_left"):
		motion.x = -MOVE_SPEED
	if Input.is_action_pressed("ui_right"):
		motion.x = MOVE_SPEED
	motion = move_and_slide(motion, Vector2.UP)
