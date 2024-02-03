extends Node2D

var player_prefab = preload("res://PLAYER.tscn")
var player_objects = {}

var objects_to_sync = {}
func on_game_start():
	for player_id in Relayconnect.ROOM_DATA.players:
		var player_instance = player_prefab.instantiate() 
		
		add_child(player_instance)
		player_instance.global_position = Vector2(randi_range(300,600),130)
		player_objects[player_id] = player_instance
		player_instance.player_id = player_id
		if player_id == multiplayer.multiplayer_peer.get_unique_id():
			print(multiplayer.multiplayer_peer.get_unique_id())
			player_instance.is_local_player = true


func sync_player_pos_all(pos : Vector2):
	for player_id in Relayconnect.ROOM_DATA.players:
		if player_id != multiplayer.multiplayer_peer.get_unique_id():
			sync_player_pos_rpc.rpc_id(player_id,pos)

@rpc("any_peer","call_remote","unreliable")
func sync_player_pos_rpc(pos : Vector2):
	var sender_id = multiplayer.get_remote_sender_id()
	if player_objects.has(sender_id):
		player_objects[sender_id].global_position = pos

@rpc("any_peer","reliable")
func spawn_object_rpc(object_path : String,pos : Vector2,rotation : float,object_id : int):
	var object_to_spawn = load(object_path) as PackedScene
	var object_instance = object_to_spawn.instantiate() 
	add_child(object_instance)
	objects_to_sync[object_id] = object_instance


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
