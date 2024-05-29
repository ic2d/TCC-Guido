extends Spatial

#Nòs Filhos relevantes
onready var player = $Layer2D/Player
onready var G_layer2d = $Layer2D
onready var Obstaculos2d = $Layer2D/ObstaculosMinimapa
onready var sword = $sword
onready var sppos = $SpawnObj/SpawnAngulo/SpawnPoint#$Spatial/SpawnObj/Path/SpawnPos
onready var spang  = $SpawnObj/SpawnAngulo
onready var SpawnG = $SpawnObj
onready var Grafico = get_parent().get_node("CanvasLayer/Graficos/line_chart_continous")
onready var SpawnTimer = $SpawnTimer
onready var TimerHistorico = $TimerHistorico
onready var graficoControl = get_parent().get_node("CanvasLayer/Graficos")
onready var playernameline = get_parent().get_node("CanvasLayer/HUD/TelaPlayerEscolha/TypePlayerName")

#Sons
onready var sd_Musica = $Sons/AudioMusica
onready var sd_Derrota = $Sons/AudioDerrota
onready var sd_Ambiente = $Sons/AudioFloresta
onready var sd_Hits = [$Sons/AudioHit1,$Sons/AudioHit2,$Sons/AudioHit3]
onready var sd_SacarEspada = $Sons/AudioStartGame
onready var sd_invocObst = $Sons/AudioInvocouObst

#Acesso a HUD
onready var HUD = get_parent().get_node("CanvasLayer")
onready var lbpts = get_parent().get_node("CanvasLayer/Countpt")
#Contador de Pontos
var points = 0
var possible_points = 0

#Carregando objetos que podem ser adicionados a cena
var enemy = preload("res://scenes/enemy.tscn")
var obst2D = preload("res://scenes/Obstaculo2D.tscn")
var objectc= preload("res://scenes/objectC.tscn")
var partic1 = preload("res://Particulas/destroypartic.tscn")

#Nome paciente foi escolhido?
var started = false
var game_running = false

#angulo exato onde será spawnado obstaculo
var angulo_desejado = 0

#Marcadores de passagem do tempo para gravar no gráfico
var time_start = 0
var time_now = 0

""" Sistema de Desafios """
#desafios padrão com: #(ângulo, tempo, velocidade e tamanho objetos)
#var df_exemplo = [[180,1,1,2],[0,2,2,1],[90,3,1,1]]
#var df_exemplo2 = [[0,1,2,2],[45,2,1,2],[10,3,1,1],[20,4,1,1],[30,5,1,1]]

#Tempos para spawnar obstaculos do desafio
var df_tempo_spawn

#desafio atual
var df_atual = []
var df_at_indice = 1000

#obstaculo atual
var df_obstaculo_atual = 0
var df_tempo_spawn_atual

#Conjunto com desafios que serão escolidos na ordem ou aletaório
var df_todos = []
var backup_df_todos = []
var df_random = false

""""""

#gerador de números aleatórios
onready var rd_number_gen = RandomNumberGenerator.new()


#Monitoramento Obstaculos
var count_obstaculo = 0
var obs_ativos = {}

#Sorter para array
class CustomSorter:
	#Sort baseado na variável tempo do dictionary
	static func sort_tempo(a,b):
		return a["tempo"] < b["tempo"]

var game_mode_selected = -1

var last_obst = false

#limitação física controle
var limit_control = 9.7
#Variaveis de intervalo do paciente
var ang_min_p = 0
var ang_max_p = 180

var angulo = 0
#Angulo objetivo do gráfico
var graf_ang_obj = 0
var graf_ang_sword = 0
#Variaveis modificadoras do tempo de spawn dos obstaculos
var df_time_mf = 2
var df_vel_mf = 1
var df_tm_mf = 1
var ang_max = 180
var ang_min = 0

