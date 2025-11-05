extends Node3D

@export var player: Node3D
@onready var jingle = $"../../JingleUnlock"

#explode if player got the items required to pass
func _process(_delta):
	if(player.weapons[2].inInventory && player.weapons[3].inInventory):
		jingle.play()
		queue_free()
