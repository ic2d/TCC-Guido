extends Control

onready var scroll_bar = $HScrollBar
onready var graf_movel = $ViewportContainer/Viewport/movel
onready var graf_bg = $ViewportContainer/Viewport/movel/graf_bg
onready var list_point = $ViewportContainer/Viewport/movel/Points
onready var points = preload("res://scenes/Grafico_desempenho/point_graf.tscn")
onready var graf_line = $ViewportContainer/Viewport/movel/graf_line
onready var graf_line2 = $ViewportContainer/Viewport/movel/graf_line2

onready var viewport = $ViewportContainer/Viewport


onready var largura_x_original = graf_bg.rect_size.x

var temp = []
var limite_scroll = 26

func _process(delta):
	#graf_movel.rect_position.x = -144 - scroll_bar.value*40
	if visible and !$FileSaveGraf.visible:
		$ViewportContainer.rect_position.x = -133- scroll_bar.value*40
		$ViewportContainer.rect_position.y = -91
	else:
		$ViewportContainer.rect_position = Vector2(1018,991)
func open_graf():
	$ViewportContainer.rect_position = Vector2(-133,-91)
	visible = true
	
func close_graf():
	$ViewportContainer.rect_position = Vector2(1018,991)
	$FileSaveGraf.visible = false
	visible = false
	
func load_graf(historico):
	viewport.size.x = len(historico["historico"])*40 + 72
	for h in historico["historico"]:
		temp.append(h[0])
		var pt1 = points.instance()
		pt1.rect_position.y = 446*h[1]/180
		pt1.rect_position.x = (len(temp)-1)*largura_x_original
		pt1.modulate = Color(0,0,0.5,0.5)
		var pt2 = points.instance()
		pt2.rect_position.y = 446*h[2]/180
		pt2.rect_position.x = (len(temp)-1)*largura_x_original
		pt2.modulate = Color(1,0,0,0.5)
		
		var pt3 = points.instance()
		if h[3] == "Acerto":
			pt3.rect_position.y = 446*h[1]/180
			pt3.rect_position.x = (len(temp)-1)*largura_x_original
			pt3.modulate = Color(0,1,0,0.2)
			pt3.rect_scale.x *= 3
			pt3.rect_scale.y *= 10
			list_point.add_child(pt3)
		elif h[3] == "Erro":
			pt3.rect_position.y = 446*h[1]/180
			pt3.rect_position.x = (len(temp)-1)*largura_x_original
			pt3.modulate = Color(0.5,0,0,0.2)
			pt3.rect_scale.x *= 3
			pt3.rect_scale.y *= 10
			list_point.add_child(pt3)
		graf_line.add_point(pt1.rect_global_position)
		graf_line2.add_point(pt2.rect_global_position)
		list_point.add_child(pt1)
		list_point.add_child(pt2)
	scroll_bar.max_value = max(0,len(temp)-limite_scroll)
	graf_bg.rect_scale.x*=len(temp)
	
func save_img():
	$FileSaveGraf.popup()
	
func save_img_file(path):
	var img = viewport.get_texture().get_data()
	img.flip_y()
	img.save_png(path+".png")


