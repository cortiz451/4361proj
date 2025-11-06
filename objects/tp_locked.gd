extends Area3D

@export var dest: Marker3D
@export var player: Node3D

signal console_text

var unlocked=false

func _process(_delta):
	if(!unlocked && (player.weapons[2].inInventory || 
		player.weapons[3].inInventory)):
			unlocked=true
			$AnimatedSprite3D.animation="default"

#teleport player
func _on_body_entered(body: Node3D) -> void:
	#only allow tp if player has unlocked a weapon
	if(body.has_method("unlockWeapon") && unlocked):
		Audio.play("sounds/tp.ogg")
		body.position=dest.position
	else:
		console_text.emit("Haven't unlocked that yet...")
		Audio.play("sounds/nope.ogg")