var list_obst2d = {}
#Calcula qual o obstáculo mais próximo para marca-lo como ideal a se atingir
var id_almejado
#Array com historico de sessão
var historico = {"historico":[],"pontuação":0}
var Ponto_ou_Erro = 0


#Sinais
signal jogo_comecou
signal fase_aberta
signal abrindo_fases
signal encerrar_teste
signal show_score
signal tropecar
signal pause_liberado

#Inicializando Jogo
func _ready():
	randomize()
	
	#Contador de tempos pro gráfico
	time_start = OS.get_ticks_msec()/1000.0
	time_now = OS.get_ticks_msec()/1000.0
	connect("tropecar",$Carroca/carrocaUp,"_Balanca")
	
func _start_game(level_id,game_mode,desafio):
	
	last_obst = false
	points = 0
	possible_points = 0
	lbpts.text = str(points)
	
	game_mode_selected = game_mode
	emit_signal("pause_liberado",game_mode_selected)

	match(game_mode):
		-2:
			if desafio.size() > 0:
				backup_df_todos = df_todos
				desafio.sort_custom(CustomSorter,"sort_tempo")
				df_todos = [desafio]
		0:
			df_todos = [df_todos[level_id]]
		1:
			df_todos = df_todos
			df_random = true
	game_running = true
	Inicializa_Desafio()
	
	#Configura timer do primeiro obstáculo
	SpawnTimer.wait_time = df_tempo_spawn_atual * df_time_mf 
	
	#Timer do obstáculo
	SpawnTimer.start()
	#Timer de Registrar dados
	TimerHistorico.start()
	
	#Retira Label na frente da tela
	HUD.get_node("HUD").set_started(true)
	
	#inicializa particula para evitar travamento
	var instp = partic1.instance()
	get_parent().add_child(instp)
	
	emit_signal("jogo_comecou")
	
	sd_Musica.play()
	sd_Ambiente.play()
	sd_SacarEspada.play()

func _open_fases():
	emit_signal("abrindo_fases")
	#Arquivo
	var file = File.new()
	###Criar Arquivo
	#file.open("Fases/Fase2.JSON",File.WRITE)
	#file.store_line(to_json(file_data))
	#file.close()
	
	var js_files = get_json_files("Fases")

	var fase_id = 0
	df_todos = []
	for f in js_files:
		#Abrir Arquivo
		file.open("Fases/"+f,File.READ)
		#Ler arquivo e converter json
		var file_data = parse_json(file.get_as_text())
		file.close()
		
		emit_signal("fase_aberta",fase_id,str(f))
		fase_id+=1
		
		#Pega desafio do json
		var df_ord = file_data["desafio"]
		#Ordena desafio baseado nas variáveis tempo
		df_ord.sort_custom(CustomSorter,"sort_tempo")
		
		#Salva desafio na lista
		df_todos.append(df_ord)



func _process(delta):
	
	if Input.is_action_just_pressed("key_g"):
		graficoControl.visible = !graficoControl.visible
	if Input.is_action_just_pressed("Minimap"):
		G_layer2d.visible = !G_layer2d.visible
	
	#Enter foi apertado enquanto jogo não está rodando
	if Input.is_action_pressed("ui_accept") and !game_running:
		_on_bt_nomePaciente_pressed()

