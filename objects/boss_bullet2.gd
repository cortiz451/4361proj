extends Area3D

signal exploded

@export var g = Vector3.FORWARD * -20
#how fast do you want it to go?
@export var Spd = 100
var MULT=max(0.25, \
			((PlayerConfig.get_config(AppSettings.GAME_SECTION, "Difficulty", 3)-1)/2) \
			)

var velocity = Vector3.ZERO

var DMG=30;

func _physics_process(delta):
	velocity = g*delta*Spd
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta*MULT

func _on_bullet_body_entered(body: Node3D) -> void:
	emit_signal("exploded", transform.origin)
	if(body.has_method("damage")):
		body.damage(DMG);
	queue_free()
