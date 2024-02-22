extends Node2D
@export var StartGameButton:Button
var positions_taken = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	
	GameManager.spawn_puppet_masters()
	GameManager.SPAWN_PUPPET_SIGNAL.connect(spawn_player_customiser)
	if Relayconnect.IS_HOST:
		Relayconnect.game_started_rpc.rpc_id(0,false)	
		for puppet_master in get_tree().get_nodes_in_group("in_game"):
			spawn_player_customiser(puppet_master)
		
	
func spawn_player_customiser(puppet_master):
	var found_pos = false
	var i = 0

	while !found_pos:
		var x_raw = i % 7 
		var y_raw = floor(i / 7) 

		if !positions_taken.has(Vector2(x_raw,y_raw)):
			positions_taken[Vector2(x_raw,y_raw)] = "TAKEN"
			var x_pos = x_raw * 250
			var y_pos = y_raw * 300
			found_pos = true
			var player = GameManager.spawn_object("res://SCENES/LOBBY/lobby_player_customization.tscn",Vector2(x_pos,y_pos),0,puppet_master.name)
			player.multiplayer_lobby = self
			player.lobby_grid_pos = Vector2(x_raw,y_raw)
		
		i+=1

	
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

