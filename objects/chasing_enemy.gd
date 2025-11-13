extends Node3D

@export var player: Node3D

@onready var raycast = $RayCast

#obj ori progs!
var health := 120
#I love ATR
var SPEED_JUSTYOUBELIEVEIT=7.5
var MULT=max(0.25, \
			((PlayerConfig.get_config(AppSettings.GAME_SECTION, "Difficulty", 3)-1)/2) \
			)

var time := 0.0
var target_position: Vector3
var destroyed := false

#code for aggro
var angry=false;
var alerted=false;

signal enemy_down

# When ready, save the initial position

func _ready():
	target_position = position


func _process(delta):
	
	if(angry):
		self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # Look at player
		if(!alerted):
			raycast.force_raycast_update()
			if(raycast.is_colliding()):
				var collider = raycast.get_collider()
				if collider.has_method("damage"):  # Raycast collides with player
					$Angry.pitch_scale=randf_range(0.9, 1.1)
					$Angry.play()
					alerted=true
		else:
			target_position=position.move_toward(player.position, delta*SPEED_JUSTYOUBELIEVEIT*MULT)
	
	target_position.y += (cos(time * 9) * 1) * delta  # Sine movement (up and down)
	time += delta
	position = target_position


# Take damage from player
func damage(amount):
	#make angry if damaged!
	angry=true
	
	$Hurt.pitch_scale=randf_range(0.9, 1.1)
	$Hurt.play()

	health -= amount

	if health <= 0 and !destroyed:
		destroy()

# Destroy the enemy when out of health

func destroy():
	$Destroy.pitch_scale=randf_range(0.9, 1.1)
	$Destroy.play()
	
	#double call issues
	if(!destroyed):
		enemy_down.emit(1)
	destroyed = true
	
	#do cool fx
	if($CollisionShape3D):
		$CollisionShape3D.queue_free()
	if($"enemy-flying"):
		$"enemy-flying".queue_free()
	$DestroyFX.visible=true
	$DestroyFX.play("default")
	await get_tree().create_timer(0.5).timeout
	queue_free()

#aggro mechanics
func _on_aggro_body_entered(body: Node3D) -> void:
	#if player is in body and not obscured, AH!
	if(body==player):
		angry=true

func _on_aggro_body_exited(body: Node3D) -> void:
	if(body==player):
		angry=false
		

func _on_destroy_time_timeout() -> void:
	queue_free()


func _on_pain_sphere_body_entered(body: Node3D) -> void:
	if(body.has_method("damage") && !destroyed):
		body.damage(20)
		destroy()
