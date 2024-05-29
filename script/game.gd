extends Node2D

#Jogo da espada
onready var Game = $JogoEspada
onready var MenuConfig = $CanvasLayer/MenuConfig
onready var TelaPause = $CanvasLayer/TelaPause
onready var playernameline = $CanvasLayer/HUD/TelaPlayerEscolha/TypePlayerName
onready var MenuSelecFase = $CanvasLayer/MenuSelectFase
onready var MenuLevelEditor = $CanvasLayer/LevelEditor
onready var ScoreFinal = $CanvasLayer/ScoreFinal
onready var HUD = $CanvasLayer/HUD
onready var play_or_edit = -1

onready var keyboard_mode = false

var calib = false
var last_ang


func _ready():
	MenuConfig.connect("sig_calibrar",self,"_calib_change")
	
	TelaPause.connect("encerrar_jogo",Game,"end_game")
	
	ScoreFinal.connect("encerrar_sessao",self,"_encerrar_sessao")
	ScoreFinal.connect("jogar_de_novo",Game,"_open_fases")
	ScoreFinal.connect("abriuScore",TelaPause,"_disallow_pause")
	
	Game.connect("jogo_comecou",self,"_jogo_comecou")
	Game.connect("pause_liberado",TelaPause,"_allow_pause")
	Game.connect("fase_aberta",MenuSelecFase,"add_button")
	Game.connect("abrindo_fases",MenuSelecFase,"abrir_menu")
	Game.connect("encerrar_teste",self,"_encerrar_teste")
	Game.connect("encerrar_teste",TelaPause,"_disallow_pause")
	Game.connect("show_score",ScoreFinal,"_show_score")

	MenuSelecFase.connect("start_game",Game,"_start_game")
	MenuSelecFase.connect("SelectF_aberto",TelaPause,"_disallow_pause")
	MenuSelecFase.connect("fechar_tela_fase",HUD,"_on_bt_paciente_pressed")
	MenuSelecFase.connect("fechar_tela_fase",Game,"votlar_tela_ap")
	
	MenuLevelEditor.connect("start_game",Game,"_start_game")

	HUD.connect("openEditor",MenuLevelEditor,"_open_editor")
	HUD.connect("openEditor",self,"_abriu_editor")
	HUD.connect("jogo",self,"_abriu_jogo")
	HUD.connect("select_tela",self,"_voltar_tela_select")
#Algum cliente se conectou ao websocket
func _on_WebSocketsServer_connected(to_url):
	$CanvasLayer/HUD.set_ip(to_url)
	$CanvasLayer/HUD.set_status("CONNECTED")
	keyboard_mode = false

#O cliente desconectou do servidor
func _on_WebSocketsServer_disconnected():
	$CanvasLayer/HUD.set_ip("")
	$CanvasLayer/HUD.set_status("DISCONNECTED")
	if play_or_edit == 1:
		keyboard_mode = true
	else:
		get_tree().reload_current_scene()
#Dados enviados pelo cliente
func _on_WebSocketsServer_new_accel_data(data):
	#Converte Json em dicionário
	var json_res = JSON.parse(data)
	
	#Checa se aconteceu algum erro
	if json_res.error != OK:
		print("ERROR parsing: ", json_res.error)
		print(json_res.error_string)
		return
		
	#Checa se conversão está no formato adequado
	if !(json_res.result is Dictionary): return
	
	#Envia dados pro Jogo
	Game.tick(json_res)
	if calib == true:
		MenuConfig.json_res = json_res
	last_ang = json_res

func _process(delta):
	if keyboard_mode:
		if Input.is_action_pressed("ui_right"):
			last_ang.result["accel"]+=10*delta
		elif Input.is_action_pressed("ui_left"):
			last_ang.result["accel"]-=10*delta
		Game.tick(last_ang)
		if calib == true:
			MenuConfig.json_res = last_ang

#Definir valores configuraveis
func setGameValues(Del,Vel,Tam,AngMax,AngMin):
	Game.setGamev(Del,Vel,Tam,AngMax,AngMin)

func _calib_change():
	calib = !calib

var nome_cliente_atual = "-"
onready var dir = Directory.new()

func _encerrar_teste():
	get_tree().paused = true
	MenuLevelEditor.visible =true

#Salvar dados e fechar jogo
func _encerrar_sessao():
	var fname = "Pacientes/"+nome_cliente_atual+"/"+nome_cliente_atual+"_Calibracao.JSON"
	var pdes = "Pacientes/"+nome_cliente_atual+"/Desempenho/"+Time.get_datetime_string_from_system().replace("-","_").replace(":","_")+".csv"
	var file = File.new()
	var data = null
	if file.file_exists(fname):
		file.open(fname,File.READ)
		data = parse_json(file.get_as_text())
		file.close()
	
	if data == null:
		data = {nome_cliente_atual:[]}
		
	var new_data = Game.get_config()
	
	data[nome_cliente_atual].append(new_data)
	
	file.open(fname,File.WRITE)
	file.store_string(JSON.print(data," "))
	file.close()
	
	file.open(pdes,File.WRITE)
	var historico_desempenho = Game.get_desempenho()
	file.store_string(historico_desempenho)
	file.close()
	
	get_tree().quit()

#Pegar nome digitado e checar se já existe um paciente registrado para criar ou abrir pastas
func _jogo_comecou():
	nome_cliente_atual = playernameline.text
	
	if dir.open("Pacientes") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == nome_cliente_atual:
				dir.open(file_name)
				return
			file_name = dir.get_next()
		dir.make_dir(nome_cliente_atual)
		#dir.open(nome_cliente_atual)
		dir.make_dir(nome_cliente_atual+"/Desempenho")

func _abriu_editor():
	play_or_edit = 1
	
func _abriu_jogo():
	play_or_edit = 0
func _voltar_tela_select():
	play_or_edit = -1
