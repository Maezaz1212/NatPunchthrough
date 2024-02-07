extends Node2D

var Game_started = false
var player_prefab = preload("res://SCENES/Player.tscn")

var objects_to_sync = {}

var positions_dict = {}
var controller_puppet_masters = {}

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

func _ready():
	Input.joy_connection_changed.connect(on_joy_connection_changed)

func  _process(delta):
	if Game_started and Relayconnect.IS_HOST:
		sync_all_objects_pos()
	pass	
# START GAME AND SPAWN PLAYERS
func on_game_start():
	var pos = Vector2(randi_range(300,600),-300)
	
	#Setup Keyboard Player
	var puppet_master_keyboard = spawn_object("res://SCENES/Puppet_Master.tscn",Vector2.ZERO,0)
	puppet_master_keyboard.owner_id = multiplayer.get_unique_id()
	puppet_master_keyboard.controller = false;
	Relayconnect.call_rpc_room(puppet_master_keyboard.set_connectionsRPC,[])
	for controller_id in Input.get_connected_joypads():
		add_controller_puppet_master(controller_id)
	
	Game_started = true;


## PUPPET MASTER CONTROLLERS
func add_controller_puppet_master(new_device_id):
	var puppet_master_controller = spawn_object("res://SCENES/Puppet_Master.tscn",Vector2.ZERO,0)
	
	puppet_master_controller.owner_id = multiplayer.get_unique_id()
	puppet_master_controller.controller = true
	puppet_master_controller.device_id = new_device_id
	
	controller_puppet_masters[new_device_id] = puppet_master_controller

func remove_controller_puppet_master(device_id):
	controller_puppet_masters[device_id].DestroySelf()
	controller_puppet_masters.erase(device_id)
	
func on_joy_connection_changed(device_id : int,connected : bool):
	if !Game_started:
		return
	if connected:
		add_controller_puppet_master(device_id)
	else:
		remove_controller_puppet_master(device_id)



## OBJECT SPAWNING
func spawn_object(object_path : String,pos : Vector2,rot : float,parent_id : String = ""):
	var object_id = create_unique_object_code()
	var object_to_spawn = load(object_path) as PackedScene
	var object_instance = object_to_spawn.instantiate() 
	
	if parent_id != "":
		objects_to_sync[parent_id].add_child(object_instance)
	else:
		add_child(object_instance)
		
	object_instance.global_position = pos
	object_instance.global_rotation_degrees = rot
	object_instance.sync_id = object_id
	 
	objects_to_sync[object_id] = object_instance
	Relayconnect.call_rpc_room(spawn_object_rpc,[object_path,pos,rot,object_id,parent_id],false)
	return object_instance

@rpc("any_peer","call_local","reliable")
func spawn_object_rpc(object_path : String,pos : Vector2,rot : float,object_id : String,parent_id : String = ""):
	var object_to_spawn = load(object_path) as PackedScene
	var object_instance = object_to_spawn.instantiate() 
	
	if parent_id != "":
		objects_to_sync[parent_id].add_child(object_instance)
	else:
		add_child(object_instance)
		
	object_instance.global_position = pos
	object_instance.global_rotation_degrees = rot
	object_instance.sync_id = object_id
	objects_to_sync[object_id] = object_instance

## OBJECT SYNCING
func sync_all_objects_pos():
	for object_id in objects_to_sync:
		positions_dict[object_id] = objects_to_sync[object_id].global_position
	
	Relayconnect.call_rpc_room(sync_all_objects_rpc,[positions_dict],false)

@rpc("any_peer","call_remote","unreliable")
func sync_all_objects_rpc(positions_dict):
		for object_id in positions_dict:
			objects_to_sync[object_id].global_position = positions_dict[object_id]
			


@rpc("any_peer","call_local","reliable")
func change_scene_rpc(scene_path : String):
	get_tree().change_scene_to_file(scene_path)



