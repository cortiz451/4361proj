extends Node3D

@export var player: Node3D
@export var Bullet : PackedScene

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

var health := 100
var time := 0.0
var target_position: Vector3
var destroyed := false
var angry=false;

# When ready, save the initial position

func _ready():
	target_position = position


func _process(delta):
	self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # Look at player
	target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)

	time += delta

	position = target_position

# Take damage from player

func damage(amount):
	Audio.play("sounds/enemy_hurt.ogg")

	health -= amount

	if health <= 0 and !destroyed:
		destroy()

# Destroy the enemy when out of health

func destroy():
	Audio.play("sounds/enemy_destroy.ogg")

	destroyed = true
	queue_free()

# Shoot when timer hits 0

func _on_timer_timeout():
	#do not aggro if not in aggro zone
	if(angry):
		var b=Bullet.instantiate()
		owner.add_child(b)
		b.transform = $Marker3D.global_transform
	

#aggro mechanics
func _on_aggro_body_entered(body: Node3D) -> void:
	if(body==player):
		angry=true

func _on_aggro_body_exited(body: Node3D) -> void:
	if(body==player):
		angry=false
