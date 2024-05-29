extends Control

onready var MenuFile = $MenuButtonFile
onready var MenuAjuda = $MenuButtonAjuda
onready var ObstsFundoMovel = $TextureMenu/GraficFundoMovel/Obstaculos
onready var obEditor = preload("res://scenes/LevelEditor/ObstaculoEditor.tscn")

#Sorter para array
class CustomSorter:
	#Sort baseado na variável tempo do dictionary
	static func sort_tempo(a,b):
		return a["tempo"] < b["tempo"]

var str_bt_criar = "Criar Novo Desafio (ctrl+n)"
var str_bt_abrir = "Abrir Desafio Existente"
var str_bt_salvar = "Salvar (ctrl+s)"
var str_bt_salvarc = "Salvar Como (ctrl+shift+s)"
var str_bt_adicionar = "Adicionar Desafio ao Projeto Atual"
var str_bt_sair = "Sair do Editor"

var str_bt_ajuda = "Ajuda"
var str_bt_credito = "Créditos"

var angulo_tip = 1

var desafio_aberto
var path_current_file = ""
var index_global = 0
var indice_selecionado = -1
var lis_obst = []

var dragging_angulo = false

signal start_game

func _ready():
	MenuFile.get_popup().add_item(str_bt_criar)
	MenuFile.get_popup().add_item(str_bt_abrir)
	MenuFile.get_popup().add_item(str_bt_salvar)
	MenuFile.get_popup().add_item(str_bt_salvarc)
	MenuFile.get_popup().add_item(str_bt_adicionar)
	MenuFile.get_popup().add_item(str_bt_sair)
	
	MenuAjuda.get_popup().add_item(str_bt_ajuda)
	MenuAjuda.get_popup().add_item(str_bt_credito)
	
	MenuFile.get_popup().connect("id_pressed",self,"item_file_selecionado")
	MenuAjuda.get_popup().connect("id_pressed",self,"item_ajuda_selecionado")



func _process(delta):
	if Input.is_action_just_pressed("ctrlshifts"):
		$SalvarFaseComo.popup()
	elif Input.is_action_just_pressed("ctrls"):
		save_padrao()
	if Input.is_action_just_pressed("ctrln"):
		criar_novo_desafio()
	
	if dragging_angulo:
		angulo_txt_mudou(str($TextureMenu/Slide_angulo.value))
	
	if angulo_tip ==1:
		$TextureMenu/linedit_angulo.text = str($TextureMenu/Slide_angulo.value)
	else:
		$TextureMenu/Slide_angulo.value = float($TextureMenu/linedit_angulo.text)
		if Input.is_action_just_pressed("ui_accept"):
			$TextureMenu/bt_Test.grab_focus()


func item_file_selecionado(id):
	var nome_item = MenuFile.get_popup().get_item_text(id)
	match nome_item:
		str_bt_criar:
			criar_novo_desafio()
		str_bt_abrir:
			$AbrirFase.popup()
		str_bt_salvar:
			save_padrao()
		str_bt_salvarc:
			$SalvarFaseComo.popup()
		str_bt_adicionar:
			$AdicionarFase.popup()
		str_bt_sair:
			get_tree().quit()

func item_ajuda_selecionado(id):
	var nome_item = MenuAjuda.get_popup().get_item_text(id)
	match nome_item:
		str_bt_ajuda:
			$HelpWindow.popup()
		str_bt_credito:
			OS.shell_open("https://github.com/guidoMoreira")

func _on_linedit_angulo_focus_entered():
	angulo_tip = 0


func _on_linedit_angulo_focus_exited():
	angulo_tip = 1

func _on_AbrirFase_file_selected(path):
	criar_novo_desafio()
	path_current_file = path
	var f = File.new()
	f.open(path,File.READ)
	desafio_aberto = parse_json(f.get_as_text())
	f.close()
	
	index_global = 0
	indice_selecionado = -1
	lis_obst = []
	
	#Erro pos não existe desafio no JSON
	if not desafio_aberto.has("desafio"):
		return

	for d in desafio_aberto["desafio"]:
		var new_obst = obEditor.instance()
		set_obstPos(new_obst,d["angulo"],d["tempo"])
		new_obst.set_indice(index_global)
		index_global+=1
		new_obst.connect("selected",self,"_obst_selecionado")
		ObstsFundoMovel.add_child(new_obst)
		lis_obst.append(new_obst)

func _on_SalvarFaseComo_file_selected(path):
	path_current_file = path
	var f = File.new()
	if desafio_aberto != null:
		var copy_desaf = desafio_aberto["desafio"].duplicate()
		copy_desaf.sort_custom(CustomSorter,"sort_tempo")
		var copy = {"desafio":copy_desaf}
		if not ".JSON" in path and not ".json" in path:
			path+=".JSON"
		f.open(path,File.WRITE)
		f.store_string(JSON.print(copy, " "))
		f.close()

