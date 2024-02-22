extends Node2D
@export var StartGameButton:Button

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_nodes_in_group("puppet_masters").size() <= 0:
		GameManager.spawn_puppet_masters()
	GameManager.SPAWN_PUPPET_SIGNAL.connect(spawn_player_customiser)
	if Relayconnect.IS_HOST:
		Relayconnect.game_started_rpc.rpc_id(0,false)	
		for puppet_master in get_tree().get_nodes_in_group("in_game"):
			spawn_player_customiser(puppet_master)
		
	
func spawn_player_customiser(puppet_master):
	var x_pos = get_tree().get_nodes_in_group("lobby_players").size() % 7 * 250
	var y_pos = floor(get_tree().get_nodes_in_group("lobby_players").size() / 7) * 300
	
	var player = GameManager.spawn_object("res://SCENES/LOBBY/lobby_player_customization.tscn",Vector2(x_pos,y_pos),0,puppet_master.name)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Relayconnect.IS_HOST:
		set_process(false)
	
	if get_tree().get_nodes_in_group("lobby_players").size() >= 1:
		StartGameButton.disabled = false
	else:
		StartGameButton.disabled = true
		


func _on_start_game_button_down():
	Relayconnect.game_started_rpc.rpc_id(0,true)
	Relayconnect.call_rpc_room(GameManager.change_scene_rpc,["res://SCENES/RaceGame/GAME.tscn",false])



func _on_leave_button_down():
	Relayconnect.leave_command.rpc_id(0)

