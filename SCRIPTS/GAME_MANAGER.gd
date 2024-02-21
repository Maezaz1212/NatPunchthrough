extends Node2D

var Game_started = false

var objects_to_sync = {}
var controller_puppet_masters = {}
var current_scene
var CHARS = "1234567890";

var player_names_controller : Dictionary = {}
var player_name_keyboard = "HEYYYO"

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
	pass
	
# START GAME AND SPAWN PLAYERS
func on_game_load():
	
	Relayconnect.game_started_rpc.rpc_id(0,false)
	var pos = Vector2(randi_range(300,600),-300)
	
	#Setup Keyboard Player
	var puppet_master_keyboard = spawn_object("res://SCENES/NETWORKING/Puppet_Master.tscn",Vector2.ZERO,0)
	puppet_master_keyboard.network_node.owner_id = multiplayer.get_unique_id()
	puppet_master_keyboard.controller = false;
	puppet_master_keyboard.player_name = player_name_keyboard
	for controller_id in Input.get_connected_joypads():
		add_controller_puppet_master(controller_id)
	
	Game_started = true;


## PUPPET MASTER CONTROLLERS
func add_controller_puppet_master(new_device_id):
	var puppet_master_controller = spawn_object("res://SCENES/NETWORKING/Puppet_Master.tscn",Vector2.ZERO,0)
	
	puppet_master_controller.get_node("NetworkVarSync").owner_id = multiplayer.get_unique_id()
	puppet_master_controller.controller = true
	puppet_master_controller.device_id = new_device_id
	puppet_master_controller.player_name = player_names_controller[new_device_id]
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
	object_instance.rotation_degrees = rot
	object_instance.name = object_id
	objects_to_sync[object_id] = object_instance
	
	var networked_sync_node = object_instance.get_node("NetworkVarSync")
	networked_sync_node.sync_id = object_id
	
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
	object_instance.name = object_id
	objects_to_sync[object_id] = object_instance
	
	var networked_sync_node = object_instance.get_node("NetworkVarSync")
	networked_sync_node.sync_id = object_id
		
@rpc("any_peer","call_local","reliable")
func change_scene_rpc(scene_path : String):
	for child in get_children():
		child.queue_free()
	get_tree().change_scene_to_file(scene_path)
	current_scene = scene_path
	

func sync_game_data(target_player):
	var dict_to_send = Recursive_child(self)
	sync_game_data_rpc.rpc_id(target_player,dict_to_send,current_scene)
	pass
	
@rpc("any_peer","call_remote","reliable")
func sync_game_data_rpc(game_data : Dictionary,scene_path : String):
	get_tree().change_scene_to_file(scene_path)
	recursive_build_scene(game_data,self)
	pass

func Recursive_child(node):
	var dict = {}
	for child in node.get_children():
		var network_node = child.get_node_or_null("NetworkVarSync")
		if !network_node:
			continue
		dict[network_node.sync_id] = {
			"node_path":network_node.instance_file_path,
			"sync_id":network_node.sync_id,
			"owner_id":network_node.owner_id,
			"children":Recursive_child(child),
		}
	return dict

func recursive_build_scene(node_dictionary,parent_node):
	for node in node_dictionary:
		var node_info = node_dictionary[node]
		var object_to_spawn = load(node_info.node_path) as PackedScene
		var object_instance = object_to_spawn.instantiate()
		parent_node.add_child(object_instance)
		var network_node = object_instance.get_node("NetworkVarSync")
		object_instance.name = node_info.sync_id
		network_node.sync_id = node_info.sync_id
		network_node.owner_id = node_info.owner_id
		
		objects_to_sync[node_info.sync_id] = object_instance
		recursive_build_scene(node_info.children,object_instance)
