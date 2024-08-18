extends Node

var mutesfx = false
func playsound(stream: AudioStream):
	
	if not mutesfx:
		var inst = AudioStreamPlayer.new()
		inst.stream = stream
		add_child(inst)
		inst.play()
		await inst.finished
		inst.queue_free()
