extends Control

onready var bt_pac = preload("res://scenes/Select_Paciente/bt_paciente.tscn")
onready var dir = Directory.new()

var pacienteid = -1

signal jogo
signal openEditor
signal select_tela

func _ready():
	#Pega ips
	var ips = IP.get_local_addresses()
	
	var ipv4 = ""
	for ip in ips:
		if (ip[0] =="1" and ip[1] == "9" and ip[2] == "2") or (ip[0] =="1" and ip[1] == "0") or (ip[0] =="1" and ip[1] == "7" and ip[2] == "2"):
			ipv4 += ip + " "
	#Criar função para pegar ipv4
	#for i in range(len(ips)):
	#	print(str(i)+" "+str(ips[i]))
	
	#Foca teclado na linha
	
	
	#Pega quarto ip da lista
	$TelaConectar/ServerIp.text = str(ipv4)
	$TelaConectar/Telainicial.visible = true
	
	

#Define texto do Ip do cliente e abre menu seleção
func set_ip(ip):
	$AudioControleConectou.play()
	$TelaConectar/MarginContainer/HBoxContainer/ClientIP.text = ip
	$TelaConectar.visible = false
	
	#Abre Tela de seleção
	abrir_menu_select()

func abrir_menu_select():
	$TelaMenu.visible = true

#Modifica texto de status
func set_status(status):
	$TelaConectar/MarginContainer/HBoxContainer/Status.text = status

#Remove texto de que precisa apertar par acomeçar jogo
func set_started(val):
	$TelaConectar/Telainicial.visible = !val
	$TelaConectar/Started.visible = !val
	$TelaConectar/ServerIp.visible = !val
	$TelaConectar/LbServer.visible = !val
	$TelaConectar/MarginContainer/HBoxContainer.visible = !val
	$TelaPlayerEscolha.visible = !val


func _on_bt_paciente_pressed():
	$TelaMenu.visible = false
	$TelaPlayerEscolha.visible = true
	$TelaPlayerEscolha/TypePlayerName.text = ""
	$TelaPlayerEscolha/TypePlayerName.grab_focus()
	
	var list_pac = []
	var bt_id = 0
	pacienteid = -1
	
	for f in $TelaPlayerEscolha/ScrollPacientes/GridPacientes.get_children():
		f.queue_free()
	
	if dir.open("Pacientes") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				list_pac.append(file_name)
				var newbt = bt_pac.instance()
				newbt.connect("paciente_selecionado",self,"_paciente_selecionado")
				newbt._set_button(bt_id,file_name)
				$TelaPlayerEscolha/ScrollPacientes/GridPacientes.add_child(newbt)
				bt_id +=1
			file_name = dir.get_next()
	emit_signal("jogo")

func _paciente_selecionado(id):
	pacienteid = id
	for f in $TelaPlayerEscolha/ScrollPacientes/GridPacientes.get_children():
		if f.level_id != id:
			f.selected = false
		else:
			$TelaPlayerEscolha/TypePlayerName.text = f.get_nome()


func _on_bt_editor_pressed():
	$TelaMenu.visible = false
	emit_signal("openEditor")


#Voltar da janela de escolher paciente
func _on_bt_Voltar_pressed():
	$TelaMenu.visible = true
	$TelaPlayerEscolha.visible = false
	release_focus()
	emit_signal("select_tela")
	
