extends Area3D

signal exploded

@export var g = Vector3.FORWARD * -20 + Vector3.LEFT*(-1+2*randf())
@export var muzzle_velocity = 35

var velocity = Vector3.ZERO

var DMG=10;

func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func _on_bullet_body_entered(body: Node3D) -> void:
	emit_signal("exploded", transform.origin)
	if(body.has_method("damage")):
		body.damage(DMG);
	queue_free()
