extends Node

var bluetooth_manager: BluetoothManager

var connected_device: BleDevice

func execServ():
	bluetooth_manager = BluetoothManager.new()
	add_child(bluetooth_manager)
	bluetooth_manager.adapter_initialized.connect(_on_initialized)
	
	bluetooth_manager.initialize()
	

func _on_initialized(success: bool, error: String):
	if success:
		print("Bluetooth inicializado. Tentando conectar...")
		#realiza a conexao direta com o nome do dispositivo escolhido	
		connect_to_device(BluetoothScan.dispositivos[BluetoothScan.disp_nome])
	else:
		print("Erro ao inicializar Bluetooth: ", error)
	

func connect_to_device(address: String):
	if address==null:
		pass
	# Connect to device
	connected_device = bluetooth_manager.connect_device(address)
	if connected_device:
		# Connect device signals
		connected_device.connected.connect(_on_device_connected)
		connected_device.services_discovered.connect(_on_services_discovered)		
		# Start connection
		connected_device.connect_async()


func _on_device_connected():
	print("Device connected")
	# Discover services
	connected_device.discover_services()

func _on_services_discovered(services: Array):
	print("Discovered services:")
	for service in services:
		print("  Service: ", service.get("uuid"))
		for char in service.get("characteristics", []):
			print("    Characteristic: ", char.get("uuid"))
			print("    Properties: ", char.get("properties"))
