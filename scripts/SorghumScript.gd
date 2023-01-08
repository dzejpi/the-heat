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

onready var sorg_audio_player = $SorghumAudioStreamPlayer

onready var amber_scene = preload("res://scenes/AmberScene.tscn")

var healthy_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_fresh.png")
var harvested_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_harvested.png")
var damaged_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_damaged.png")
var burned_plant_sprite = preload("res://assets/visual/crops/ase_crops_sorghum_burned.png")

var crop_counted = false
var current_status = "healthy"
var amber_timeout = 2
var amber_current_timeout = amber_timeout

var is_audio_playing = false


func _ready():
	update_crop_sprite()
	destroyed_ground.hide()


func _process(delta):
	if is_burning && !is_burned:
		manage_fire(delta)
	
	if !crop_counted:
		GlobalVar.field_amount += 1
		crop_counted = true
		
	check_fields_on_fire()


func manage_fire(delta):
	if is_burning:
		if !is_audio_playing:
			is_audio_playing = true
			sorg_audio_player.play()
		
		health -= (burn_rate * delta)
		
		if health < 50:
			if amber_current_timeout > 0:
				amber_current_timeout -= (1 * delta)
			else:
				spawn_amber()
				amber_current_timeout = amber_timeout
		
		if health <= 0:
			health = 0
			if !is_burned:
				GlobalVar.field_amount -= 1
				GlobalVar.fields_on_fire -= 1
			is_burned = true
			sorg_audio_player.stop()
			is_burning = false
			
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
	if is_burning:
		GlobalVar.fields_on_fire -= 1
		sorg_audio_player.stop()
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
	if !is_harvested:
		GlobalVar.field_amount -= 1
	is_harvested = true
	update_crop_sprite()
	print("Fields left: " + String(GlobalVar.field_amount))


func destroy_crop():
	destroyed_ground.show()
	plant_sprite.hide()
	plant_fire_sprite.hide()
	
	if !is_burned:
		if !is_harvested:
			GlobalVar.field_amount -= 1
			GlobalVar.fields_on_fire -= 1
			sorg_audio_player.stop()
	is_burned = true


func _on_Sorghum_body_entered(body):
	print("Body " + body.name + "entered crop.")
	
	if body.name != "Player":
		if !is_burning:
			GlobalVar.fields_on_fire += 1
		is_burning = true
		update_crop_sprite()


func spawn_amber():
	var amber_instance = amber_scene.instance()
	add_child(amber_instance)
	amber_instance.global_transform.origin.x = self.global_transform.origin.x
	amber_instance.global_transform.origin.y = 2
	amber_instance.global_transform.origin.z = self.global_transform.origin.z


func check_fields_on_fire():
	if GlobalVar.fields_on_fire < 2:
		var randomNumber = randi() % 101 + 1
		if randomNumber == 1:
			if !is_burning:
				GlobalVar.fields_on_fire += 1
			is_burning = true
			update_crop_sprite()
