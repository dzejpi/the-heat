extends Spatial


onready var animation_player = $AnimationPlayer

var demon_appeared = false
var demon_flying = false


func _ready():
	hide()


func _process(delta):
	if !demon_appeared:
		if GlobalVar.field_amount < 250:
			demon_appeared = true
			animation_player.play("Demon Appearing")
			show()
	
	if !demon_flying:
		if GlobalVar.field_amount < 200:
			demon_flying = true
			animation_player.play("DemonFlying")

	if demon_flying:
		animation_player.play("DemonFlying")