func _on_AdicionarFase_file_selected(path):
	path_current_file = path
	var f = File.new()
	f.open(path,File.READ)
	var desafio_adicionar = parse_json(f.get_as_text())
	f.close()
	

	var last_temp = desafio_aberto["desafio"][-1]["tempo"]
	for d in desafio_adicionar["desafio"]:
		var new_obst = obEditor.instance()
		d["tempo"] += last_temp
		
		set_obstPos(new_obst,d["angulo"],d["tempo"])
		new_obst.set_indice(index_global)
		index_global+=1
		desafio_aberto["desafio"].append(d)
		
		new_obst.connect("selected",self,"_obst_selecionado")
		ObstsFundoMovel.add_child(new_obst)
		lis_obst.append(new_obst)
#Obstáculo selecionado
func _obst_selecionado(ind):
	indice_selecionado = ind
	for f in ObstsFundoMovel.get_children():
		var indice = f.index
		f.select = indice == ind
		if indice == ind:
			$TextureMenu/lb_index.text = str(ind)
			if desafio_aberto["desafio"][indice]["angulo"]>-1:
				$TextureMenu/linedit_angulo.text = str(desafio_aberto["desafio"][indice]["angulo"])
				$TextureMenu/Slide_angulo.value = float(desafio_aberto["desafio"][indice]["angulo"])
				$TextureMenu/CheckButtonRandom.pressed = false
				$TextureMenu/BlockAngulo.visible = false
			else:
				$TextureMenu/CheckButtonRandom.pressed = true
				$TextureMenu/BlockAngulo.visible = true
			$TextureMenu/linedit_vel.text = str(desafio_aberto["desafio"][indice]["velocidade"])
			$TextureMenu/linedit_tam.text = str(desafio_aberto["desafio"][indice]["tamanho"])
			$TextureMenu/linedit_asset.text = str(desafio_aberto["desafio"][indice]["asset"])
			$TextureMenu/linedit_ponto.text = str(desafio_aberto["desafio"][indice]["ponto"])
			$TextureMenu/linedit_tempo.text = str(desafio_aberto["desafio"][indice]["tempo"])

func save_padrao():
	var f = File.new()
	if desafio_aberto != null and path_current_file != "":
		var copy_desaf = desafio_aberto["desafio"].duplicate()
		copy_desaf.sort_custom(CustomSorter,"sort_tempo")
		var copy = {"desafio":copy_desaf}
		f.open(path_current_file,File.WRITE)
		f.store_string(JSON.print(copy, " "))
		f.close()
	else:
		$SalvarFaseComo.popup()


func _on_bt_Add_pressed():
	if desafio_aberto != null:
		var new_obst = obEditor.instance()
		new_obst.set_indice(index_global)
		index_global+=1
		var new_d = {"angulo": 90,"tempo": 0.1,"velocidade":1,"tamanho": 1,"asset": 0,"ponto": 1}
		desafio_aberto["desafio"].append(new_d)
		new_obst.connect("selected",self,"_obst_selecionado")
		ObstsFundoMovel.add_child(new_obst)
		set_obstPos(new_obst,new_d["angulo"],new_d["tempo"]) 
		lis_obst.append(new_obst)
		new_obst._on_TextureButton_pressed()
		$AudioAdd.play()
	else:
		$FaseNaoCriadaWindow.popup()

func _on_bt_Remove_pressed():
	if indice_selecionado != -1:
		lis_obst.pop_at(indice_selecionado).queue_free()
		desafio_aberto["desafio"].remove(indice_selecionado)
		reset_atributos()
		index_global -=1
		$AudioRemove.play()
		for o in lis_obst:
			if o.index > indice_selecionado:
				o.index -=1
	indice_selecionado = -1

func _on_bt_Duplicar_pressed():
	if indice_selecionado != -1:
		var dup_d = {"angulo":0, "tempo":0.1, "velocidade":1, "tamanho":1, "asset":0, "ponto":1}
		copy_obst_data(dup_d,desafio_aberto["desafio"][indice_selecionado])
		desafio_aberto["desafio"].append(dup_d)
		var new_bt = obEditor.instance()
		new_bt.set_indice(index_global)
		index_global+=1
		new_bt.set_pos(lis_obst[indice_selecionado].get_pos())
		new_bt.connect("selected",self,"_obst_selecionado")
		ObstsFundoMovel.add_child(new_bt)
		lis_obst.append(new_bt)
		new_bt._on_TextureButton_pressed()
		$AudioAdd.play()
		
