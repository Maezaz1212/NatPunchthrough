extends Node2D

@export var JOIN_BUTTON : Button
@export var HOST_BUTTON : Button
@export var MessageLabel : RichTextLabel

@export var NameArea : BoxContainer
@export var ControllerLobbyPrefab : PackedScene

func _ready():
	Relayconnect.JOIN_SUCCESS.connect(_on_join_success)
	Relayconnect.JOIN_FAIL.connect(_on_join_fail)
	Relayconnect.HOST_SUCCESS.connect(_on_host_success)
	Relayconnect.HOST_FAIL.connect(_on_host_fail)
	Relayconnect.ON_RELAY_SERVER_FAIL.connect(_on_relay_server_fail)
	Relayconnect.ON_RELAY_SERVER_CONNECT.connect(_on_relay_server_connect)
	Input.joy_connection_changed.connect(on_joy_connection_changed)
	for controller_id in Input.get_connected_joypads():
		add_controller_lobby(controller_id)


func on_joy_connection_changed(device_id : int,connected : bool):
	if connected:
		add_controller_lobby(device_id)
	else:
		remove_controller_lobby(device_id)

func add_controller_lobby(device_id):
	var object_to_spawn = ControllerLobbyPrefab
	var object_instance = object_to_spawn.instantiate() 
	NameArea.add_child(object_instance)
	object_instance.controller_id = device_id
	object_instance.add_to_group("controller_lobby_prefabs")

func remove_controller_lobby(device_id):
	for node in get_tree().get_nodes_in_group("controller_lobby_prefabs"):
		if node.controller_id == device_id:
			node.queue_free()
			return
	
func _on_host_success():
	Relayconnect.call_rpc_room(GameManager.change_scene_rpc,["res://SCENES/RaceGame/GAME.tscn"])

func _on_host_fail():
	print("HOST FAIL")

func _on_join_success():
	print("JOIN SUCCESS")

func _on_join_fail(error_message):
	print(error_message)
	print("JOIN FAIL")

func _on_relay_server_connect():
	MessageLabel.text = ""
	JOIN_BUTTON.disabled = false
	HOST_BUTTON.disabled = false

func _on_relay_server_fail():
	MessageLabel.text = "CONNECTION TO RELAY SERVER FAILED"

func _on_host_button_down():
	Relayconnect.host()

func _on_join_button_down():
	Relayconnect.join()
	
func _on_line_edit_text_changed(new_text):
	Relayconnect.typed_room_code = new_text



	
