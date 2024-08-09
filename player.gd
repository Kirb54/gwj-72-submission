extends CharacterBody2D


@onready var tptimer = $tptimer
@onready var switchtimer = $switchtimer
@onready var anim = $AnimatedSprite2D
@onready var timerlabel = $timerlabel


const smallspeed = 600
const bigspeed = 100
const left = -1
const right = 1
const up = -1
const down = 1
const tpdistance = 100

var notdead = false
var bored = true
var small = true
var cantp = true
var tpx = 0
var tpy = 0
var direction = 1

func _ready():
	smallswitch()


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
	if bored:
		
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
	pass

func smallswitch():
	small = true
	var timesmall = randi_range(2,5)
	switchtimer.start(timesmall)
	await switchtimer.timeout
	bigswitch()


func bigswitch():
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
