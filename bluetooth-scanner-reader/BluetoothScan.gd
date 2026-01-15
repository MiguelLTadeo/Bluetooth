extends Node

var bluetooth_manager: BluetoothManager

#Declaraçao de um dicionario para armazenar os nomes e endereços 
@export var dispositivos:Dictionary ={}

#Declaraçao de uma variavel global para armazenar o nome do dispositivo a ser conectado
@export var disp_nome = ""

func execScan():
	# Cria uma inctancia do BluetoothManager
	BluetoothScan.dispositivos.clear()
	bluetooth_manager = BluetoothManager.new()
	add_child(bluetooth_manager)
	
	# Começa a escanear em busca de dispositivos bluetooth
	bluetooth_manager.adapter_initialized.connect(_on_adapter_initialized)
	# Ao descobrir um dispositivo verifica se ele tem um nome nulo e armazena ele no dicionario
	bluetooth_manager.device_discovered.connect(_on_device_discovered)
	# Quando scan para, o total de dispositivos descobertos e informado e seus nomes e endereços
	bluetooth_manager.scan_stopped.connect(_on_scan_stopped)
	
	# Inicializa o adaptador Bluetooths
	bluetooth_manager.initialize()

func _on_adapter_initialized(success: bool, error: String):
	if success:
		print("Bluetooth initialized successfully")
		bluetooth_manager.start_scan(2.0)
	else:
		print("Bluetooth initialization failed: ", error)

func _on_device_discovered(device_info: Dictionary):
	if device_info.get("name", 'Unknown') != null:
		print("Device found: ", device_info.get("name", "Unknown"))
		print("  Address: ", device_info.get("address"))
		print("  Signal strength: ", device_info.get("rssi"), " dBm")
		BluetoothScan.dispositivos[device_info.get("name", "Unknown")]=device_info.get("address")

func _on_scan_stopped():
	print("Scan complete")
	var devices = bluetooth_manager.get_discovered_devices()
	print("Total devices found: ", devices.size())
	print(BluetoothScan.dispositivos)
