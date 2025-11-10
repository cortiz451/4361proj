extends CharacterBody3D

@export_subgroup("Weapons")
@export var weapons: Array[Weapon] = []

@export var coins = 0

const RUNSPEED = 12
const MAX_AIRACCEL=0.8
const MAX_ACCEL = 8*RUNSPEED
const g=24
const jump_strength = 1.5*sqrt(2*g)
var friction = 10

var weapon: Weapon
var weapon_index := 1

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true
var movement_velocity: Vector3
var rotation_target: Vector3
var input_mouse: Vector2

var health:int = 100

var previously_floored := false
var container_offset = Vector3(0, -1.3, -3)
var tween:Tween

var DAMAGE_COOLDOWN=0.25;

#add ammotypes here
var ammoTypes=["Ammo", "Shells", "Bullets", "Rockets"]
var numATypes=4
var ammo=[1, 50, 256, 25]
var maxAmmo=[1, 100, 512, 50]

var keys=[false,false,false]

var jump=false

#Sig-nal.
signal health_updated
signal ammo_updated
signal drain_updated
signal coins_updated
signal init_enemycount
signal consoletext
signal key_updated
signal btp_updated

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var blaster_cooldown = $Cooldown
@onready var dmgcool = $DmgCool
@onready var resupplytime = $"../Level/WpnPickups/Resupply/Timer"
@onready var initWait = $"initWait"
@onready var hudfade=$"../HUD/Fade"

@export var crosshair:TextureRect

@onready var tmp = ConfigFile.new()

var player_mouse_sensitivity : float = PlayerConfig.get_config(AppSettings.INPUT_SECTION, "MouseSensitivity", 1.0)
var player_joypad_sensitivity : float = PlayerConfig.get_config(AppSettings.INPUT_SECTION, "JoypadSensitivity", 1.0)

var time=0.0

# Functions

func _ready():
	
	hudfade.color=Color(0,0,0,0)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	weapon = weapons[weapon_index] # Weapon must never be nil
	initiate_change_weapon(0)
	
	#used to track deaths/tp status
	var e = tmp.load("user://tmp")
	
	if(e!=OK):
		print("COULD NOT LOAD FILE!!")
	
	#update enemy count the best way I know how
	initWait.start(0.5)
	
	#update tp5 (boss tp) status
	if(tmp.get_value("Game.Info", "tp1")):
		btp_updated.emit()
	
	if(tmp.get_value("Game.Info", "died")):
		var deathmsg="You died! "
		#death message
		match randi_range(0,3):
			0:
				deathmsg+=("It was nice knowing you...")
			1:
				deathmsg+=("Have you tried turning the game off and on again?")
			2:
				deathmsg+=("You almost had it, too!")
			3:
				deathmsg+=("Maybe you just need to believe in yourself...")
		tmp.set_value("Game.Info", "died", false)
		tmp.save("user://tmp")
		
		consoletext.emit(deathmsg)
		
	$"../BackgroundMusicPlayer".play()
	

func _process(delta):
	
	time+=delta
	
	# Handle functions
	handle_controls(delta)
	
	# Movement
	handle_mvmt(delta)
	
	# Movement sound
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
		#headbob
		if(movement_velocity.length()>0.1):
			camera.position.y = lerp(camera.position.y, 0.05+(camera.position.y+0.05*sin(10*time)), delta * 5)
			container.position.y = lerp(container.position.y, (container.position.y+0.15*sin(10*time)), delta * 5)
			container.position.x = lerp(container.position.x, (container.position.x+0.25*sin(5*time)), delta * 5)
		else:
			camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
		#container.position.y = lerp(container.position.y, container.position.y, delta * 5)
		#container.position.x = lerp(container.position.x, 0.0, delta * 5)
		
	
	# Landing after jump or falling
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	# Falling/respawning
	
	if position.y < -100:
		get_tree().reload_current_scene()

# Mouse movement

func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		input_mouse = (event.relative / mouse_sensitivity) #* player_mouse_sensitivity
		handle_rotation(event.relative.x, event.relative.y, false)

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
	movement_velocity = (Vector3(input.x, 0, 0)+Vector3(0,0,input.y)).normalized()
	#movement_velocity = (transform.basis.x*Vector3(input.x, 0, 0)+transform.basis.z*Vector3(0,0,input.y)).normalized()
	
	# Handle Controller Rotation
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	if rotation_input:
		handle_rotation(rotation_input.x, rotation_input.y, true, delta)
	
	# Shooting
	action_shoot()
	
	#Weapon switch
	action_weapon_toggle()
	action_weapon_select()

# Camera rotation

func handle_rotation(xRot: float, yRot: float, isController: bool, delta: float = 0.0):
	if isController:
		rotation_target -= Vector3(-yRot, -xRot, 0).limit_length(1.0) * gamepad_sensitivity * player_joypad_sensitivity
		rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
		rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	else:
		rotation_target += (Vector3(-yRot, -xRot, 0) / mouse_sensitivity) * player_mouse_sensitivity
		rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = rotation_target.x;
		rotation.y = rotation_target.y;

