extends Node


onready var sfx_node = $SfxPlayer
onready var music_node = $MusicPlayer

var sfx_walk = preload("res://assets/sfx/sfx_walk.mp3")
var sfx_water_throw = preload("res://assets/sfx/sfx_water_throw.mp3")

var is_game_over = false
var is_game_paused = false

var tutorial_shown = false

var field_amount = 0
var fields_on_fire = 0
var collected_grains = 0

var timer_countdown = 10

func _ready():
	is_game_over = false


func _process(delta):
	if timer_countdown > 0:
		timer_countdown -= (1 * delta)
	elif field_amount < 10:
		is_game_over = true
		
	if is_game_over:
		field_amount = 0

func play_sound(sfx_name):
	match(sfx_name):
		"walk":
			sfx_node.stream = sfx_walk
			sfx_node.play()
		"water_throw":
			sfx_node.stream = sfx_water_throw
			sfx_node.play()

func stop_sound(sfx_name):
	match(sfx_name):
		"walk":
			sfx_node.stream = sfx_walk
			sfx_node.stop()
		"water_throw":
			sfx_node.stream = sfx_water_throw
			sfx_node.stop()

