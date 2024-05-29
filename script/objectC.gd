extends KinematicBody
 
#Direção do movimento
var direc = Vector3(0,0,0.05)

#Tamanho original
onready var largura = $CollisionShape.shape.extents.x 
onready var larguraAsset = $assets.scale.x
var asset_ind = -1

var pt_mf = 1

signal dados

func _ready():
	randomize()
	var assets = []
	for i in $assets.get_children():
		assets.append(i)
	var ind = 0
	
	if asset_ind <= -1 or asset_ind >= assets.size():
		ind = randi() % assets.size()
	else:
		ind = asset_ind
	for i in range(0,assets.size()):
		if i != ind:
			assets[i].queue_free()
		else:
			assets[i].visible = true
	
#Definir novos tamanhos e velocidade
func Set_Speed_e_Tamanho(sp,tm):
	#Modifica raios do objeto e do formato de colisão
	$assets.scale.z = tm * larguraAsset
	$assets.scale.y = tm * larguraAsset
	$CollisionShape.shape.extents.z = tm * largura

	
	#Altera velocidade
	direc *= sp

var id = -1

#Move objeto
func _physics_process(delta):
	$assets.rotation.z-=delta*PI/2 * 3
	move_and_collide(direc)
	emit_signal("dados",translation,id)


