extends Node2D


var is_game_over = true

onready var crops_harvested_label = $StatusLabels/CropsHarvestedLabel
onready var days_left_label = $StatusLabels/DaysLeftLabel


func _ready():
	update_game_over_state()


func _process(_delta):
	if !is_game_over:
		if GlobalVar.is_game_over:
			update_game_over_state()


func update_game_over_state():
	is_game_over = GlobalVar.is_game_over
	
	crops_harvested_label.text = "Crops harvested: " + String(GlobalVar.collected_grains) + " (" + String(GlobalVar.collected_grains * 0.25) + " kg)."
	days_left_label.text = "It all ends in " + String(GlobalVar.collected_grains * 0.125) + " days."
	
	if is_game_over:
		visible = true
	else:
		visible = false
