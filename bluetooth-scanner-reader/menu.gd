extends Control

@onready var input_nome = $VBoxContainer/LineEdit
@onready var leitura_label = $VBoxContainer/LEITURA

func _process(delta: float) -> void:
	leitura_label.text = "LEITURA: "+BluetoothDirect.posicao


func _on_conectar_esp_32_miguel_pressed() -> void:
	var nome_disp = input_nome.text
	print("Nome: ", nome_disp)
	BluetoothDirect.conect(nome_disp)

func _on_desconectar_pressed() -> void:
	BluetoothDirect._exit_tree()
	pass # Replace with function body.
