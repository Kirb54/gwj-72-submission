extends Node2D

signal donegenerating

@onready var player = $player
@onready var tnt = preload("res://tntlin.tscn")
@onready var norm = preload("res://goblin.tscn")
@onready var cooldown = $cooldowntimer
@onready var boundslabel = $hud/bounds

var inbounds = true
var oob = 0
var ramping = 1
var enemies = []
var done = false
# Called when the node enters the scene tree for the first time.
func _ready():
	spawnenemy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkoob()




func checkoob():
	if not inbounds:
		oob += 1
		print('get in bounds')
	else:
		oob = 0
	if oob >= 1:
		boundslabel.show()
	else:
		boundslabel.hide()
	if oob >= 100:
		player.hit(self)


func _on_inbounds_body_entered(body):
	if body == player:
		inbounds = true
	



func _on_inbounds_body_exited(body):
	if body == player:
		inbounds = false
	elif body.is_in_group('enemy'):
		body.queue_free()


func endgame():
	pass


func setenemeies(n):
	if n > 30:
		n = 30
	if n >= 1:
		var e = randi_range(1,5)
		if e == 1:
			enemies.append(tnt)
		else:
			enemies.append(norm)
		n -= 1
		setenemeies(n)
	else:
		print(enemies)
		donegenerating.emit()

func spawnenemy():
	enemies = []
	var spawnamount = int(ramping +1)
	setenemeies(spawnamount)
	await done
	done = false
	print('generated')
	for e in enemies:
		var inst = e.instantiate()
		inst.global_position = getpos()
		add_child(inst)
	cooldown.start()
	await cooldown.timeout
	print('ended')
	ramping += randf_range(0,ramping)
	spawnenemy()
	

func getpos():
	var choice = randi_range(1,3)
	if choice == 1:
		return Vector2(300,600)
	elif choice == 2:
		return Vector2(0,260)
	else:
		return Vector2(820,580)


func _on_donegenerating():
	done = true
