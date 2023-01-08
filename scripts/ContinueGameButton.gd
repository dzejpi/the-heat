extends TextureButton


#func _ready():
#	pass


#func _process(delta):
#	pass



func _on_ContinueGameButton_pressed():
	GlobalVar.play_sound("button_confirm")
	get_parent().is_game_paused = false
	GlobalVar.is_game_paused = false
	get_parent().update_pause_state()
