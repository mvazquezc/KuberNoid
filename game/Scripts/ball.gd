extends RigidBody2D

export var ball_green_sprite : Texture 
export var ball_red_sprite : Texture
export var score_label_path : NodePath
export var start_label_path : NodePath

onready var score_label = get_node(score_label_path)
onready var start_label = get_node(start_label_path)
export var paddle_path : NodePath

onready var paddle = get_node(paddle_path)

const paddle_speed_up = 30
const max_speed = 30000
const wall_speed_up = 20
var change_texture = false

var ball_launched = false
var rng = RandomNumberGenerator.new()

func reposition_ball() -> void:
	var ball_start_position = Vector2(169, 561)
	var ball_start_linear_velocity = Vector2(0, 0)
	set_linear_velocity(ball_start_linear_velocity)
	set_position(ball_start_position)
	ball_launched = false

func _ready() -> void:
	mode = RigidBody2D.MODE_CHARACTER
	# Ball has a physic material that makes it bounce and don't have friction
	gravity_scale = 0.0
	linear_damp = 0.0
	angular_damp = 0.0
	linear_velocity = Vector2(0, 0)
	score_label.text = "00000"

func _process(_delta):
	if !ball_launched:
		# We want the ball to follow the paddle when the ball has not been launched
		# First, we get the paddle position
		var paddle_position = paddle.position
		# Next we create a Vector2 for the ball position from the paddle
		var ball_position = Vector2(0, -15)
		# We aggregate the two values and that will give us the position for the ball
		var reposition_ball = paddle_position + ball_position
		# We modify the position for the ball
		position = reposition_ball
		
	if !ball_launched and Input.is_action_pressed("ui_accept"):
		print("ball launched")
		start_label.visible = false
		var random_number = rng.randf_range(0, 10)
		linear_velocity = Vector2(250, -250)
		# Launch ball to the left
		if random_number <= 5:
			linear_velocity = Vector2(-250, 250)
		ball_launched = true
		# Reset pitch
		$AudioStreamPlayer.pitch_scale = 1.0
	


func _on_Ball_body_entered(body):
	# In order for this to work, ball rigibody needs to have contacts reported and contact monitor
	# properties set to 1 and on respectively
	$AudioStreamPlayer.play()
	$AudioStreamPlayer.stop()
	if body.is_in_group("brick"):
		#body.destroy_brick()
		body.delete_brick()
		# Increase score
		GameOptions.score = int(score_label.text) + 1 * 10333
		score_label.text = str(GameOptions.score)

	if body.is_in_group("player"):
		# This code changes the texture every time the ball hits the paddle
		#change_texture = !change_texture
		#if change_texture:
		#	$Sprite.texture = ball_red_sprite
		#else:
		#	$Sprite.texture = ball_green_sprite
		# Speed up the ball
		var speed = get_linear_velocity().length()
		var direction = position - body.get_node("BodyCollision").get_global_position()
		var velocity = direction.normalized()*min(speed+paddle_speed_up, max_speed)
		# TODO: Check angle with velocity and avoid ball angle less than 60 degrees
		#print(get_linear_velocity())
		#print(velocity)
		set_linear_velocity(velocity)
		$AudioStreamPlayer.pitch_scale += 0.005


# If the ball goes out of the screen we relocate it
func _on_VisibilityNotifier2D_screen_exited():
	var ball_start_position = Vector2(169, 561)
	var ball_start_linear_velocity = Vector2(0, 0)
	self.set_linear_velocity(ball_start_linear_velocity)
	self.set_position(ball_start_position)
	ball_launched = false
	print("Ball relocated")

