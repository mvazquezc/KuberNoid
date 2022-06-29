extends Control


func _ready():
	pass


func _on_Breakout_Assets_pressed():
	OS.shell_open("https://megacrash.itch.io/breakout-assets")


func _on_Sound_Effects_Assets_pressed():
	OS.shell_open("https://opengameart.org/content/8-bit-retro-sfx")


func _on_Font_Asset_pressed():
	OS.shell_open("https://www.dafont.com/es/8-bit-arcade.font")


func _on_Icons_Assets_pressed():
	OS.shell_open("https://hugo4it.itch.io/nice-pack")


func _on_Programming_pressed():
	OS.shell_open("https://twitter.com/mvazce")


func _on_Source_pressed():
	OS.shell_open("https://github.com/mvazquezc/kubernoid")


func _on_Go_Back_pressed():
	GameOptions.load_scene("res://Scenes/MainMenu.tscn")
