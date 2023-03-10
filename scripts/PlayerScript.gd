extends KinematicBody


# Head
onready var player_head = $PlayerHead
onready var ray = $PlayerHead/RayCast

# Labels
onready var crop_status_label = $UILabels/CropLabels/CropStatusLabel
onready var crop_health_label = $UILabels/CropLabels/CropHealthLabel
onready var carry_status_label = $UILabels/SelectedTools/CarryStatusLabel
onready var tooltip_label = $UILabels/SelectedTools/TooltipLabel
onready var prompt_label = $UILabels/ActionLabel
onready var fields_left_label = $UILabels/TopLabels/CropsLeftLabel

onready var tutorial_label = $TutorialLabel/TutorialLabel
onready var tutorial_node = $TutorialLabel

onready var selected_item_sprite = $PlayerHead/SelectedItemSprite

onready var animation_player = $PlayerHead/PlayerCamera/AnimationPlayer
onready var item_animation_player = $PlayerHead/SelectedItemSprite/ItemAnimationPlayer

onready var player_timer = $PlayerTimer

# Sprites
var selected_item_hands = preload("res://assets/visual/items/spr_empty_hands.png")
var selected_item_sickle = preload("res://assets/visual/items/spr_sickle.png")
var selected_item_bucket_empty = preload("res://assets/visual/items/spr_bucket_empty.png")
var selected_item_bucket_water = preload("res://assets/visual/items/spr_bucket_water.png")
var selected_item_spade = preload("res://assets/visual/items/spr_spade.png")
var selected_item_crops = preload("res://assets/visual/items/spr_harvested_crops.png")

var speed = 8
var jump = 8
var gravity = 16

var ground_acceleration = 8
var air_acceleration = 2
var acceleration = ground_acceleration

var slide_prevention = 10
var mouse_sensitivity = 0.75

var direction = Vector3()
var velocity = Vector3()
var movement = Vector3()
var gravity_vector = Vector3()

var is_on_ground = true
var is_options_menu_displayed = false

# Name of the observed object for debugging purposes
var observed_object = "" 

var is_carrying_crops = false
var is_bucket_empty = true
var carried_object = 1
var tutorial_step = 1
var some_crop_destroyed = false

var is_walking = false
var is_walking_being_played = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crop_status_label.text = ""
	crop_health_label.text = ""
	carry_status_label.text = ""
	tooltip_label.text = ""
	prompt_label.text = ""
	selected_item_sprite.texture = selected_item_hands
	carried_item_change()


func _input(event):
	if !GlobalVar.is_game_over:
		if !GlobalVar.is_game_paused:
			if event is InputEventMouseMotion:
				rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10
				player_head.rotation_degrees.x = clamp(player_head.rotation_degrees.x - event.relative.y * mouse_sensitivity / 10, -90, 90)

			direction = Vector3()
			direction.z = -Input.get_action_strength("move_up") + Input.get_action_strength("move_down")
			direction.x = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
			direction = direction.normalized().rotated(Vector3.UP, rotation.y)
		
			if carried_object != 5:
				if Input.is_action_just_pressed("item_1"):
					carried_object = 1
					carried_item_change()
				if Input.is_action_just_pressed("item_2"):
					carried_object = 2
					carried_item_change()
				if Input.is_action_just_pressed("item_3"):
					carried_object = 3
					carried_item_change()
				if Input.is_action_just_pressed("item_4"):
					carried_object = 4
					carried_item_change()
				if Input.is_action_just_pressed("item_change_up"):
					if carried_object < 4:
						carried_object += 1
					else:
						carried_object = 1
					carried_item_change()
				if Input.is_action_just_pressed("item_change_down"):
					if carried_object > 1:
						carried_object -= 1
					else:
						carried_object = 4
					carried_item_change()
					
			if Input.is_action_pressed("move_up"):
				if !is_walking:
					is_walking = true
					if !is_walking_being_played:
						is_walking_being_played = true
						GlobalVar.play_sound("walk")
			else:
				is_walking = false
				if is_walking_being_played:
					is_walking_being_played = false
					GlobalVar.stop_sound("walk")
		
		# Handling the options menu
		if Input.is_action_just_pressed("ui_cancel"):
			if !GlobalVar.is_game_over:
				if !GlobalVar.is_game_paused:
					GlobalVar.is_game_paused = true
				else:
					GlobalVar.is_game_paused = false
				
		if Input.is_action_just_pressed("game_action"):
			item_animation_player.play("Item Use")
			process_player_action_on_object(observed_object, ray.get_collider())


