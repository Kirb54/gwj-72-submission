extends CharacterBody2D


@onready var tptimer = $tptimer
@onready var switchtimer = $switchtimer
@onready var anim = $AnimatedSprite2D
@onready var timerlabel = $timerlabel
@onready var leftbox = $leftbox/CollisionShape2D
@onready var rightbox = $rightbox/CollisionShape2D
@onready var upbox = $upbox/CollisionShape2D
@onready var downbox = $downbox/CollisionShape2D
@onready var attacktimer = $attacktimer
@onready var light = preload("res://light.tscn")
@onready var dark = $dark
@onready var timefreeze = $timefreeze
@onready var cam = $Camera2D
@onready var knockedtimer = $knockedtimer


const smallspeed = 600
const bigspeed = 100
const left = -1
const right = 1
const up = -1
const down = 1
const tpdistance = 100
const scstrong = 5
const knockstr = 500



var notdead = false
var bored = true
var small = false
var cantp = true
var tpx = 0
var tpy = 0
var direction = 1
var attacking = false
var knocked = false


func _ready():
	#smallswitch()
	dark.hide()
	leftbox.disabled = true
	rightbox.disabled = true
	upbox.disabled = true
	downbox.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not notdead:
		
		if small:
			smallrun()
			teleport()
		else:
			bigrun()
			attack()
		animations()
		timercount()
		screenshake()
	
	move_and_slide()


func smallrun():
	if bored:
		
		if Input.is_action_pressed('ui_right'):
			direction = right
			velocity.x = move_toward(velocity.x,right * smallspeed, 150)
		elif Input.is_action_pressed('ui_left'):
			direction = left
			velocity.x = move_toward(velocity.x,left * smallspeed, 150)
		else:
			velocity.x = move_toward(velocity.x,0,50)
			velocity.y = move_toward(velocity.y,0,50)
			
			
		if Input.is_action_pressed('ui_up'):
			velocity.y = move_toward(velocity.y,up * smallspeed, 150)
		elif Input.is_action_pressed('ui_down'):
			velocity.y = move_toward(velocity.y,down * smallspeed, 150)
		else:
			velocity.x = move_toward(velocity.x,0,50)
			velocity.y = move_toward(velocity.y,0,50)

func bigrun():
	if not attacking or not knocked:
		
		if Input.is_action_pressed('ui_right'):
			direction = right
			velocity.x = move_toward(velocity.x,right * bigspeed, 150)
		elif Input.is_action_pressed('ui_left'):
			direction = left
			velocity.x = move_toward(velocity.x,left * bigspeed, 150)
		else:
			velocity.x = move_toward(velocity.x,0,50)
			velocity.y = move_toward(velocity.y,0,50)
			
			
		if Input.is_action_pressed('ui_up'):
			velocity.y = move_toward(velocity.y,up * bigspeed, 150)
		elif Input.is_action_pressed('ui_down'):
			velocity.y = move_toward(velocity.y,down * bigspeed, 150)
		else:
			velocity.x = move_toward(velocity.x,0,50)
			velocity.y = move_toward(velocity.y,0,50)

func teleport():
	if Input.is_action_pressed("ui_accept") and cantp:
		cantp = false
		tpx = 0
		tpy = 0
		if velocity.x != 0:
			if velocity.x > 0:
				tpx = 1
			else:
				tpx = -1
		if velocity.y != 0:
			if velocity.y > 0:
				tpy = 1
			else:
				tpy = -1
		global_position.x = global_position.x + (tpdistance * tpx)
		global_position.y = global_position.y + (tpdistance * tpy)
		tptimer.start()
		await tptimer.timeout
		cantp = true

func attack():
	if Input.is_action_pressed("ui_accept") and not attacking and not knocked:
		attacking = true
		velocity.y = move_toward(velocity.y,0,100)
		velocity.x = move_toward(velocity.x,0,100)
		if Input.is_action_pressed("ui_down"):
			anim.play("attack down")
			attacktimer.start()
			await attacktimer.timeout
			downbox.disabled = false
			await anim.animation_finished
			downbox.disabled = true
			attacking = false
		elif Input.is_action_pressed("ui_up"):
			anim.play("attack up")
			attacktimer.start()
			await attacktimer.timeout
			upbox.disabled = false
			await anim.animation_finished
			upbox.disabled = true
			attacking = false
		else:
			if direction == left:
				anim.play("attack forward")
				anim.flip_h = true
				attacktimer.start()
				await attacktimer.timeout
				leftbox.disabled = false
				await anim.animation_finished
				leftbox.disabled = true
				attacking = false
			else:
				anim.play("attack forward")
				anim.flip_h = false
				attacktimer.start()
				await attacktimer.timeout
				rightbox.disabled = false
				await anim.animation_finished
				rightbox.disabled = true
				attacking = false
		

func smallswitch():
	dark.show()
	var sun = get_tree().get_first_node_in_group('light')
	if sun:
		sun.queue_free()
	small = true
	var timesmall = randi_range(2,5)
	switchtimer.start(timesmall)
	await switchtimer.timeout
	bigswitch()


func bigswitch():
	var inst = light.instantiate()
	add_sibling(inst)
	dark.hide()
	small = false
	var timebig = randi_range(2,5)
	switchtimer.start(timebig)
	await switchtimer.timeout
	smallswitch()

func getflip():
	if direction == right:
		anim.flip_h = false
	else:
		anim.flip_h = true

func animations():
	if not attacking:
		
		if small:
			if velocity.x != 0:
				anim.play("run small")
				getflip()
			elif velocity.y != 0:
				anim.play("run small")
			else:
				anim.play("idle little")
				getflip()
		else:
			if velocity.x != 0:
				anim.play("run big")
				getflip()
			elif velocity.y != 0:
				anim.play("run big")
			else:
				anim.play("idle big")
				getflip()


func timercount():
	timerlabel.text = str(int(switchtimer.time_left))
	if small:
		timerlabel.add_theme_color_override("font_color","WHITE")
	else:
		timerlabel.add_theme_color_override("font_color","BlACK")



func hit(e):
	if not knocked:
		Engine.time_scale = .5
		timefreeze.start()
		await timefreeze.timeout
		var diffrence = Vector2(e.global_position.x+global_position.x,e.global_position.y+global_position.y)
		var mathdif : Vector2
		mathdif = abs(diffrence)
		var findratio = mathdif.x + mathdif.y
		var ratio = knockstr/findratio
		velocity.x = ratio * diffrence.x
		velocity.y = ratio * diffrence.y
		knocked = true
		knockedtimer.start()
		await knockedtimer.timeout
		knocked = false


func _on_downbox_body_entered(body):
	if body.is_in_group('enemy'):
		body.hit(self)


func _on_upbox_body_entered(body):
	if body.is_in_group('enemy'):
		body.hit(self)


func _on_leftbox_body_entered(body):
	if body.is_in_group('enemy'):
		body.hit(self)


func _on_rightbox_body_entered(body):
	if body.is_in_group('enemy'):
		body.hit(self)

func hitsomething():
	Engine.time_scale = .5
	timefreeze.start()
	await timefreeze.timeout
	Engine.time_scale = 1
	cam.offset = Vector2(0,0)



func screenshake():
	if timefreeze.time_left != 0:
		var x = randf_range(-scstrong,scstrong)
		var y = randf_range(-scstrong,scstrong)
		cam.offset = Vector2(x,y)
