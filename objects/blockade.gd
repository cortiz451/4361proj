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

func _on_warning_body_entered(body: Node3D) -> void:
	if(body.has_method("unlockWeapon")):
		console_text.emit("I'm going to need to pick up something to pass this guy...")
		Audio.play("sounds/nope.ogg")