#Atualização por dados recebidos pelo controle
func tick(json_res):
	#Intervalos -9.7 a 9.7
	if json_res.result["accel"] > limit_control:
		json_res.result["accel"] = limit_control
	elif json_res.result["accel"] < -limit_control:
		json_res.result["accel"] = -limit_control
	
	var lim_sup = 2*limit_control*ang_max_p/180
	var lim_inf =  2*limit_control*ang_min_p/180
	#Passar para Limites do Paciente
	json_res.result["accel"]+=limit_control
	if json_res.result["accel"] > lim_sup:
		json_res.result["accel"] = lim_sup
	elif json_res.result["accel"] < lim_inf:
		json_res.result["accel"] = lim_inf

	#Converter para proporção dos limites do paciente e passar de volta para os limites de -9.7 a 9.7
	json_res.result["accel"] = (json_res.result["accel"]-lim_inf)*2*limit_control/(lim_sup-lim_inf)-limit_control
	
	
	#Cria animação e roda para movimento da espada
	var tw = create_tween()
	
	#ângulo para espada utilizando parâmetros configurados
	angulo = 180*stepify(-(json_res.result["accel"]),0.02)/(2*limit_control)+90
	angulo = (ang_max-ang_min)*angulo/180+ ang_min
	tw.tween_property(sword,"rotation_degrees",Vector3(0,0,angulo),0.2)
	
	#Mover navinha
	#Animação de movimento para posição proporcional ao angulo do controle
	var tw2 = create_tween()
	tw2.tween_property(player,"position",Vector2(1900 +(1900-0)*angulo*-1/180,1000),0.2)

	
	

#função para spawnar inimigos
func spawn_enemy():
	
	#Pega dados do obstáculo atual
	var en_angulo
	if df_atual[df_obstaculo_atual]["angulo"] >= 0:
		en_angulo = (ang_max-ang_min)*df_atual[df_obstaculo_atual]["angulo"]/180+ ang_min
	else:
		en_angulo = randi() % 181
		en_angulo = (ang_max-ang_min)*en_angulo/180+ ang_min
	var en_velocidade = df_atual[df_obstaculo_atual]["velocidade"] * df_vel_mf
	var en_tam =df_atual[df_obstaculo_atual]["tamanho"] * df_tm_mf
	var en_asset = df_atual[df_obstaculo_atual]["asset"]
	var en_pt_mf = df_atual[df_obstaculo_atual]["ponto"]
	
	#==Obstáculo 2D==
	var instance = obst2D.instance()#enemy.instance()
	instance.global_position = Vector2(1856+(1856-64)*en_angulo*-1/180, 0)
	instance.id = count_obstaculo
	
	instance.scale.x *= en_tam/2.0	
	
	Obstaculos2d.add_child(instance)
	list_obst2d[count_obstaculo] =instance
	
	instance.speed_mf = en_velocidade
	#Define posição 
	
	#instance.visible = false
	
	#==Obstáculo 3D==
	var inst = objectc.instance()
	inst.id = count_obstaculo
	
	inst.connect("dados",self,"_dados_obstaculo")
	
	#Define ângulo
	var randAng = en_angulo
	spang.rotation.z = deg2rad(randAng)
	
	#Converter para ângulo do gráfico
	angulo_desejado =  (ang_max-ang_min)*(randAng)/180 + ang_min

	#Invocar e passar parâmetros para o obstáculo 3d (sppos é child de spang)
	inst.translation = sppos.global_translation
	inst.rotation.y = PI/2
	inst.rotation.x = 3*PI/2-spang.rotation.z
	inst.asset_ind = en_asset
	inst.pt_mf = en_pt_mf
	SpawnG.get_node("ObstaculosInvocados").add_child(inst)
	inst.Set_Speed_e_Tamanho(en_velocidade,en_tam)
	obs_ativos[count_obstaculo] = [Vector3(0,0,0),angulo_desejado]
	
	count_obstaculo+=1
	emit_signal("tropecar")
	sd_invocObst.play()

#Inicializa um novo desafio
func Inicializa_Desafio():
	#Desafio aleatório
	if df_random:
		df_at_indice = rd_number_gen.randi_range(0,df_todos.size()-1)
	#Desafio na ordem
	elif df_at_indice+1 < df_todos.size():
		df_at_indice+=1
	else:
		df_at_indice=0
	
	#Volta ao primeiro obstáculo
	df_obstaculo_atual = 0
	
	#Pega dados do desafio atual
	df_atual = df_todos[df_at_indice]
	df_tempo_spawn= getTemposDesafio(df_atual)
	df_tempo_spawn_atual = df_tempo_spawn[df_obstaculo_atual]

