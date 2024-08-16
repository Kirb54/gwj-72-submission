extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var aimlesstimer = $aimlesstimer




const speed = 400




var attacking = false
var knocked = false
var player = null
var aimless = false
var near = false
var nearcount = 0



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



func attack():
	if nearcount >= 15:
		attacking = true
		anim.play("blowup")
		

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
	if not attacking:
		if velocity.x != 0:
			anim.play('run')
			if velocity.x > 0:
				anim.flip_h = false
			else:
				anim.flip_h = true
		else:
			anim.play('idle')