func handle_mvmt(delta):
	
	movement_velocity = (transform.basis * movement_velocity).normalized() # Move forward

	if(is_on_floor()):
		#allow for easy bhop; you're welcome :)
		if(Input.is_action_pressed("jump")):
			#prevent scary hup overlap
			if($hup.is_stopped()):
				Audio.play("sounds/hup.ogg")
				$hup.start(0.4)
			velocity.y = jump_strength
			velocity = acc(movement_velocity, MAX_AIRACCEL, delta)
		else:
			velocity = hmvmt_ground(movement_velocity, delta)
	else:
		velocity.y -= g*delta
		velocity = acc(movement_velocity, MAX_AIRACCEL, delta)
	
	move_and_slide()
	
	# Rotation 
	container.position = lerp(container.position, container_offset - (basis.inverse() * velocity / 250), delta * 10)

#acceleration func
func acc(applied_velocity, max_velocity, delta):
	#				current (*) applied leads to quake-style airaccel (w low enough air friction)
	var current_spd = velocity.dot(applied_velocity)
	var add_speed=clamp(max_velocity-current_spd, 0, MAX_ACCEL*delta)
	return velocity+add_speed*applied_velocity

#horz. mvmt
func hmvmt_ground(applied_velocity, delta):
	var spd=velocity.length()
	
	#friction!
	if(spd!=0):
		var drop=spd * friction * delta
		velocity *= max(spd-drop,0)/spd
	
	return acc(applied_velocity, RUNSPEED, delta)

# Shooting
func action_shoot():
	
	if Input.is_action_pressed("shoot"):
		
		var aty=weapon.ammotype
		
		if (!blaster_cooldown.is_stopped()): return # Cooldown for shooting
		if (ammo[aty]<=0):
			blaster_cooldown.start(0.5)
			Audio.play("sounds/nope.ogg")
			return
		
		Audio.play(weapon.sound_shoot)
		
		# Set muzzle flash position, play animation
		
		muzzle.play("default")
		
		muzzle.rotation_degrees.z = randf_range(-45, 45)
		muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
		muzzle.position = container.position - weapon.muzzle_position
		
		blaster_cooldown.start(weapon.cooldown)
		
		# FOR PROJECTILE WEAPONS
		if(!weapon.hitscan):
			shootProj()
		# Shoot the weapon, amount based on shot count
		else:
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

func shootProj():
	var b=weapon.Proj.instantiate()
	owner.add_child(b)
	b.transform = $Head/Camera/Marker3D.global_transform

# Toggle between available weapons (listed in 'weapons')

func action_weapon_toggle():
	
	if Input.is_action_just_pressed("weapon_next"):
		var w=wrap(weapon_index + 1, 0, weapons.size())
		#cycle to next available
		while(!weapons[w].inInventory):
			w=wrap(w+1, 0, weapons.size())
		initiate_change_weapon(w)
		
	if Input.is_action_just_pressed("weapon_last"):
		var w=wrap(weapon_index - 1, 0, weapons.size())
		#cycle to next available
		while(!weapons[w].inInventory):
			w=wrap(w-1, 0, weapons.size())
		initiate_change_weapon(w)


func action_weapon_select():
	if Input.is_action_just_pressed("baby_blaster"):
		initiate_change_weapon(0)
	elif Input.is_action_just_pressed("shotgun"):
		initiate_change_weapon(1)
	elif Input.is_action_just_pressed("super_shotgun"):
		initiate_change_weapon(2)
	elif Input.is_action_just_pressed("chaingun"):
		initiate_change_weapon(3)
	elif Input.is_action_just_pressed("rocket_launcher"):
		initiate_change_weapon(4)
	

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

func sethp(hp):
	health=hp
	health_updated.emit(health)

func keyGet(type):
	key_updated.emit(type, true)
	consoletext.emit("You picked up a "+type+" key!")
	match type:
		"red": keys[0]=true
		"yellow": keys[1]=true
		"blue": keys[2]=true

func keyUse(type):
	key_updated.emit(type, false)
	consoletext.emit("You used the "+type+" key...")
	match type:
		"red": keys[0]=false
		"yellow": keys[1]=false
		"blue": keys[2]=false

func hasKey(type):
	match type:
		"red": return keys[0]
		"yellow": return keys[1]
		"blue": return keys[2]

func setAmmo(ammotype, value, add=false):
	if(add):
		ammo[ammotype]+=value
		match ammotype:
			1:
				consoletext.emit("You scooped up some Shells!")
			2:
				consoletext.emit("You bargained for some Bullets!")
			3:
				consoletext.emit("You racketeered some Rockets!")
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
			consoletext.emit("You collected a Chaingun!")
		4:					#maybe a better word here?
			consoletext.emit("You rounded up a Rocket Launcher!")


func damage(amount):
	
	if(dmgcool.time_left!=0): return
	
	Audio.play("sounds/ouch.ogg")
	
	health -= amount+randi_range(-2,2)
	health_updated.emit(health) # Update health on HUD
	
	dmgcool.start(DAMAGE_COOLDOWN)
	
	if health < 0:
		tmp.set_value("Game.Info", "died", true)
		tmp.save("user://tmp")
		SceneLoader.reload_current_scene() # Reset when out of health

func bossTpUnlocked():
	tmp.load("user://tmp")
	tmp.set_value("Game.Info", "tp1", true)
	tmp.save("user://tmp")


func _on_init_wait_timeout() -> void:
	init_enemycount.emit(0)
	coins_updated.emit(0)


func _consoletext() -> void:
	pass # Replace with function body.


func _on_enemy_down() -> void:
	pass # Replace with function body.
