extends Spatial

onready var Animtree = $AnimationTree
onready var AnimPlay = $AnimationPlayer

func _ready():
	#Mudar animação para loop
	AnimPlay.get_animation("Andando").loop = true
	#AnimPlay.get_animation("Andando").bone = false
func _process(delta):
	
	if Input.is_action_just_pressed("ui_accept"):
		#AnimPlay.play("ArmatureAction")
		Animtree["parameters/OneShot/active"] = true
