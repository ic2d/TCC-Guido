extends TextureButton

var level_id = -1
var selected = false
var nome = ""
var max_char = 42

signal paciente_selecionado

func _process(delta):
	$Texture_select.visible = selected

func _set_button(id,text):
	nome = text
	if text.length() < max_char:
		$Label.text = text
	else:
		$Label.text = text.erase(max_char,text.length()-max_char)
	level_id = id

func get_nome():
	return nome

func _on_bt_fase_pressed():
	emit_signal("paciente_selecionado",level_id)
	selected = true
