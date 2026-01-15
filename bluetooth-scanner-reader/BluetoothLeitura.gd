extends Node

var bluetooth_manager: BluetoothManager
var sensor_device: BleDevice

# UUIDs do servico e caracteristica, provavelmente todos os nos-sensores vao ter o mesmo(isso e declarado no .ino) 
const UUID_SERVICO = "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
const UUID_CHAR    = "beb5483e-36e1-4688-b7f5-ea07361b26a8"

# vai armazenar globalmente o angulo do no-sensor, por padrao sendo 3
@export var posicao:int = 3

func execConn():
	#Cria uma instancia do BluetoothManager
	bluetooth_manager = BluetoothManager.new()
	add_child(bluetooth_manager)
	#inicializa o adaptador bluetooth
	bluetooth_manager.adapter_initialized.connect(_on_initialized)
	
	bluetooth_manager.initialize()

func _on_initialized(success: bool, error: String):
	if success:
		print("Bluetooth inicializado. Tentando conectar...")
		#realiza a conexao direta com o nome do dispositivo escolhido
		conectar_direto(BluetoothScan.disp_nome)
	else:
		print("Erro ao inicializar Bluetooth: ", error)

func conectar_direto(Disp_nome: String):
	if BluetoothScan.dispositivos.has(Disp_nome):
		#com o nome do dispositivo encontramos seu endereço e realizamos a conexao via connect_device
		var address = BluetoothScan.dispositivos[Disp_nome]
		print("Conectando ao objeto: ", Disp_nome, " [", address, "]")
		
		sensor_device = bluetooth_manager.connect_device(address)
		
		#se a conexao funcionou
		if sensor_device:
			sensor_device.connected.connect(_on_sensor_connected)
			sensor_device.services_discovered.connect(_on_services_found)
			
			sensor_device.characteristic_notified.connect(_on_data_update)
			
			sensor_device.connect_async()
	else:
		print("Erro: Dispositivo não encontrado na lista Options.")

func _on_sensor_connected():
	print("Dispositivo conectado! Mapeando serviços...")
	sensor_device.discover_services()

func _on_services_found(services: Array):
	#ao encontrar os serviços usamos o subscribe_characteristic para captar as mudanças de valor do angulo 
	for s in services:
		if s.uuid==UUID_SERVICO:
			print(s)
	print("Serviços encontrados. Ativando leitura constante (Subscribe)...")
	sensor_device.subscribe_characteristic(UUID_SERVICO, UUID_CHAR)

func _on_data_update(char_uuid: String, data: PackedByteArray):
	#aqui e realizada a traduçao e armazenamento do valor da posiçao na variavel global
	if char_uuid.to_lower() == UUID_CHAR.to_lower():

		var leitura = data.get_string_from_utf8()
		
		BluetoothLeitura.position = leitura
		
		print("Dado recebido: ", leitura)
