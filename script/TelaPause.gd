extends TextureRect

var p = false
var jogo_rodando = false

signal encerrar_jogo

func _process(delta):
	if jogo_rodando:
		if not p and Input.is_action_just_pressed("Pause"):
			visible = true
			get_tree().paused = true
			p = true
			$AudioPause.play()
		elif Input.is_action_just_pressed("Pause"):
			visible = false
			get_tree().paused = false
			p = false

func _allow_pause(game_mode):
	jogo_rodando = true
	if game_mode == -2:
		$bt_Sair_Jogo.disabled = true
	else:
		$bt_Sair_Jogo.disabled = false

func _disallow_pause():
	jogo_rodando = false
	if p:
		visible = false
		get_tree().paused = false
		p = false



func Continuar():
	visible = false
	get_tree().paused = false
	p = false


func config_jogo():
	get_parent().get_node("MenuConfig").visible = true


func config_graf():
	pass # Replace with function body.


func sair_jogo():
	visible = false
	emit_signal("encerrar_jogo")
	get_tree().paused = false
	p = false
	
