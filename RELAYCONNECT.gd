extends Node2D

### ALL CODE PERTAINING TO RELAY CONNECTION
signal JOIN_SUCCESS
signal JOIN_FAIL
signal HOST_SUCCESS
signal HOST_FAIL

@export var typed_room_code= ""
var ROOM_DATA = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	var relay_connect = ENetMultiplayerPeer.new()
	var error = relay_connect.create_client("127.0.0.1",25566)
	if error:
		return(error)
		
	multiplayer.multiplayer_peer = relay_connect
	multiplayer.peer_connected.connect(_on_player_connected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(multiplayer.multiplayer_peer.get_connection_status())
	pass

func _on_player_connected(id:int):
	_resgister_player.rpc_id(0)

	
func host():
	if multiplayer.multiplayer_peer.CONNECTION_CONNECTED:
		host_rpc.rpc_id(0)

func join():
	if multiplayer.multiplayer_peer.CONNECTION_CONNECTED:
		join_rpc.rpc_id(0,typed_room_code)

@rpc("any_peer","call_remote","reliable")
func host_rpc():
	pass

@rpc("authority","call_remote","reliable")
func host_success_rpc(room_code,room_info):
	print(room_info)
	HOST_SUCCESS.emit()

@rpc("any_peer","call_remote","reliable")
func join_rpc(room_code):
	pass

@rpc("authority","call_remote","reliable")
func join_success_rpc(room_code):
	JOIN_SUCCESS.emit()
	pass

@rpc("any_peer","call_remote","reliable")
func _resgister_player():
	pass

@rpc("authority","reliable")
func sync_room_data_rpc(room_data):
	ROOM_DATA = room_data
	print(ROOM_DATA)


func _on_line_edit_text_changed(new_text):
	typed_room_code = new_text
	pass # Replace with function body.

### END OF RELAY SERVER CONNECTION 


func change_scene_all(scene_path):
	for player_id in ROOM_DATA.players:
		change_scene_rpc.rpc_id(player_id,scene_path)
	
@rpc("any_peer","call_local","reliable")
func change_scene_rpc(scene_path):
	get_tree().change_scene_to_file(scene_path)
