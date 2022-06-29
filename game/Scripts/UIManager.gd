extends CanvasLayer

export var sound_sprite : Texture 
export var nosound_sprite : Texture

func _ready():
	if GameOptions.sound_muted:
		$Button.texture_normal = nosound_sprite
	else:
		$Button.texture_normal = sound_sprite

func _on_Button_pressed():
	if GameOptions.sound_muted:
		print("unmute")
		$Button.texture_normal = sound_sprite
		var master_sound = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(master_sound, false)
	else:
		print("mute")
		$Button.texture_normal = nosound_sprite
		var master_sound = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(master_sound, true)
	GameOptions.sound_muted = !GameOptions.sound_muted
	
