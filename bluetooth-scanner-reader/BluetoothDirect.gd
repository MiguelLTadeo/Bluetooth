extends Node

var bluetooth_manager: BluetoothManager
var target_device_name = "ESP32_MPU_BLE"
var device: BleDevice

const UUID_SERVICO = "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
const UUID_CHAR    = "beb5483e-36e1-4688-b7f5-ea07361b26a8"

@export var posicao: String = "3"

func conect(nome_disp: String):
	bluetooth_manager = BluetoothManager.new()
	add_child(bluetooth_manager)
	
	if nome_disp!="":
		target_device_name = nome_disp

	
	bluetooth_manager.adapter_initialized.connect(_on_initialized)
	bluetooth_manager.device_discovered.connect(_on_device_found)
	bluetooth_manager.scan_stopped.connect(_on_scan_done)
	
	bluetooth_manager.initialize()

func _on_initialized(success: bool, error: String):
	if success:
		bluetooth_manager.start_scan(2.0)

func _on_device_found(info: Dictionary):
	var name = info.get("name", "")
	if name == target_device_name:
		print("Dispositivo alvo encontrado!")
		bluetooth_manager.stop_scan()
		connect_to_target(info.get("address"))


func _on_scan_done():
	print("Scan completo.")

func connect_to_target(address: String):
	device = bluetooth_manager.connect_device(address)
	if device:
		device.connected.connect(_on_connected)
		device.services_discovered.connect(_on_services_found)
			
		device.characteristic_notified.connect(_on_data_update)
		device.connect_async()
		
func _on_services_found(services:Array):
	print("Serviços encontrados.")
	device.subscribe_characteristic(UUID_SERVICO, UUID_CHAR)

func _on_data_update(char_uuid: String, data: PackedByteArray):
	
	if char_uuid.to_lower() == UUID_CHAR.to_lower():
		var leitura = data.get_string_from_utf8()
		
		BluetoothDirect.posicao = leitura
		
		print("Dado recebido: ", leitura)

func _on_connected():
	print("Dispositivo Conectado!")
	device.discover_services()

func _exit_tree():
	if device and device.is_connected():
		device.disconnect()
	if bluetooth_manager:
		bluetooth_manager.stop_scan()
