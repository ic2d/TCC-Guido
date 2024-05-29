extends Spatial

onready var AnimPlay = $AnimationPlayer

func _ready():
	#Mudar animação para loop
	AnimPlay.get_animation("Andando").loop = true
	#AnimPlay.get_animation("Andando").bone = false
	AnimPlay.play("Andando")
