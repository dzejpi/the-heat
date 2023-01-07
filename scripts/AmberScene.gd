extends KinematicBody


var on_way_to_set_fire = false
var on_move = true
var start_area = null
var is_start_area_set = false
var fire_out_timer = 6
#var speed = 4
#var global_direction = Vector3(0, 0, 1)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if on_move:
		self.global_transform.origin.x += (2 * delta)
	else:
		if fire_out_timer > 0:
			fire_out_timer -= (1 * delta)
		else:
			queue_free()


func _on_Area_area_entered(area):
	print("Ember entered: " + String(area.name))
	
	if !is_start_area_set:
		start_area = area
		on_move = true
		is_start_area_set = true
		
	if area != start_area:
		on_move = false
