extends Area


export var health = 100
export var is_burning = false
export var is_damaged = false
export var is_burned = false
export var is_harvested = false
export var burn_rate = 4

onready var plant_sprite = $SorghumPlantSprite
onready var plant_fire_sprite = $SorghumFireSprite
onready var destroyed_ground = $DestroyedGround

var healthy_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_fresh.png")
var harvested_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_harvested.png")
var damaged_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_damaged.png")
var burned_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_burned.png")

var current_status = "healthy"


func _ready():
	update_crop_sprite()
	GlobalVar.field_amount += 1
	destroyed_ground.hide()


func _process(delta):
	if is_burning && !is_burned:
		manage_fire(delta)


func manage_fire(delta):
	if is_burning:
		health -= (burn_rate * delta)
		if health <= 0:
			health = 0
			is_burned = true
			is_burning = false
			GlobalVar.field_amount -= 1
			print("Fields left: " + String(GlobalVar.field_amount))
			update_crop_sprite()
	if !is_damaged:
		if health < 50:
			is_damaged = true
			update_crop_sprite()


func update_crop_sprite():
	if is_burned:
		plant_sprite.texture = burned_plant_sprite
		change_fire_animation()
	elif is_harvested:
		plant_sprite.texture = harvested_plant_sprite
		change_fire_animation()
	elif is_damaged:
		plant_sprite.texture = damaged_plant_sprite
		change_fire_animation()
	else:
		plant_sprite.texture = healthy_plant_sprite
		change_fire_animation() 


func change_fire_animation():
	if is_burned or is_harvested:
		plant_fire_sprite.animation = "no_animation"
	elif is_burning:
		if !is_damaged:
			plant_fire_sprite.play("crop_small_fire")
		else:
			plant_fire_sprite.play("crop_big_fire")
	else:
		plant_fire_sprite.animation = "no_animation"


func get_health():
	return health


func get_crop_status():
	if is_burning:
		current_status = "burning"
	elif is_damaged:
		current_status = "damaged"
	elif is_burned:
		current_status = "destroyed"
	else:
		current_status = "healthy"
	
	return current_status


func extinguish_fire():
	is_burning = false
	change_fire_animation()


func check_fire_status():
	return is_burning


func check_harvestability():
	if is_burned:
		return false
	else:
		return true


func harvest_crop():
	is_harvested = true
	update_crop_sprite()
	GlobalVar.field_amount -= 1
	print("Fields left: " + String(GlobalVar.field_amount))


func destroy_crop():
	destroyed_ground.show()
	plant_sprite.hide()
	plant_fire_sprite.hide()
	
	is_burned = true
