extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var upbox = $upbox/CollisionShape2D
@onready var downbox = $downbox/CollisionShape2D
@onready var leftbox = $leftbox/CollisionShape2D
@onready var rightbox = $rightbox/CollisionShape2D
@onready var aimlesstimer = $aimlesstimer
@onready var attackstartup = $attackstartup




const speed = 500


var player = null
var aimless = false
var attacking = false


func _ready():
	Engine.time_scale = .5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		followplayer()
	else:
		findplayer()
	animations()
	move_and_slide()


func followplayer():
	if not attacking:
		var diffrence = Vector2(player.global_position.x-global_position.x,player.global_position.y-global_position.y)
		var mathdif : Vector2
		mathdif = abs(diffrence)
		var findratio = mathdif.x + mathdif.y
		var ratio = speed/findratio
		velocity.x = move_toward(velocity.x, ratio * diffrence.x, 100)
		velocity.y = move_toward(velocity.y, ratio * diffrence.y, 100)
		


func findplayer():
	if not aimless:
		velocity = Vector2(randf_range(-300,300),randf_range(-300,300))
		aimless = true
		aimlesstimer.start(randi_range(1,3))
		await aimlesstimer.timeout
		aimless = false


func _on_sight_body_entered(body):
	player = body



func _on_downbox_body_entered(body):
	if body.is_in_group('player') and not attacking:
		attack(downbox)
		anim.play("attack down")
	elif body.is_in_group('player') and attacking:
		body.hit()


func _on_rightbox_body_entered(body):
	if body.is_in_group('player') and not attacking:
		attack(rightbox)
		anim.play("attack forward")
		anim.flip_h = false


func _on_upbox_body_entered(body):
	if body.is_in_group('player') and not attacking:
		attack(upbox)
		anim.play("attack up")


func _on_leftbox_body_entered(body):
	if body.is_in_group('player') and not attacking:
		attack(leftbox)
		anim.play("attack forward")
		anim.flip_h = true

func attack(attackbox):
	velocity.x = 0
	velocity.y = 0
	leftbox.disabled = true
	rightbox.disabled = true
	upbox.disabled = true
	downbox.disabled = true
	attacking = true
	attackstartup.start()
	await attackstartup.timeout
	attackbox.disabled = false
	await anim.animation_finished
	attackbox.disabled = true
	attacking = false
	leftbox.disabled = false
	rightbox.disabled = false
	upbox.disabled = false
	downbox.disabled = false
	

func animations():
	if not attacking:
		if velocity.x > 0:
			anim.play("run")
			anim.flip_h = false
		elif velocity.x < 0:
			anim.play("run")
			anim.flip_h = true
		else:
			anim.play("idle")


