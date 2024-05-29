extends Spatial



func get_borda_pos():
	return $Borda.global_translation

func _remove_borda():
	$Borda.queue_free()


func _on_TimerDie_timeout():
	queue_free()

func _som_rio():
	$AudioRio.play()
