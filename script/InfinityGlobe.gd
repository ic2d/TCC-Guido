extends Spatial

#Gira cenário infinitamente
func _process(delta):
	rotate(Vector3(1,0,0),0.005)
