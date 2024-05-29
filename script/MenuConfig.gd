extends Control

onready var txtDel = $txtDelObj
onready var txtVel = $txtVelObj
onready var txtTam = $txtTamObj
onready var txtAngMax = $txtAngMax
onready var txtAngMin = $txtAngMin

var Del = 2
var Vel = 1
var Tam = 1
var AngMax = 180
var AngMin = 0
var json_res
var calib = false
var limit_control = 9.7
#Variaveis de intervalo do paciente
var ang_min_p = 0
var ang_max_p = 180
var ang_max = 180
var ang_min = 0

func _ready():
	txtDel.text = str(Del)
	txtVel.text = str(Vel)
	txtTam.text = str(Tam)
	txtAngMax.text = str(AngMax)
	txtAngMin.text = str(AngMin)

func _process(delta):
	#Sair da tela por botão
	if visible and Input.is_action_just_pressed("Pause"):
		visible = false
		get_tree().paused = false
	
	#Converter angulos pro padrão
	if calib and json_res != null:
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
		
	
		#ângulo para espada utilizando parâmetros configurados
		var angulo = abs(180*stepify(-(json_res.result["accel"]),0.02)/(2*limit_control)+90)
		angulo = round_place((ang_max-ang_min)*angulo/180+ ang_min,2)
		if calib_max_min == 1 and angulo> float($angulo_calib.text):
			$angulo_calib.text = str(angulo)
			$Img_Calib/PonteiroAngulo.rotation = deg2rad(180-angulo)
		elif calib_max_min == 2 and angulo< float($angulo_calib.text):
			$angulo_calib.text = str(angulo)
			$Img_Calib/PonteiroAngulo.rotation = deg2rad(180-angulo)


func _on_btSalvar_pressed():
	Del = txtDel.text
	Vel = txtVel.text
	Tam = txtTam.text
	AngMax = txtAngMax.text
	AngMin = txtAngMin.text
	
	#Passar valores para root
	var tree = get_parent().get_parent()
	tree.setGameValues(Del,Vel,Tam,AngMax,AngMin)

signal sig_calibrar

var calib_max_min = -1

func bt_calib_max():
	$Img_Calib.visible = true
	$angulo_calib.visible = true
	$Timer_calib.start()
	emit_signal("sig_calibrar")
	calib = true
	calib_max_min = 1

func Timer_Calibrar():
	$Img_Calib.visible = false
	$angulo_calib.visible = false
	emit_signal("sig_calibrar")
	calib = false
	if calib_max_min == 1:
		txtAngMax.text = $angulo_calib.text
	elif calib_max_min == 2:
		txtAngMin.text = $angulo_calib.text
func bt_calib_min():
	$Img_Calib.visible = true
	$angulo_calib.visible = true
	$Timer_calib.start()
	emit_signal("sig_calibrar")
	calib = true
	calib_max_min = 2

#Função para arredondar casas decimais
func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))


func _on_btVoltar_pressed():
	visible = false
