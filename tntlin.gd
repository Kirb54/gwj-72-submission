extends CharacterBody2D



@export var hitsfx : AudioStream
@export var deathsfx : AudioStream



@onready var anim = $AnimatedSprite2D
@onready var aimlesstimer = $aimlesstimer
@onready var attacktimer = $attacktimer
@onready var explo = preload("res://explosion.tscn")
@onready var knockedtimer = $knockedtimer
@onready var fuse = $fuse
@onready var light = $PointLight2D


const speed = 400
const knockstr = 500



var attacking = false
var knocked = false
var player = null
var aimless = false
var near = false
var nearcount = 0
var health = 1


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		follow()
		checknear()
		attack()
	else:
		findplayer()
	
	animations()
	flash()
	move_and_slide()



func follow():
	if not attacking and not knocked:
		var diffrence = Vector2(player.global_position.x-global_position.x,player.global_position.y-global_position.y)
		var mathdif : Vector2
		mathdif = abs(diffrence)
		var findratio = mathdif.x + mathdif.y
		var ratio = speed/findratio
		velocity.x = move_toward(velocity.x, ratio * diffrence.x, 100)
		velocity.y = move_toward(velocity.y, ratio * diffrence.y, 100)
	elif attacking:
		velocity.x = move_toward(velocity.x,0,100)
		velocity.y = move_toward(velocity.y,0,100)



func attack():
	if nearcount >= 15 and not attacking and not knocked:
		attacking = true
		fuse.emitting = true
		if anim.flip_h == true:
			fuse.position.x = -7
		else:
			fuse.position.x = 7
		anim.play("blowup")
		attacktimer.start()
		await attacktimer.timeout
		var inst = explo.instantiate()
		inst.global_position = global_position
		add_sibling(inst)
		gb.kills += 1
		self.queue_free()
		

func checknear():
	if near:
		nearcount += 1
	else:
		nearcount = 0

func findplayer():
	if not aimless:
		velocity = Vector2(randf_range(-300,300),randf_range(-300,300))
		aimless = true
		aimlesstimer.start(randi_range(1,3))
		await aimlesstimer.timeout
		aimless = false







func _on_sight_body_entered(body):
	if body.is_in_group('player'):
		player = body


func _on_neardetect_body_entered(body):
	if body.is_in_group('player'):
		near = true



func _on_neardetect_body_exited(body):
	if body.is_in_group('player'):
		near = false



func animations():
	if not attacking and not knocked:
		if velocity.x != 0:
			anim.play('run')
			if velocity.x > 0:
				anim.flip_h = false
			else:
				anim.flip_h = true
		else:
			anim.play('idle')
			
			


func hit(p):
	health -= 1
	sfx.playsound(hitsfx)
	if p.is_in_group('player'):
		p.hitsomething()
	knocked = true
	var diffrence = Vector2(p.global_position.x+global_position.x,p.global_position.y+global_position.y)
	var mathdif : Vector2
	mathdif = abs(diffrence)
	var findratio = mathdif.x + mathdif.y
	var ratio = knockstr/findratio
	anim.play('run')
	velocity.x = ratio * diffrence.x
	velocity.y = ratio * diffrence.y
	if velocity.x > 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
	knockedtimer.start()
	await knockedtimer.timeout
	knocked = false
	attacking = false
	anim.show()
	light.show()
	velocity.x = move_toward(velocity.x,0,100)
	velocity.y = move_toward(velocity.y,0,100)
	
	if health <= 0:
		var inst = explo.instantiate()
		inst.global_position = global_position
		add_sibling(inst)
		gb.kills += 1
		self.queue_free()


func flash():
	if knockedtimer.time_left != 0:
		var rand = randi_range(0,1)
		if rand == 0:
			anim.hide()
			light.hide()
		else:
			anim.show()
			light.show()
