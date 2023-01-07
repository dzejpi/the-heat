extends StaticBody


onready var grain_mill_crops = $blend_grain_mill_crops
var is_being_loaded = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass

func load_grain_mill():
	raise_mill_crops()
	GlobalVar.collected_grains += 1
	

func raise_mill_crops():
	grain_mill_crops.global_transform.origin.y += 0.003
