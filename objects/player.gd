extends CharacterBody3D

@export_subgroup("Properties")
@export var movement_speed = 5
@export_range(0, 100) var number_of_jumps:int = 2
@export var jump_strength = 8

@export_subgroup("Weapons")
@export var weapons: Array[Weapon] = []

@export var coins = 0

var weapon: Weapon
var weapon_index := 1

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true
var movement_velocity: Vector3
var rotation_target: Vector3
var input_mouse: Vector2

var health:int = 100
var gravity := 0.0

var previously_floored := false
var jumps_remaining:int
var container_offset = Vector3(1.2, -1.1, -2.75)
var tween:Tween

var DAMAGE_COOLDOWN=0.33;

#add ammotypes here
var ammoTypes=["Ammo", "Shells", "Bullets"]
var numATypes=3
var ammo=[1, 50, 256]
var maxAmmo=[1, 100, 512]

#Sig-nal.
signal health_updated
signal ammo_updated
signal drain_updated
signal coins_updated
signal init_enemycount
signal consoletext

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var blaster_cooldown = $Cooldown
@onready var dmgcool = $DmgCool
@onready var resupplytime = $"../Level/WpnPickups/Resupply/Timer"
@onready var initWait = $"initWait"

@export var crosshair:TextureRect

# Functions

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	weapon = weapons[weapon_index] # Weapon must never be nil
	initiate_change_weapon(0)
	
	#update enemy count the best way I know how
	initWait.start(0.5)
	
	$"../Music".play()

func _process(delta):
	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement
	
	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation 
	container.position = lerp(container.position, container_offset - (basis.inverse() * applied_velocity / 30), delta * 10)
	
	# Movement sound
	
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
	
	# Landing after jump or falling
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	# Falling/respawning
	
	if position.y < -100:
		get_tree().reload_current_scene()

# Mouse movement

func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		input_mouse = event.relative / mouse_sensitivity
		handle_rotation(event.relative.x, event.relative.y, false)
	
	#code for selecting weapons
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				initiate_change_weapon(0)
			KEY_2:
				initiate_change_weapon(1)
			KEY_3:
				initiate_change_weapon(2)
			KEY_4:
				initiate_change_weapon(3)
			#KEY_5:
			#	initiate_change_weapon(4)
			
		

func handle_controls(delta):
	
	# Mouse capture
	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	# Movement
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	# Handle Controller Rotation
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	if rotation_input:
		handle_rotation(rotation_input.x, rotation_input.y, true, delta)
	
	# Shooting
	
	action_shoot()
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if jumps_remaining:
			action_jump()
		
	# Weapon switching
	
	action_weapon_toggle()

# Camera rotation

func handle_rotation(xRot: float, yRot: float, isController: bool, delta: float = 0.0):
	if isController:
		rotation_target -= Vector3(-yRot, -xRot, 0).limit_length(1.0) * gamepad_sensitivity
		rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
		rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	else:
		rotation_target += (Vector3(-yRot, -xRot, 0) / mouse_sensitivity)
		rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = rotation_target.x;
		rotation.y = rotation_target.y;
	
# Handle gravity

func handle_gravity(delta):
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		jumps_remaining = number_of_jumps
		gravity = 0

# Jumping

func action_jump():	
	Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
	gravity = -jump_strength	
	jumps_remaining -= 1

# Shooting

