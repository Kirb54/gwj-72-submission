extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var upbox = $upbox/CollisionShape2D
@onready var downbox = $downbox/CollisionShape2D
@onready var leftbox = $leftbox/CollisionShape2D
@onready var rightbox = $rightbox/CollisionShape2D
@onready var aimlesstimer = $aimlesstimer

const speed = 500


var player = null
var aimless = false



func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		followplayer()
	else:
		findplayer()
	
	move_and_slide()


func followplayer():
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