func _process(delta):
	# Check whether the game is paused and show/hide cursor
	manage_mouse_focus()
	update_field_count()
	update_moving_speed()
	
	if !GlobalVar.tutorial_shown:
		manage_tutorial()
	else:
		tutorial_node.hide()
	
	# If player is looking at something
	if ray.is_colliding():
		var collision_object = ray.get_collider().name
		var watched_object = ray.get_collider()
		
		if collision_object != observed_object:
			observed_object = collision_object
			if "Sorg" in observed_object:
				observed_object = "Sorghum"
			#print("Player is looking at: " + observed_object + ".")
			process_object_prompt(observed_object, watched_object)
	else:
		var collision_object = "nothing"
		if collision_object != observed_object:
			observed_object = collision_object
			#print("Player is looking at: nothing.")
			prompt_label.text = ""	
		process_object_prompt(observed_object, "")
		crop_health_label.text = ""
		crop_status_label.text = ""
		
	toggle_labels()

func _physics_process(delta):
	
	
	if is_on_floor():
		gravity_vector = -get_floor_normal() * slide_prevention
		acceleration = ground_acceleration
		is_on_ground = true
	else:
		if is_on_ground:
			gravity_vector = Vector3.ZERO
			is_on_ground = false
		else:
			gravity_vector += Vector3.DOWN * gravity * delta
			acceleration = air_acceleration

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		is_on_ground = false
		gravity_vector = Vector3.UP * jump

	if Input.is_action_pressed("move_sprint"):
		velocity = velocity.linear_interpolate(direction * speed * 2, acceleration * delta)
	else:
		velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	
	movement.z = velocity.z + gravity_vector.z
	movement.x = velocity.x + gravity_vector.x
	movement.y = gravity_vector.y
	
	move_and_slide(movement, Vector3.UP)
	
	if !GlobalVar.is_game_over or !GlobalVar.is_game_paused:
		if direction != Vector3():
			animation_player.play("Head Bob")
	

func carried_item_change():
	match(carried_object):
		# Hands
		1:
			carry_status_label.text = ""
			tooltip_label.text = ""
			selected_item_sprite.texture = selected_item_hands
		
		# Sickle
		2:
			GlobalVar.play_sound("item_change")
			carry_status_label.text = "Sickle"
			tooltip_label.text = "Use to harvest crops"
			selected_item_sprite.texture = selected_item_sickle
			
		# Bucket
		3:
			if is_bucket_empty:
				carry_status_label.text = "Empty bucket"
				tooltip_label.text = "Has to be filled with water"
				selected_item_sprite.texture = selected_item_bucket_empty
			else:
				carry_status_label.text = "Bucket with water"
				tooltip_label.text = "Use to put out fire"
				selected_item_sprite.texture = selected_item_bucket_water
		
		# Spade
		4:
			GlobalVar.play_sound("item_change")
			carry_status_label.text = "Spade"
			tooltip_label.text = "Destroy crops"
			selected_item_sprite.texture = selected_item_spade
		
		# Crops
		5:
			carry_status_label.text = "Crops"
			tooltip_label.text = "Take crops to the storage"
			selected_item_sprite.texture = selected_item_crops
			


func process_player_action_on_object(observed_object, raycast_object):
	match(observed_object):
		"Well":
			if carried_object == 3:
				if is_bucket_empty:
					is_bucket_empty = false
					item_animation_player.stop()
					GlobalVar.play_sound("water_draw")
					carried_item_change()
		"Sorghum":
			if carried_object == 2:
				var is_crop_on_fire = raycast_object.check_fire_status()
				if !is_crop_on_fire:
					var is_crop_harvestable = raycast_object.check_harvestability()
					if is_crop_harvestable:
						GlobalVar.play_sound("crop_harvest")
						raycast_object.harvest_crop()
						carried_object = 5
						# Wait for the animation to end
						player_timer.start()
						yield(player_timer, "timeout")
						carried_item_change()
			if carried_object == 3:
				if !is_bucket_empty:
					raycast_object.extinguish_fire()
					GlobalVar.play_sound("water_throw")
					is_bucket_empty = true
					selected_item_sprite.texture = selected_item_bucket_empty
			if carried_object == 4:
				GlobalVar.play_sound("crop_destruction")
				raycast_object.destroy_crop()
				some_crop_destroyed = true
		"GrainBin":
			if carried_object == 5:
				GlobalVar.play_sound("crop_drop")
				raycast_object.load_grain_mill()
				carried_object = 2
				speed = 8
				# Wait for the animation to end
				player_timer.start()
				yield(player_timer, "timeout")
				carried_item_change()
				

