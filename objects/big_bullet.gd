extends Area3D

signal exploded

@export var g = Vector3.FORWARD * -20 + Vector3.LEFT*(-3+6*randf()) + Vector3.UP*(-2+4*randf())
@export var muzzle_velocity = 35

var MULT=max(0.5, \
			((PlayerConfig.get_config(AppSettings.GAME_SECTION, "Difficulty", 3)-1)/2) \
			)
var velocity = Vector3.ZERO

#how fast do you want it to go?
var SPEED = 60

var DMG=20;

func _physics_process(delta):
	velocity = g*delta*SPEED
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta*MULT

func _on_bullet_body_entered(body: Node3D) -> void:
	emit_signal("exploded", transform.origin)
	if(body.has_method("damage")):
		body.damage(DMG);
	queue_free()
