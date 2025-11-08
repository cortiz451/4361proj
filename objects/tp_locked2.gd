extends Area3D

@export var dest: Marker3D
@export var player: Node3D

var unlocked=false
var tmp = ConfigFile.new()

signal console_text

func _process(_delta):
	if(tmp.get_value("Game.Info","tp1", false)):
		unlocked=true
		$AnimatedSprite3D.animation="default"

#teleport player
func _on_body_entered(body: Node3D) -> void:
	if(unlocked):
		body.position=dest.position
		Audio.play("sounds/tp.ogg")
	else:
		console_text.emit("Haven't unlocked that yet...")
		Audio.play("sounds/nope.ogg")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.has_method("keyGet")):
		tmp.load("user://tmp")
		console_text.emit("Teleport unlocked! Hopefully you won't need it...")
		$"../../../../JingleUnlock".play()
		unlocked=true
		$AnimatedSprite3D.animation="default"
		tmp.set_value("Game.Info", "tp1", true)
		tmp.save("user://tmp")
		
		$Area3D.queue_free()