func action_shoot():
	
	if Input.is_action_pressed("shoot"):
		
		var aty=weapon.ammotype
		
		if !blaster_cooldown.is_stopped() || ammo[aty]<=0: return # Cooldown for shooting
		
		Audio.play(weapon.sound_shoot)
		
		# Set muzzle flash position, play animation
		
		muzzle.play("default")
		
		muzzle.rotation_degrees.z = randf_range(-45, 45)
		muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
		muzzle.position = container.position - weapon.muzzle_position
		
		blaster_cooldown.start(weapon.cooldown)
		
		# Shoot the weapon, amount based on shot count
		
		for n in weapon.shot_count:
		
			raycast.target_position.x = randf_range(-weapon.spread, weapon.spread)
			raycast.target_position.y = randf_range(-weapon.spread, weapon.spread)
			
			raycast.force_raycast_update()
			if !raycast.is_colliding():
				continue # Don't create impact when raycast didn't hit

			var collider = raycast.get_collider()
			# Hitting an enemy
			
			if collider.has_method("damage"):
				collider.damage(weapon.damage)
			
			# Creating an impact animation
			
			var impact = preload("res://objects/impact.tscn")
			var impact_instance = impact.instantiate()
			
			impact_instance.play("shot")
			
			get_tree().root.add_child(impact_instance)
			
			impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
			impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true)
			
		container.position.z += 0.45 # Knockback of weapon visual
		#camera.rotation.x += 0.025 # Knockback of camera
		#movement_velocity += Vector3(0, 0, weapon.knockback) # Knockback
		
		#lower ammo
		ammo[aty] -= weapon.drain;
		ammo[aty]=max(0, ammo[aty])
		
		ammo_updated.emit(ammo[aty], ammoTypes[aty]) # Update ammo on HUD..?


# Toggle between available weapons (listed in 'weapons')

func action_weapon_toggle():
	
	if Input.is_action_just_pressed("weapon_toggle"):
		initiate_change_weapon(wrap(weapon_index + 1, 0, weapons.size()))
	
	if Input.is_action_just_pressed("weapon_untoggle"):
		initiate_change_weapon(wrap(weapon_index - 1, 0, weapons.size()))

# Initiates the weapon changing animation (tween)

func initiate_change_weapon(index):
	
	# no cheeky same swaps!
	if(index==weapon_index): return
	
	#unlockables
	if(! weapons[index].inInventory): return
	
	Audio.play("sounds/weapon_change.ogg")
	
	blaster_cooldown.start(0.5)
	
	weapon_index = index
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon) # Changes the model

# Switches the weapon model (off-screen)

func change_weapon():
	
	weapon = weapons[weapon_index]

	# Step 1. Remove previous weapon model(s) from container
	
	for n in container.get_children():
		container.remove_child(n)
	
	# Step 2. Place new weapon model in container
	
	var weapon_model = weapon.model.instantiate()
	container.add_child(weapon_model)
	
	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation
	
	# Step 3. Set model to only render on layer 2 (the weapon camera)
	
	for child in weapon_model.find_children("*", "MeshInstance3D"):
		child.layers = 2
		
	# Set weapon data
	
	raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
	crosshair.texture = weapon.crosshair
	
	drain_updated.emit(weapon.drain) # Update drain on HUD..?
	ammo_updated.emit(ammo[weapon.ammotype], ammoTypes[weapon.ammotype]) # Update ammo on HUD

func coin_get():
	coins+=1
	coins_updated.emit(coins)
	consoletext.emit("You found a coin! Now where's the other one...")
	
func heal(hp):
	var prevhp=health
	var better="That burger made you feel better..."
	health+=hp
	if(health>200): health=200
	health_updated.emit(health)
	if(prevhp<25):
		better+=" you really needed it!"
	consoletext.emit(better)

func setAmmo(ammotype, value, add=false):
	if(add):
		ammo[ammotype]+=value
		match ammotype:
			1:
				consoletext.emit("You scooped up some Shells!")
			2:
				consoletext.emit("You bargained for some Bullets!")
	else:
		ammo[ammotype]=value
	#wrap down
	ammo[ammotype]=min(ammo[ammotype], maxAmmo[ammotype])
	refreshAmmoHUD()

func refreshAmmoHUD():
	ammo_updated.emit(ammo[weapon.ammotype], ammoTypes[weapon.ammotype]) # Update ammo on HUD

func unlockWeapon(w):
	weapons[w].inInventory=true
	match w:
		2:
			consoletext.emit("You snagged a Super Shotgun!")
		3:					#maybe a better word here?
			consoletext.emit("You contracted a Chaingun!")
		


func damage(amount):
	
	if(dmgcool.time_left!=0): return
	
	Audio.play("sounds/ouch.ogg")
	
	health -= amount+randi_range(-2,2)
	health_updated.emit(health) # Update health on HUD
	
	dmgcool.start(DAMAGE_COOLDOWN)
	
	if health < 0:
		
		get_tree().reload_current_scene() # Reset when out of health


func _on_init_wait_timeout() -> void:
	init_enemycount.emit(0)
