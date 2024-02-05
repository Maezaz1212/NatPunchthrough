extends Node2D

var Game_started = false
var player_prefab = preload("res://SCENES/Player.tscn")

var objects_to_sync = {}

var positions_dict = {}
var CHARS = "1234567890";
func create_unique_object_code():
	var id = ""
	for n in 7:
		var random_number =  randi_range(0,CHARS.length() -1)
		var random_char = CHARS[random_number]
		id+=random_char
		
	if objects_to_sync.has(id):
		return create_unique_object_code()
	
	return id
	
func  _process(delta):
	if Game_started and Relayconnect.IS_HOST:
		sync_all_objects_pos()
		
# START GAME AND SPAWN PLAYERS
func on_game_start():
	
	if(!Relayconnect.IS_HOST):
		return
	for player_id in Relayconnect.ROOM_DATA.players:
		var pos = Vector2(randi_range(300,600),-300)
		var player = spawn_object("res://SCENES/Player.tscn",pos,0)
		player.owner_id  = player_id
	Game_started = true;
func spawn_object(object_path : String,pos : Vector2,rot : float):
	var object_id = create_unique_object_code()
	var object_to_spawn = load(object_path) as PackedScene
	var object_instance = object_to_spawn.instantiate() 
	add_child(object_instance)
	object_instance.global_position = pos
	object_instance.global_rotation_degrees = rot
	objects_to_sync[object_id] = object_instance
	print(object_id)
	Relayconnect.call_rpc_room(spawn_object_rpc,[object_path,pos,rot,object_id],false)
	return object_instance

@rpc("any_peer","call_local","reliable")
func spawn_object_rpc(object_path : String,pos : Vector2,rot : float,object_id : String):
	#print(object_id)
	var object_to_spawn = load(object_path) as PackedScene
	var object_instance = object_to_spawn.instantiate() 
	add_child(object_instance)
	object_instance.global_position = pos
	object_instance.global_rotation_degrees = rot
	objects_to_sync[object_id] = object_instance

@rpc("any_peer","call_local","reliable")
func change_scene_rpc(scene_path : String):
	get_tree().change_scene_to_file(scene_path)

func sync_all_objects_pos():
	for object_id in objects_to_sync:
		positions_dict[object_id] = objects_to_sync[object_id].global_position
	
	Relayconnect.call_rpc_room(sync_all_objects_rpc,[positions_dict],false)

@rpc("any_peer","call_remote","unreliable")
func sync_all_objects_rpc(positions_dict):
		for object_id in positions_dict:
			
			objects_to_sync[object_id].global_position = positions_dict[object_id]

