extends Resource
class_name Weapon

@export_subgroup("Model")
@export var model: PackedScene  # Model of the weapon
@export var position: Vector3  # On-screen position
@export var rotation: Vector3  # On-screen rotation
@export var muzzle_position: Vector3  # On-screen position of muzzle flash

@export_subgroup("Properties")
@export_range(0.001, 3) var cooldown: float = 0.1  # Firerate
@export_range(1, 200) var max_distance: int = 200  # Fire distance
@export_range(0, 100) var damage: float = 25  # Damage per hit
@export_range(0, 50) var spread: float = 0  # Spread of each shot
@export_range(1, 64) var shot_count: int = 1  # Amount of shots
@export_range(0, 50) var knockback: int = 0  # Amount of knockback
@export var ammotype: int = 0  # Amount of ammo
@export_range(0, 10) var drain: int = 1  # Amount of ammo to take per shot
@export var inInventory: bool = true  # Requires pickup?
@export var hitscan: bool = true # Rocket launcher :)

@export_subgroup("Sounds")
@export var sound_shoot: String  # Sound path

@export_subgroup("Crosshair")
@export var crosshair: Texture2D  # Image of crosshair on-screen
