extends Spatial


func _ready():
	randomize()

func _Balanca():
	var ind = randi() % 6
	match(ind):
		0:
			$AnimationPlayer.play("tropeco1")
		1:
			$AnimationPlayer.play("tropeco2")
		2:
			$AnimationPlayer.play("tropeco3")
		3:
			$AnimationPlayer.play("tropeco4")
		4:
			$AnimationPlayer.play("tropeco5")
		5:
			$AnimationPlayer.play("tropeco6")
	