func process_object_prompt(observed_object, raycast_object):
	match(observed_object):
		"Well":
			if carried_object == 1:
				prompt_label.text = "Fill your bucket here"
			if carried_object == 3:
				if is_bucket_empty:
					prompt_label.text = "Take water"
				else:
					prompt_label.text = "Bucket full"
			else:
				prompt_label.text = "You need a bucket"
		"Sorghum":
			crop_health_label.text = "Health: " + String(int(raycast_object.get_health()))
			crop_status_label.text = "Crop status: " + raycast_object.get_crop_status()
			
			if carried_object == 2:
				var is_crop_on_fire = raycast_object.check_fire_status()
				if !is_crop_on_fire:
					var is_crop_harvestable = raycast_object.check_harvestability()
					if is_crop_harvestable:
						prompt_label.text = "Harvest crop"
					else:
						prompt_label.text = "Nothing to harvest"
				else:
					prompt_label.text = "Put out fire first"
			if carried_object == 3:
				if !is_bucket_empty:
					var is_crop_on_fire = raycast_object.check_fire_status()
					if is_crop_on_fire:
						prompt_label.text = "Extinguish fire"
					else:
						prompt_label.text = "Throw water at"
				else:
					prompt_label.text = "Get water first"
			if carried_object == 4:
				prompt_label.text = "Destroy crop"
		"GrainBin":
			if carried_object == 5:
				prompt_label.text = "Unload crop"
			else:
				prompt_label.text = "Harvest crop and drop it here"


func manage_mouse_focus():
	if is_options_menu_displayed != GlobalVar.is_game_paused:
		is_options_menu_displayed = GlobalVar.is_game_paused
		if GlobalVar.is_game_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if GlobalVar.is_game_over:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func update_field_count():
	fields_left_label.text = "Stacks collected: " + String(GlobalVar.collected_grains)


func update_moving_speed():
	if GlobalVar.is_game_paused or GlobalVar.is_game_over:
		speed = 0
	elif carried_object == 5:
		speed = 4
	else:
		speed = 8


func toggle_labels():
		# Stop displaying if game is paused or over
	if GlobalVar.is_game_paused or GlobalVar.is_game_over:
		fields_left_label.hide()
		crop_status_label.hide()
		crop_health_label.hide()
		carry_status_label.hide()
		tooltip_label.hide()
		prompt_label.hide()
		fields_left_label.hide()
		tutorial_label.hide()
	else:
		fields_left_label.show()
		crop_status_label.show()
		crop_health_label.show()
		carry_status_label.show()
		tooltip_label.show()
		prompt_label.show()
		fields_left_label.show()
		tutorial_label.show()

func manage_tutorial():
	match(tutorial_step):
		1:
			tutorial_label.text = "Select sickle with 2 or MMB scroll"
			if carried_object == 2:
				tutorial_step += 1
		2:
			tutorial_label.text = "Harvest some crop with sickle"
			if carried_object == 5:
				tutorial_step += 1
		3:
			tutorial_label.text = "Take crop to the harvest bin"
			if carried_object == 2:
				tutorial_step += 1
		4:
			tutorial_label.text = "Select bucket with 3 or MMB scroll"
			if carried_object == 3:
				tutorial_step += 1
		5:
			tutorial_label.text = "Look at well and left click"
			if !is_bucket_empty:
				tutorial_step += 1
		6:
			tutorial_label.text = "Use bucket by left clicking on crop"
			if is_bucket_empty:
				tutorial_step += 1
		7:
			tutorial_label.text = "Select spade with 4 or MMB scroll"
			if carried_object == 4:
				tutorial_step += 1
		8:
			tutorial_label.text = "Destroy some crop with spade"
			if some_crop_destroyed:
				tutorial_step += 1
		9:
			GlobalVar.tutorial_shown = true
