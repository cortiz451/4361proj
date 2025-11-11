extends Control

func _difficulty(d: int) -> void:
	PlayerConfig.set_config(AppSettings.GAME_SECTION, "Difficulty", d)
	d
	#random difficulty names
	match d:
		1:
			match randi_range(0,2):
				0:
					$VBoxContainer/Label.text="This is my first video game..."
				1:
					$VBoxContainer/Label.text="I'm scared!"
				2:
					$VBoxContainer/Label.text="Let's try peace for a change."
				
		2:
			match randi_range(0,2):
				0:
					$VBoxContainer/Label.text="I've played one of these before!"
				1:
					$VBoxContainer/Label.text="The W key moves me forward, right?"
				2:
					$VBoxContainer/Label.text="I'm a rookie, but I'm ready for a challenge."
				
		3:
			match randi_range(0,2):
				0:
					$VBoxContainer/Label.text="I'm ready. Hit me!"
				1:
					$VBoxContainer/Label.text="War paint's on. Let's do this."
				2:
					$VBoxContainer/Label.text="Let's go, baby."
				
		4:
			match randi_range(0,2):
				0:
					$VBoxContainer/Label.text="Fear me."
				1:
					$VBoxContainer/Label.text="No problems for me."
				2:
					$VBoxContainer/Label.text="Elimination is near."
				
		5:
			match randi_range(0,2):
				0:
					$VBoxContainer/Label.text="Haw haw haw... HAW!!"
				1:
					$VBoxContainer/Label.text="Hehehheeehawahaw!!!!"
				2:
					$VBoxContainer/Label.text="...hahahaHAHA!!"
				
		
