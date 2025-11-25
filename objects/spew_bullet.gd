extends Area3D

signal exploded

@export var g = Vector3.FORWARD * -20 + Vector3.LEFT*(-10+20*randf()) + Vector3.UP*(-7+14*randf())
var h = Vector3.FORWARD * -15 + Vector3.LEFT*(-3+6*randf()) + Vector3.UP*(-2+4*randf())
@export var muzzle_velocity = 45

var velocity = Vector3.ZERO
var MULT=max(0.5, \
			((PlayerConfig.get_config(AppSettings.GAME_SECTION, "Difficulty", 3)-1)/2) \
			)
#how fast do you want it to go?
var SPEED = 65

var DMG=25

var r=false

func _ready():
	r=(randi_range(0,1)==1)

func _physics_process(delta):
	if(r):
		velocity = g*delta*SPEED*MULT
	else:
		velocity = h*delta*SPEED*MULT
	velocity = velocity.clamp(Vector3(-120,-120,-120), Vector3(120,120,120))
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta*MULT

func _on_bullet_body_entered(body: Node3D) -> void:
	emit_signal("exploded", transform.origin)
	if(body.has_method("damage")):
		body.damage(DMG);
	queue_free()
