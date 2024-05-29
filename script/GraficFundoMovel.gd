extends Node2D

onready var line = preload("res://scenes/LevelEditor/LinhaInfinita.tscn")
onready var lastline = $Linhas/Linha

var scroll_speed = 40
var count_sec = 2

func _process(delta):
	if lastline.get_pos_borda().y > 0:
		_new_line()
	if Input.is_action_just_released("scroll_down") and position.y > 810:
		position.y -=scroll_speed
	elif Input.is_action_just_released("scroll_up"):
		position.y +=scroll_speed

func _new_line():
	var lin_inst = line.instance()
	$Linhas.add_child(lin_inst)
	lin_inst.global_position = lastline.get_pos_borda()
	lastline.delete_borda()
	lastline = lin_inst
	lastline.set_sec(count_sec)
	count_sec+=1
