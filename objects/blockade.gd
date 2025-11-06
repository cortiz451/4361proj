extends Node3D

@export var player: Node3D
@onready var jingle = $"../../JingleUnlock"
@onready var waitTime = $"../../BlockadeSanityTimer"

var hasFired = false

signal console_text

#explode if player got the items required to pass
func _process(_delta):
	if(!hasFired && player.weapons[2].inInventory && player.weapons[3].inInventory):
		waitTime.start()
		#prevents "infinite loop" LOL
		hasFired=true

#jingle a little after getting weapon so sounds don't overlap
func _on_blockade_sanity_timer_timeout() -> void:
	console_text.emit("Something shifted in the world...")
	jingle.play()
	queue_free()
