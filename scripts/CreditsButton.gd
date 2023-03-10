extends TextureButton


var time_out = 0
var button_pressed = false
onready var transition_overlay_sprite = $"../../TransitionOverlay/TransitionSprite"


func _ready():
	pass


func _process(delta):
	if button_pressed:
		if time_out < 1:
			time_out += (2 * delta)
			transition_overlay_sprite.modulate.a = time_out
		else:
			get_tree().change_scene("res://scenes/CreditsScene.tscn")


func _on_CreditsButton_pressed():
	GlobalVar.play_sound("button_confirm")
	button_pressed = true
