extends Node


onready var sfx_node = $SfxPlayer
onready var music_node = $MusicPlayer

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
