extends CanvasLayer

var displayAmmo = true

var time=0.0
var lastupdate=0.0
var enemies=0
var thingsToSay=[]

@onready var hp=$"../Player".health
@onready var enemycount=$"../Enemies".get_children().size()
@onready var coincount=$"../Level/Coins".get_children().size()

func _process(delta):
	time+=delta
	
	$FPS.text = "FPS: " + str(Engine.get_frames_per_second())
	#INTEGER DIVISION IS THE POINT, GODOT.
	@warning_ignore("integer_division")
	$Time.text = "Time: %d:%02d.%03d" % [(int)(time)/60, ((int)(time)%60), ((int)(time*1000))%1000]
	
	#update face constantly! prevents oddities :)
	hp=$"../Player".health
	
	#cutesy buddha mode (See Source engine for terminology) face
	if(hp>500):
		$face_win.visible=true
	else:
		$face_win.visible=false
	
	#normal faces
	if(hp>100):
		$face_wow.visible=true
	elif(hp>50):
		$face_wow.visible=false
		$face_good.visible=true
	elif(hp>25):
		$face_good.visible=false
		$face_ok.visible=true
	else:
		$face_ok.visible=false
		$face_bad.visible=true

func _on_health_updated(health):
	$Health.text = "Health: "+ str(health) + "%"

func _on_player_ammo_updated(weaponammo, type) -> void:
	if(displayAmmo):
		$Ammo.text = type+": "+str(weaponammo)
	else:
		$Ammo.text = ""

func _on_player_drain_updated(weapondrain) -> void:
	displayAmmo=(weapondrain!=0)

func _on_player_coins_updated(coins) -> void:
	$Coins.text = "Coins: "+str(coins)+"/"+str(coincount)

func _on_enemy_down(v):
	enemies+=v
	$Enemies.text = "Enemies: "+str(enemies)+"/"+str(enemycount)

func _consoletext(text) -> void:
	thingsToSay.push_back(text)

	#reconstruct console output in case of new info
	print_console()
	
	#Start the timer which will remove x after y seconds
	await get_tree().create_timer(10).timeout
	if(!thingsToSay.is_empty()):
		thingsToSay.pop_front()
	
	#after we pop the crusty info
	print_console()

func print_console():
	var console=""
	for x in thingsToSay:
		console+=x+("\n")
	$Console.text=console


func _on_player_key_updated(type, pickedup=true) -> void:
	match type:
		"red": 
			$Keys/RedKey.visible=pickedup
		"yellow": 
			$Keys/YelKey.visible=pickedup
		"blue": 
			$Keys/BluKey.visible=pickedup
