extends Node


onready var sfx_node = $SfxPlayer
onready var music_node = $MusicPlayer

var is_game_over = true
var is_game_paused = false

var field_amount = 0
var fields_on_fire = 0
var collected_grains = 0

#func _ready():
#	pass


#func _process(delta):
#	pass
