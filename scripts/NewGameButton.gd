extends TextureButton


var time_out = 0
var button_pressed = false
onready var transition_overlay_sprite = $"../../TransitionOverlay/TransitionSprite"


func _ready():
	pass


func _process(delta):
	if button_pressed:
		
		GlobalVar.is_game_paused = false
		GlobalVar.is_game_over = false
		GlobalVar.field_amount = 0
		GlobalVar.fields_on_fire = 0
		GlobalVar.collected_grains = 0
		GlobalVar.timer_countdown = 10
			
		if time_out < 1:
				time_out += (2 * delta)
				transition_overlay_sprite.modulate.a = time_out
		else:
			get_tree().change_scene("res://scenes/GameSceneOne.tscn")


func _on_NewGameButton_pressed():
	GlobalVar.play_sound("button_confirm")
	GlobalVar.play_music()
	button_pressed = true
