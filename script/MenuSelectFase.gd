extends Control

onready var button = preload("res://scenes/Select_Fase/bt_fase.tscn")

var level_id = -1
var game_mode = 0

signal start_game
signal SelectF_aberto
signal fechar_tela_fase

func add_button(fase_id,file_name):
	var newbt = button.instance()
	newbt.connect("fase_selecionado",self,"_fase_selecionada")
	newbt._set_button(fase_id,file_name)
	$ScrollContainer/GridFases.add_child(newbt)

func abrir_menu():
	#Limpar grid para abrir novas fases
	for f in $ScrollContainer/GridFases.get_children():
		f.queue_free()
	level_id = -1
	visible = true
	emit_signal("SelectF_aberto")

func _on_bt_jogar_pressed():
	print(level_id)
	print(game_mode)
	if level_id > -1 and game_mode ==0:
		emit_signal("start_game",level_id,game_mode,null)
		visible = false
	elif game_mode == 1:
		emit_signal("start_game",level_id,game_mode,null)
		visible = false

func _fase_selecionada(id):
	level_id = id
	var c = $ScrollContainer/GridFases.get_children()
	for f in c:
		if f.level_id != id:
			f.selected = false


func _on_optionbt_modo_jogo_item_selected(index):
	game_mode = index


func _on_bt_Voltar_pressed():
	visible = false
	emit_signal("fechar_tela_fase")
