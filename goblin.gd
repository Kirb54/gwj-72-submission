extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var upbox = $upbox/CollisionShape2D
@onready var downbox = $downbox/CollisionShape2D
@onready var leftbox = $leftbox/CollisionShape2D
@onready var rightbox = $rightbox/CollisionShape2D
@onready var aimlesstimer = $aimlesstimer
@onready var attackstartup = $attackstartup
@onready var knockedtimer = $knockedtimer
@onready var light = $PointLight2D


const speed = 500
const knockstr = 450



var player = null
var aimless = false
var attacking = false
var hitplayerdown = false
var hitplayerleft = false
var hitplayerright = false
var hitplayerup = false
var health = 3
var knocked = false


func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		followplayer()
	else:
		findplayer()
	animations()
	flash()
	move_and_slide()


func followplayer():
	if not attacking and not knocked:
		var diffrence = Vector2(player.global_position.x-global_position.x,player.global_position.y-global_position.y)
		var mathdif : Vector2
		mathdif = abs(diffrence)
		var findratio = mathdif.x + mathdif.y
		var ratio = speed/findratio
		velocity.x = move_toward(velocity.x, ratio * diffrence.x, 100)
		velocity.y = move_toward(velocity.y, ratio * diffrence.y, 100)
		print(velocity)


func findplayer():
	if not aimless:
		velocity = Vector2(randf_range(-300,300),randf_range(-300,300))
		aimless = true
		aimlesstimer.start(randi_range(1,3))
		await aimlesstimer.timeout
		aimless = false


func _on_sight_body_entered(body):
	player = body

#this attack function is cringe but im rage coding rn so this is the best its gonna be

func _on_downbox_body_entered(body):
	if body.is_in_group('player'):
		if not attacking:
			anim.play("attack down")
			hitplayerdown = true
			attacking = true
			attack(downbox,body)
		else:
			hitplayerdown = true
		


func _on_rightbox_body_entered(body):
	if body.is_in_group('player'):
		if not attacking:
			anim.play("attack forward")
			anim.flip_h = false
			hitplayerright = true
			attacking = true
			attack(rightbox,body)
		else:
			hitplayerright = true


func _on_upbox_body_entered(body):
	if body.is_in_group('player'):
		
		if not attacking:
			anim.play("attack up")
			hitplayerup = true
			attacking = true
			attack(upbox,body)
		else:
			hitplayerup = true


func _on_leftbox_body_entered(body):
	if body.is_in_group('player'):
		if not attacking:
			anim.play("attack forward")
			anim.flip_h = true
			hitplayerup = true
			attacking = true
			attack(upbox,body)
		else:
			hitplayerleft = true

func attack(attackbox,p):
	if not knocked:
		velocity.x = 0
		velocity.y = 0
		attackstartup.start()
		await attackstartup.timeout or knocked
		if not knocked:
			if attackbox == downbox:
				if hitplayerdown:
					p.hit(self)
			elif attackbox == upbox:
				if hitplayerup:
					p.hit(self)
			elif attackbox == leftbox:
				if hitplayerleft:
					p.hit(self)
			elif attackbox == rightbox:
				if hitplayerright:
					p.hit(self)
		else:
			return
		await anim.animation_finished or knocked
		attacking = false
	

func animations():
	if not attacking and not knocked:
		if velocity.x > 0:
			anim.play("run")
			anim.flip_h = false
		elif velocity.x < 0:
			anim.play("run")
			anim.flip_h = true
		else:
			anim.play("idle")




func _on_downbox_body_exited(body):
	hitplayerdown = false


func _on_rightbox_body_exited(body):
	hitplayerright = false



func _on_upbox_body_exited(body):
	hitplayerup = false


func _on_leftbox_body_exited(body):
	hitplayerleft = false



func hit(p):
	health -= 1
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
