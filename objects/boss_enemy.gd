extends Node3D

@export var player: Node3D
@export var Bullet : PackedScene
@export var Bullet2 : PackedScene

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

signal end_game
signal music

#obj ori progs!
var health := 5000
var shots := 10

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
					$Timer3.start(8)
					
					#music time
					music.emit()
	
	target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
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

	enemy_down.emit(1)
	destroyed = true
	
	#do cool fx
	if($CollisionShape3D):
		$CollisionShape3D.queue_free()
	if($"enemy-flying"):
		$"enemy-flying".queue_free()
	$DestroyFX.visible=true
	$DestroyFX.play()
	$Timer.stop()
	$Timer2.stop()
	$Timer3.stop()
	
	end_game.emit()
	
	await get_tree().create_timer(2).timeout
	
	queue_free()

# Shoot when timer hits 0
func _on_timer_timeout():
	#do not aggro if not in aggro zone
	if(angry):
		raycast.force_raycast_update()
	
	if(destroyed): return

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("damage"):  # Raycast collides with player
			
			for n in shots:
				var b=Bullet.instantiate()
				owner.add_child(b)
				b.transform = $Marker3D.global_transform
		
			muzzle_a.frame = 0
			muzzle_a.play("default")
			muzzle_a.rotation_degrees.z = randf_range(-45, 45)
			$Pew.play()

#right
func _on_timer_2_timeout() -> void:
	#do not aggro if not in aggro zone
	if(angry):
		raycast.force_raycast_update()
	
	if(destroyed): return

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("damage"):  # Raycast collides with player
			await get_tree().create_timer(0.5).timeout
			for n in shots:
				var b=Bullet.instantiate()
				owner.add_child(b)
				b.transform = $Marker3D2.global_transform
			
			muzzle_b.frame = 0
			muzzle_b.play("default")
			muzzle_b.rotation_degrees.z = randf_range(-45, 45)
			$Pew.play()


#aggro mechanics
func _on_aggro_body_entered(body: Node3D) -> void:
	#if player is in body and not obscured, AH!
	if(body==player):
		angry=true

func _on_aggro_body_exited(body: Node3D) -> void:
	if(body==player):
		angry=false
		

#big boss attack
func _on_timer_3_timeout() -> void:
	#do not aggro if not in aggro zone
	if(angry):
		raycast.force_raycast_update()
	
	if(destroyed): return

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("damage"):  # Raycast collides with player
			await get_tree().create_timer(0.5).timeout
			for n in shots:
				await get_tree().create_timer(0.25).timeout
				var b=Bullet2.instantiate()
				owner.add_child(b)
				b.transform = $Marker3D3.global_transform
				$Pew2.play()
