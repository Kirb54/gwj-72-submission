extends Area2D

@onready var part = $explosion
@onready var selftimer = $Timer
@onready var radius = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	part.emitting = true
	selftimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	radius.disabled = true


func _on_explosion_finished():
	self.queue_free()


func _on_body_entered(body):
	if body.is_in_group('player'):
		body.hit(self)
	elif body.is_in_group('enemy'):
		body.queue_free()
