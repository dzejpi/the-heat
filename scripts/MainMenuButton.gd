extends TextureButton


# var a = 2


func _ready():
	pass


func _process(_delta):
	pass


func _on_MainMenuButton_pressed():
	GlobalVar.stop_music()
	GlobalVar.play_sound("button_confirm")
	get_tree().change_scene("res://scenes/MainMenuScene.tscn")
