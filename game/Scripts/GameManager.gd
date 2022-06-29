extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var bricks_node_path : NodePath
onready var bricks_node = get_node(bricks_node_path)

onready var brick_scene=preload("res://Scenes/Brick.tscn")

const max_bricks_per_row = 11 
const brick_width = 32
const brick_heigh = 16

var bricks_in_game : int

var brick_data = ""
# We can generate custom signals
signal bricks_generated

func get_bricks():
	print("getting bricks")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "process_bricks")

	var error = http_request.request(GameOptions.pod_lister_url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func process_bricks(_result, _response_code, _headers, body):
	print("request completed")
	var bricks_in_data = 0
	var response = JSON.parse(body.get_string_from_utf8())
	brick_data = response.result
	if brick_data != null and brick_data["pods"] != null:
		bricks_in_data = len(brick_data["pods"])
	else:
		print("bricks not received")
	# We initialize generated_bricks to 0, this will be the counter for Y axys used by positioning
	var generated_bricks = 0
	# We start creating bricks at Y 355
	var starting_row = 42
	# We start creating bricks at X 16
	var starting_column = 16
	
	# We may need to create fake bricks
	var required_bricks = 0
	# For the number of bricks we got we iterate over them
	if bricks_in_data < bricks_in_game:
		# We need to add bricks to the game
		required_bricks = bricks_in_game - bricks_in_data

	for i in range(bricks_in_game):
		var brick = brick_scene.instance()
		# We want fake bricks to be position before the real bricks
		if i >= required_bricks:
			# Here we add the blue animation to the non-fake bricks
			var animated_sprite = brick.find_node("AnimatedSprite")
			animated_sprite.play("blue")
			var brick_namespace = brick_data["pods"][i-required_bricks]["namespace"]
			var brick_podname = brick_data["pods"][i-required_bricks]["pod"]
			brick.set_meta("namespace", brick_namespace)
			brick.set_meta("podname", brick_podname)
			### TODO: Add metadata to the brick
			### Probar que pasa cuando no obtiene datos del server
			

		# If we filled the row we need to continue in the next one
		if generated_bricks >= max_bricks_per_row:
			# We initialize the generated_bricks back to 0
			generated_bricks = 0
			# We increase the Y axis by the heigh of the brick (16px)
			starting_row = starting_row+brick_heigh
		# We position the brick on the coordinates we calculated
		brick.position = Vector2(starting_column+generated_bricks*brick_width,starting_row)
		bricks_node.add_child(brick)
		generated_bricks += 1
		#print(brick_data["pods"][i])
	# Emit custom signal
	emit_signal("bricks_generated")
	# Start process function
	set_process(true)



# Called when the node enters the scene tree for the first time.
func _ready():
	# 88 bricks - extra hard
	# 44 bricks - hard
	# 22 bricks - normal
	
	if GameOptions.difficulty == 1:
		bricks_in_game = 22
	elif GameOptions.difficulty == 2:
		bricks_in_game = 44
	else:
		bricks_in_game = 88
	# Pause process until we get bricks
	set_process(false)
	get_bricks()
	
	
func _process(_delta):
	# we can wait until a signal is generated yield(self, "bricks_generated")
	#yield(get_tree().create_timer(2.0), "timeout")
	var remaining_bricks = bricks_node.get_child_count()
	if remaining_bricks == 0:
		GameOptions.game_win = true
		print("Win!")
		GameOptions.load_scene("res://Scenes/GameFinished.tscn")

