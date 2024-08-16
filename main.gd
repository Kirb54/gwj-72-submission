extends Node2D

@onready var player = $player

var inbounds = true
var oob = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkoob()




func checkoob():
	if not inbounds:
		oob += 1
		print('get in bounds')
	else:
		oob = 0
	if oob >= 100:
		player.queue_free()


func _on_inbounds_body_entered(body):
	if body == player:
		inbounds = true



func _on_inbounds_body_exited(body):
	if body == player:
		inbounds = false
