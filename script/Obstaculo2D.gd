extends Area2D

var speed_mf = 1
var id = -1

#Move obstaculo 2d no eixo y
#func _physics_process(delta):
#	position.y +=600*speed_mf*delta

#Função para deletar objeto 2d
func Sumir():
	queue_free()


func PlayerColidiu(body):
	Sumir()

func setpos(py,px):
	position.x = 1856+(1856-64)*px*-1/180 
	position.y = 210*(6 - abs(py))
