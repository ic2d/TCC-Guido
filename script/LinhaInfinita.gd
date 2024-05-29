extends Sprite

func get_pos_borda():
	return $BordaLinha.global_position
	
func delete_borda():
	$BordaLinha.queue_free()
func set_sec(sec):
	$segundo_label.text = str(sec)
