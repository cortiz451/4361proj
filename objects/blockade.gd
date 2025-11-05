extends Node3D

@export var player: Node3D
@onready var jingle = $"../../JingleUnlock"
@onready var waitTime = $Timer

#explode if player got the items required to pass
func _process(_delta):
	if(player.weapons[2].inInventory && player.weapons[3].inInventory):
		waitTime.start(0.5)

func _on_timer_timeout() -> void:
	jingle.play()
	queue_free()