#Timer para Spawnar inimigos
func _on_SpawnTimer_timeout():
	
	#Já foi o último obstáculo
	if df_obstaculo_atual >= df_atual.size():
		# o que fazer ao fim da fase depende do game mode
		match(game_mode_selected):
			-2:
				last_obst = true
				df_todos = backup_df_todos
			0: #Terminar depois de uma fase
				last_obst = true
			1: #Jogar infinitamente escolher outra fase aleatória
				Inicializa_Desafio()
		
	#Próximo obstáculo
	elif game_running:
		proximo_obstaculo()

#funcao para invocar um obstáculo e configurar para o próximo
func proximo_obstaculo():
	#Invocar obstáculo
	spawn_enemy()
	
	#Atualiza indice
	df_obstaculo_atual +=1
	
	#Checa se existe um próximo obstáculo para configurar timer
	if df_obstaculo_atual < df_atual.size():
		df_tempo_spawn_atual = df_tempo_spawn[df_obstaculo_atual]
		var timer_time = df_time_mf*(df_tempo_spawn_atual - df_tempo_spawn[df_obstaculo_atual-1])
		if timer_time <= 0:
			timer_time = 0.001
		SpawnTimer.wait_time = timer_time
		SpawnTimer.start()
	
	#caso tenha chegado ao ultimo inicializa desafio e arrumar timer
	else:
		_on_SpawnTimer_timeout()
		SpawnTimer.wait_time = df_tempo_spawn_atual * df_time_mf
		SpawnTimer.start()

#Deletar inimigos 2d no fim da tela
func _on_Area2D_area_entered(area):
	if !area.is_in_group("Enemies"): return
	area.die()

#Espada atingiu um dos alvos
func Objeto_bateu_espada(body):
	if game_running:
		var indh = randi() % sd_Hits.size()
		sd_Hits[indh].play()	
		Ponto_ou_Erro = 1
		
		#Adicionar particula de explosão na posição do impacto
		var instp = partic1.instance()
		instp.translation = body.global_translation
		get_parent().add_child(instp)
		
		
		
		#Aumenta e atualiza pontos
		points += 10 * body.pt_mf
		lbpts.text = str(points)
		_obstaculo_destruido(body.id,body.pt_mf)
		#Deleta obstáculo que atingiu
		body.queue_free()



#Atualizar gráfico com posição atual da mão e posição do próximo obstáculo
func Update_Grafico():
	#pega ângulo atual
	graf_ang_sword = rad2deg((ang_max-ang_min)*sword.rotation.z/180 +ang_min)
	
	obs_ideal()
	var values
	#Dados de ângulo atual e ângulo "ideal"
	if not obs_ativos.empty():
		#Simplificação transição
		graf_ang_obj = lerp(graf_ang_obj,obs_ativos[id_almejado][1],0.4)
		values = {
			  angulo_conseguido = graf_ang_sword,#rng.randi_range(-50,50)
			  angulo_ideal = graf_ang_obj
			}
	else:
		values = {
				angulo_conseguido = graf_ang_sword,#rng.randi_range(-50,50)
				angulo_ideal = graf_ang_obj
			}
	#Pega tempo atual
	time_now = OS.get_ticks_msec()/1000.0
		
	#Adiciona pontos no gráfico
	Grafico.add_points((time_now-time_start),values)

#Função para pegar todos os tempos de spawnar obstaculo no jogo
func getTemposDesafio(desafio):
	var tempos = []
	for i in desafio:
		tempos.append(i["tempo"])
	return tempos



#Set valores preferencias do usuário
func setGamev(Del,Vel,Tam,AngMax,AngMin):
	df_time_mf = float(Del)
	df_vel_mf = float(Vel)
	df_tm_mf = float(Tam)
	ang_min_p= float(AngMin)#ang_max = float(AngMax)
	ang_max_p= float(AngMax)#ang_min = float(AngMin)

