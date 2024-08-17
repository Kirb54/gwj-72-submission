extends Node2D

signal donegenerating

@onready var player = $player
@onready var tnt = preload("res://tntlin.tscn")
@onready var norm = preload("res://goblin.tscn")
@onready var cooldown = $cooldowntimer
@onready var boundslabel = $hud/bounds
@onready var healthlabel = $hud/health
@onready var gameended = $gameended
@onready var killslabel = $gameended/killslabel
@onready var wavelabel = $hud/wavelabel

var inbounds = true
var oob = 0
var ramping = 1
var rampheal = 3
var enemies = []
var done = false
# Called when the node enters the scene tree for the first time.
func _ready():
	gameended.hide()
	spawnenemy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkoob()
	checkhealth()
	nextwave()




func checkoob():
	if not inbounds:
		oob += 1
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
	gameended.show()
	get_tree().paused = true
	killslabel.text = "you got " + str(gb.kills) + " kills"


func setenemeies(n):
	if n > 30:
		n = 30
	var amount = get_tree().get_nodes_in_group('enemy')
	var a = 0
	for i in amount:
		a += 1
		
	if n >= 1 and a < 45:
		var e = randi_range(1,5)
		if e == 1:
			enemies.append(tnt)
		else:
			enemies.append(norm)
		n -= 1
		setenemeies(n)
	else:
		donegenerating.emit()

func spawnenemy():
	enemies = []
	var spawnamount = int(ramping +1)
	setenemeies(spawnamount)
	await done
	done = false
	for e in enemies:
		var inst = e.instantiate()
		inst.global_position = getpos()
		add_child(inst)
	cooldown.start()
	await cooldown.timeout
	ramping += randf_range(0,ramping)
	heal()
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


func heal():
	if ramping >= rampheal:
		gb.health += 1
		rampheal = rampheal * 2


func checkhealth():
	healthlabel.text = "Health: " + str(gb.health)
	if gb.health <= 0:
		endgame()


func _on_play_again_pressed():
	get_tree().paused = false
	Engine.time_scale = 1
	gb.reset()
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().paused = false
	Engine.time_scale = 1
	gb.reset()
	get_tree().change_scene_to_file("res://start.tscn")

func nextwave():
	if cooldown.time_left != 0:
		wavelabel.text = "Next wave in " + str(int(cooldown.time_left))


func _on_player_darkswitch():
	if healthlabel and boundslabel and wavelabel:
		healthlabel.add_theme_color_override("font_color","WHITE")
		boundslabel.add_theme_color_override("font_color",'WHITE')
		wavelabel.add_theme_color_override("font_color",'WHITE')
	


func _on_player_lightswitch():
	if healthlabel and boundslabel and wavelabel:
		healthlabel.add_theme_color_override("font_color","BLACK")
		boundslabel.add_theme_color_override("font_color",'BLACK')
		wavelabel.add_theme_color_override("font_color",'BLACK')
