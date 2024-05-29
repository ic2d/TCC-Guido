extends Spatial


onready var Floor1 = preload("res://Modelos/InfinityMap/Floors/Floor1.tscn")
onready var f_1 = preload("res://Modelos/InfinityMap/Floors/Floor1.glb")
onready var f_2 = preload("res://Modelos/InfinityMap/Floors/Floor2.glb")
onready var f_3 = preload("res://Modelos/InfinityMap/Floors/Floor3.glb")
onready var fb_1 = preload("res://Modelos/InfinityMap/Floors/FloorBridge.glb")

onready var prop1 = preload("res://Modelos/InfinityMap/Props/Props1.glb")
onready var prop2 = preload("res://Modelos/InfinityMap/Props/Props2.glb")
onready var prop3 = preload("res://Modelos/InfinityMap/Props/Props3.glb")
onready var prop4 = preload("res://Modelos/InfinityMap/Props/Props4.glb")
onready var prop5 = preload("res://Modelos/InfinityMap/Props/Props5.glb")
onready var prop6 = preload("res://Modelos/InfinityMap/Props/Props6.glb")

onready var Floor_Atual = $FloorAtivo/Floor1

var floor_models_forest = []
var floor_models_bridge = []

var prop_models_forest = []
var speed = 2

func _ready():
	randomize()
	floor_models_forest = [f_1,f_2,f_3]
	floor_models_bridge = [fb_1]
	prop_models_forest = [prop1, prop2,prop3,prop4,prop5,prop6]
func _process(delta):
	for f in $FloorAtivo.get_children():
		f.translation.z +=speed*delta
	if Floor_Atual.get_borda_pos().z -global_translation.z > 0:
		var inst = Floor1.instance()
		$FloorAtivo.add_child(inst)
		inst.global_translation = Floor_Atual.get_borda_pos()
		Floor_Atual._remove_borda()
		
		#Escolhe modelos
		var p = randi() % 100
		var inst_f
		var choice = -1
		if p < 90: #Floresta
			choice = 1
			var i = randi() % floor_models_forest.size()
			inst_f = floor_models_forest[i].instance()
		else: #RIO
			choice = 2
			var i = randi() % floor_models_bridge.size()
			inst_f = floor_models_bridge[i].instance()
			inst._som_rio()
		
		Floor_Atual = inst
		Floor_Atual.add_child(inst_f)
		if choice == 1:
			var i = randi() % prop_models_forest.size()
			var instprop = prop_models_forest[i].instance()
			Floor_Atual.add_child(instprop)

