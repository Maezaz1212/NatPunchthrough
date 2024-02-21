extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.spawn_puppet_masters()
	GameManager.SPAWN_PUPPET_SIGNAL.connect(spawn_player_customiser)
	Relayconnect.game_started_rpc.rpc_id(0,false)	

func spawn_player_customiser(puppet_master,remote_sender_id):
	var x_pos = get_tree().get_nodes_in_group("lobby_players").size() % 7 * 250
	var y_pos = floor(get_tree().get_nodes_in_group("lobby_players").size() / 7) * 300
	
	var player = GameManager.spawn_object("res://SCENES/LOBBY/lobby_player_customization.tscn",Vector2(x_pos,y_pos),0,puppet_master.name)
	var network_node = player.get_node("NetworkVarSync")
	network_node.owner_id = multiplayer.get_remote_sender_id()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_button_down():
	Relayconnect.game_started_rpc.rpc_id(0,true)
	Relayconnect.call_rpc_room(GameManager.change_scene_rpc,["res://SCENES/RaceGame/GAME.tscn",false])
