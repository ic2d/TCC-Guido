extends Control

signal encerrar_sessao
signal jogar_de_novo
signal abriuScore

var hist

func _show_score(score,max_score,historico):
	hist = historico
	load_graf()
	
	$AudioVitoria.play()

	visible = true
	$lb_pontos.text = str(score) + " / " + str(max_score)
	if score > 2.0*max_score/3.0:
		$Star3.visible = true
		$Star2.visible = true
	elif score > max_score/3.0:
		$Star2.visible = true
	emit_signal("abriuScore")

func _on_bt_encerrar_pressed():
	emit_signal("encerrar_sessao")


func _on_bt_jogarOutra_pressed():
	emit_signal("jogar_de_novo")
	visible = false

func load_graf():
	$GraficoDesempenho.load_graf(hist)


func _on_bt_grafico_pressed():
	if !$GraficoDesempenho.visible:
		$GraficoDesempenho.open_graf()
	else:
		$GraficoDesempenho.close_graf()
