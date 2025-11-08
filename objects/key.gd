extends Node3D

@export var KeyType=""
@export var color=Color(255,255,255,1)

func _ready():
	$Sprite3D.modulate=color

func _on_collect(body: Node3D) -> void:
	if(body.has_method("keyGet")):
		body.keyGet(KeyType)
		queue_free()