func velocidade_mudou(new_text):
	if float(new_text) <= 0:
		new_text = "1"
	$TextureMenu/linedit_vel.text = str(float(new_text))
	if indice_selecionado != -1:
		desafio_aberto["desafio"][indice_selecionado]["velocidade"] = float(new_text)


func tamanho_mudou(new_text):
	if float(new_text) <= 0:
		new_text = "1"
	$TextureMenu/linedit_tam.text = str(float(new_text))
	if indice_selecionado != -1:
		desafio_aberto["desafio"][indice_selecionado]["tamanho"] = float(new_text)


func asset_mudou(new_text):
	if int(new_text) < -1:
		new_text = "-1"
	$TextureMenu/linedit_asset.text = str(int(new_text))
	if indice_selecionado != -1 and int(new_text) >= -1:
		desafio_aberto["desafio"][indice_selecionado]["asset"] = int(new_text)


func ponto_mudou(new_text):
	if float(new_text) <= 0:
		new_text = "1"
	$TextureMenu/linedit_ponto.text = str(float(new_text))
	if indice_selecionado != -1:
		desafio_aberto["desafio"][indice_selecionado]["ponto"] = float(new_text)


func tempo_mudou(new_text):
	if float(new_text) <= 0:
		new_text = "0.1"
	$TextureMenu/linedit_tempo.text = str(float(new_text))
	if indice_selecionado != -1:
		desafio_aberto["desafio"][indice_selecionado]["tempo"] = float(new_text)
		
		var d = desafio_aberto["desafio"][indice_selecionado]
		set_obstPos(lis_obst[indice_selecionado],d["angulo"],d["tempo"])

func angulo_txt_mudou(new_text):
	if float(new_text) > 180:
		new_text = "180"
	elif float(new_text)<0:
		new_text = "0"
	$TextureMenu/linedit_angulo.text = str(float(new_text))
	if indice_selecionado != -1:
		desafio_aberto["desafio"][indice_selecionado]["angulo"] = float(new_text)
		var d = desafio_aberto["desafio"][indice_selecionado]
		set_obstPos(lis_obst[indice_selecionado],d["angulo"],d["tempo"])

func _on_Slide_angulo_drag_started():
	dragging_angulo = true


func _on_Slide_angulo_drag_ended(value_changed):
	dragging_angulo = false

func criar_novo_desafio():
	index_global = 0
	desafio_aberto = {"desafio":[]}
	path_current_file = ""
	indice_selecionado = -1
	lis_obst = []
	for filho in ObstsFundoMovel.get_children():
		filho.queue_free()
	reset_atributos()

func reset_atributos():
	$TextureMenu/lb_index.text = "-1"
	$TextureMenu/linedit_angulo.text = "90"
	$TextureMenu/Slide_angulo.value = 90.0
	$TextureMenu/linedit_vel.text = "1"
	$TextureMenu/linedit_tam.text = "1"
	$TextureMenu/linedit_asset.text = "0"
	$TextureMenu/linedit_ponto.text = "1"
	$TextureMenu/linedit_tempo.text = "1"

func copy_obst_data(to,from):
	to["angulo"] = from["angulo"]
	to["asset"] = from["asset"]
	to["ponto"] = from["ponto"]
	to["tamanho"] = from["tamanho"]
	to["tempo"] = from["tempo"]
	to["velocidade"] = from["velocidade"]
	


func _on_bt_Tes_Faset_pressed():
	if desafio_aberto != null and desafio_aberto["desafio"].size() > 0:
		get_tree().paused = false
		var data = desafio_aberto["desafio"].duplicate()
		emit_signal("start_game",-1,-2,data)#criar gamemode -2
		visible =false

func set_obstPos(new_obst,angulo,tempo):
	var newx = angulo/180.0 *-828 + 414#Baseado no tamanho da reta base
	var newy = tempo * -250 - 10
	
	new_obst.set_pos([newx,newy]) 


func _open_editor():
	get_tree().paused = true
	visible = true



func _on_CheckButtonRandom_toggled():
	$TextureMenu/BlockAngulo.visible = $TextureMenu/CheckButtonRandom.pressed
	if $TextureMenu/CheckButtonRandom.pressed and indice_selecionado > -1:
		desafio_aberto["desafio"][indice_selecionado]["angulo"] = -1
		var d = desafio_aberto["desafio"][indice_selecionado]
		set_obstPos(lis_obst[indice_selecionado],d["angulo"],d["tempo"])
	else:
		desafio_aberto["desafio"][indice_selecionado]["angulo"] = 90
		var d = desafio_aberto["desafio"][indice_selecionado]
		set_obstPos(lis_obst[indice_selecionado],d["angulo"],d["tempo"])
		_obst_selecionado(indice_selecionado)

signal voltar_menu_select
func _on_bt_Voltar_pressed():
	get_tree().reload_current_scene()
	
