extends KinematicBody


var on_way_to_set_fire = false
var on_move = true
var start_area = null
var is_start_area_set = false
var fire_out_timer = 6
var speed = 3
var global_direction = Vector3(0, 0, 1)


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation.y = rand_range(1, 359)


func _process(delta):
	if on_move:
		if self.global_transform.origin.y <= 0.25:
			on_move = false
		else:
			var local_direction = global_direction.rotated(Vector3(0, 1, 0), rotation.y)
			var velocity = local_direction * speed
			move_and_slide(velocity)
			self.global_transform.origin.y -= (0.25 * delta)
	else:
		self.global_transform.origin.y -= (0.25 * delta)
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
