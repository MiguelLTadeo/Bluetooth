extends Control

@onready var opt_btn = $VBoxContainer/OptionButton

func _ready():
	pass

func escreve_op_button():
	#funcao para popular o opt_btn com os dispositivos
	opt_btn.clear()
	var index = 0
	for disp in BluetoothScan.dispositivos.keys():
		opt_btn.add_item(disp,index)
		index+1

func _on_option_button_item_selected(index: int) -> void:
	#ao selecionar um novo dispositivo o nome global muda
	BluetoothScan.disp_nome = $VBoxContainer/OptionButton.get_item_text(index)

func _on_escanear_pressed() -> void:
	#ao pressionar o botao ESCANEAR a funçao execScan e chamada e o opt_btn e preenchido
	BluetoothScan.execScan()
	await get_tree().create_timer(3.0).timeout
	escreve_op_button()

func _on_conectar_pressed() -> void:
	#executa a conexao e leitura dos dadoss
	if BluetoothScan.disp_nome=="":
		print("execute o scan!")
	else:
		BluetoothLeitura.execConn()


func _on_services_pressed() -> void:
	BluetoothServices.execServ()
