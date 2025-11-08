extends Area3D

signal exploded

@export var g = Vector3.FORWARD * 20
@export var muzzle_velocity = 55

var velocity = Vector3.ZERO

var DMG=200;

func _physics_process(delta):
	velocity = muzzle_velocity*g*delta
	look_at(transform.origin + velocity.normalized(), Vector3.FORWARD)
	#transform.origin = Vector3.FORWARD*3
	transform.origin += velocity * delta

func _on_area_entered(area: Area3D) -> void:
	if(area.has_method("damage")):
		emit_signal("exploded", transform.origin)
		#area.damage(DMG)
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if(!body.has_method("damage") && $"../PreventWallCol".is_stopped()):
		emit_signal("exploded", transform.origin)
		queue_free()
