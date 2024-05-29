extends CPUParticles

#Emitir partiucla
func _ready():
	emitting = true

#Checa se particula não é mais emitida e pode ser removida
func _process(delta):
	if emitting == false:
		queue_free()
