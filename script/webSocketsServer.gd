extends Node

#Sinais utilizados pelo jogo
signal new_accel_data(data)
signal connected(to_url)
signal disconnected()

# Porta do websocket
const PORT = 9080

# Criar instancia de websocket
var server = WebSocketServer.new()

func _ready():
	# Conecta sinais as funções do websocket
	server.connect("client_connected", self, "_connected")
	server.connect("client_disconnected", self, "_disconnected")
	server.connect("client_close_request", self, "_close_request")
	server.connect("data_received", self, "_on_data")
	
	# Começa a ouvir na porta escolhida
	var err = server.listen(PORT)
	
	#Caso aconteça um erro
	if err != OK:
		print("Unable to start server")
		set_process(false)

		
func _process(delta):
	# Função responsável pelas transferencias de dados e emissões de sinais
	server.poll()

#Conectado novo cliente com id e protocolo
func _connected(id, proto):
	print("Client %d connected with protocol: %s" % [id, proto])
	#Emissão de sinal passando ip
	emit_signal("connected", server.get_peer_address(id))

#Cliente deseja fechar conecção passando um código e motivo
func _close_request(id, code, reason):
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

#Cliente desconectou e variável apontando se avisou que disconectaria
func _disconnected(id, was_clean = false):
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	
	#Sinal por desconectar
	emit_signal("disconnected")

#Dado foi enviado para o jogo
func _on_data(id):
	#Recebendo pacote enviado peo cliente
	var pkt = server.get_peer(id).get_packet()
	#print("Got data from client %d: %s" % [id, pkt.get_string_from_utf8()])

	#Emitindo sinal e dados para o jogo
	emit_signal("new_accel_data",  pkt.get_string_from_utf8())
