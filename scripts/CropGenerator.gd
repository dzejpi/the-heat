extends Node


onready var sorghum_scene = preload("res://scenes/SorghumScene.tscn")

var crop_y_position = 0
var random_range_bottom = -0.8
var random_range_up = 0.8

var x_pos_array = [
	-47.901,
	-44.051,
	-39.944,
	-35.759,
	-31.956,
	-27.742,
	-23.973,
	-19.898,
	-17.789,
	-14.042,
	-9.897,
	-5.823,
	-2.072,
	2.305,
	6.027,
	9.848,
	14.345,
	17.871,
	22.253,
	26.007,
	30.029,
	34.184,
	37.863,
	42.326,
	45.884
	]

var z_pos_array = [
	-47.711,
	-43.594,
	-39.477,
	-35.360,
	-31.243,
	-27.126,
	-23.008,
	-18.891,
	-14.774,
	-10.657,
	-6.540,
	-2.423,
	1.694,
	5.811,
	9.928,
	14.045,
	18.162,
	22.279,
	26.397,
	30.514,
	34.631,
	38.748,
	42.865,
	46.982
	]


func _ready():
	generate_crops()


func generate_crops():
	
	for i in range(0, x_pos_array.size() - 1):
		for j in range(0, z_pos_array.size() - 1):
			
			# Avoid generating crops in [(15, 9) - (18, 14)] rectangle - farm is there 
			if i >= 15 && i <= 18:
				if j >= 9 && j <= 14:
					pass
				else:
					var sorghum_instance = sorghum_scene.instance()
					add_child(sorghum_instance)
					randomize()
					sorghum_instance.global_transform.origin.x = x_pos_array[i] + rand_range(random_range_bottom, random_range_up)
					sorghum_instance.global_transform.origin.y = crop_y_position
					sorghum_instance.global_transform.origin.z = z_pos_array[j]	+ rand_range(random_range_bottom, random_range_up)
			else:
				var sorghum_instance = sorghum_scene.instance()
				add_child(sorghum_instance)
				randomize()
				sorghum_instance.global_transform.origin.x = x_pos_array[i]	+ rand_range(random_range_bottom, random_range_up)
				sorghum_instance.global_transform.origin.y = crop_y_position
				sorghum_instance.global_transform.origin.z = z_pos_array[j]	+ rand_range(random_range_bottom, random_range_up)
				
			j += 1
			
		i += 1
	
