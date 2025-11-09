extends Area3D

signal exploded

@export var g = Vector3.FORWARD * -20 + Vector3.LEFT*(-8+16*randf()) + Vector3.UP*(-6+12*randf())
var h = Vector3.FORWARD * -20 + Vector3.LEFT*(-3+6*randf()) + Vector3.UP*(-2+4*randf())
@export var muzzle_velocity = 45

var velocity = Vector3.ZERO

#how fast do you want it to go?
var SPEED = 65

var DMG=20;

func _physics_process(delta):
	var r=(randi_range(0,1)==1)
	if(r):
		velocity = g*delta*SPEED
	else:
		velocity = h*delta*SPEED
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func _on_bullet_body_entered(body: Node3D) -> void:
	emit_signal("exploded", transform.origin)
	if(body.has_method("damage")):
		body.damage(DMG);
	queue_free()
