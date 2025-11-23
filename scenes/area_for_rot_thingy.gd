extends Area3D

signal consoletext

func damage(_amount):
	if($Timer.time_left<0.2):
		consoletext.emit("He's friendly...")
	$Timer.start(1.0)
