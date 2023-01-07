extends Area


export var health = 100
export var is_burning = false
export var is_damaged = false
export var is_burned = false
export var is_harvested = false
export var burn_rate = 8


onready var plant_sprite = $SorghumPlantSprite
onready var plant_fire_sprite = $SorghumFireSprite

var healthy_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_fresh.png")
var harvested_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_harvested.png")
var damaged_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_damaged.png")
var burned_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_burned.png")


func _ready():
	update_crop_sprite()
	GlobalVar.field_amount += 1


func _process(delta):
	if is_burning && !is_burned:
		manage_fire(delta)


func manage_fire(delta):
	if is_burning:
		health -= (burn_rate * delta)
		if health <= 0:
			is_burned = true
			is_burning = false
			GlobalVar.field_amount -= 1
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