#Função para pegar arquivos de diretório
func get_json_files(path):
	var dir = Directory.new()
	var jsonfiles = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass#print("Found directory: " + file_name)
			else:
				#print("Found file: " + file_name)
				if not ".JSON" in file_name and not ".json" in file_name:
					pass
				else:
					jsonfiles.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return jsonfiles

#Pega Configuração atual
func get_config():
	return {"data":Time.get_datetime_string_from_system(),
		"delay inimigos":df_time_mf,
		"velocidade objetos":df_vel_mf,
		"tamanho objetos":df_tm_mf,
		"angulo max": ang_max_p,
		"angulo min": ang_min_p
		}


#Passa dados de historico		
func get_desempenho():
	
	var historicocsv = "tempo, paciente ângulo, desejado ângulo, Acertos, Pontuação\n"
	for i in historico["historico"]:
		for j in i:
			historicocsv+=str(j)
			historicocsv+=","
		
		historicocsv+="\n"
		print(historicocsv)
	return historicocsv


#Passar dados atais do obstáculo e atualizar minimapa
func _dados_obstaculo(pos,id):
	if obs_ativos.has(id): # id <
		obs_ativos[id][0] = pos
		var obst = obs_ativos[id]
		list_obst2d[id].setpos(obst[0][2],obst[1])
	
func _obstaculo_destruido(id,pontoObst):
	possible_points += 10 * pontoObst
	obs_ativos.erase(id)
	list_obst2d[id].queue_free()
	list_obst2d.erase(id)
	#nao esta encerrando jogo
	if pontoObst > 0:
		Registro_historico()
	if last_obst and obs_ativos.size() == 0:
		match(game_mode_selected):
			-2:
				last_obst = false
				emit_signal("encerrar_teste")
			0:
				last_obst = false
				sd_Musica.stop()
				emit_signal("show_score",points,possible_points,historico)
				TimerHistorico.stop()


func obs_ideal():
	if not obs_ativos.empty():
		var zprox = -10000
		var kprox = -1
		for key in obs_ativos:
			var posz = obs_ativos[key][0][2]
			if posz > zprox:
				zprox = posz
				kprox = key
		id_almejado = kprox
		

func Registro_historico():
	obs_ideal()
	var apend
	if Ponto_ou_Erro == 1:
		apend = [time_now,graf_ang_sword,graf_ang_obj,"Acerto",points]
		Ponto_ou_Erro = 0
	elif Ponto_ou_Erro == 2:
		apend = [time_now,graf_ang_sword,graf_ang_obj,"Erro", points]
		Ponto_ou_Erro = 0
	else:
		apend = [time_now,graf_ang_sword,graf_ang_obj,"-",points]
	historico["historico"].append(apend)



func obstaculo_saiu_limite(body):
	if game_running:
		Ponto_ou_Erro = 2
		_obstaculo_destruido(body.id,body.pt_mf)
		obs_ideal()
		body.queue_free()



#Abrir Fases caso paciente tenha sido selecionado
func _on_bt_nomePaciente_pressed():
	#Se não começou iniciar jogo
	if playernameline.text != "":
		_open_fases()


func end_game():
	count_obstaculo = 0
	last_obst = false
	df_obstaculo_atual = -1
	for k in obs_ativos.keys():
		_obstaculo_destruido(k,0)
		obs_ativos.erase(k)
	for c in SpawnG.get_node("ObstaculosInvocados").get_children():
		c.queue_free()
	Ponto_ou_Erro = 0
	df_atual = []
	df_todos = backup_df_todos
	
	df_at_indice = 1000
	SpawnTimer.stop()
	sd_Musica.stop()
	emit_signal("show_score",points,possible_points,historico)
	TimerHistorico.stop()
	
