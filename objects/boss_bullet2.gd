extends Area3D

signal exploded

@export var g = Vector3.FORWARD * -20
#how fast do you want it to go?
@export var Spd = 100

var velocity = Vector3.ZERO

var DMG=25;

func _physics_process(delta):
	velocity = g*delta*Spd
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func _on_bullet_body_entered(body: Node3D) -> void:
	emit_signal("exploded", transform.origin)
	if(body.has_method("damage")):
		body.damage(DMG);
	queue_free()
