extends TextureButton

var level_id = -1
var selected = false
var max_char = 35

signal fase_selecionado

func _process(delta):
	$Texture_select.visible = selected

func _set_button(id,text):
	text.erase(text.length() - 5, 5)
	if text.length() < max_char:
		$Label.text = text
	else:
		$Label.text = text.erase(max_char,text.length()-max_char)
	level_id = id

func _on_bt_fase_pressed():
	emit_signal("fase_selecionado",level_id)
	selected = true
