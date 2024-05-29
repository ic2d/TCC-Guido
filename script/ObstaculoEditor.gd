extends Node2D

var index = -1
signal selected
var select = false

func _process(delta):
	$SpriteSelected.visible = select

func get_pos():
	return [position.x,position.y]
func set_pos(pos):
	position.x = pos[0]
	position.y = pos[1]
func set_indice(indice):
	index = indice


func _on_TextureButton_pressed():
	emit_signal("selected",index)
	select = true
