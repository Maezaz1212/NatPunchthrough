extends Node2D

@export var textLabel : RichTextLabel
@export var WALLOFDEATH : Node2D
@export var DOOR : Node2D
@export var Game_message : RichTextLabel
@export var LobbyButton : Button
var players_in_start_box := 0
var race_started =false
var game_started = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Relayconnect.IS_HOST:
		return

	LobbyButton.disabled = false
	var i = 0
	
	for puppet_master in get_tree().get_nodes_in_group("in_game"):
		var player = GameManager.spawn_object("res://SCENES/Puppets/Player.tscn",Vector2(300 + (i *10),300),0,puppet_master.name)
		var network_node = player.get_node("NetworkVarSync")
		network_node.owner_id = puppet_master.network_node.owner_id
		i += 2
		

func _process(delta):
	if !Relayconnect.IS_HOST:
		set_process(false)
		
	var dead_players = 0
	var all_players = get_tree().get_nodes_in_group("player_instances")
	for player in all_players:
		if player.is_dead:
			dead_players += 1
	
	if dead_players >= all_players.size() && all_players.size() > 0:
		end_race_game("EVERYONE IS DEAD")
			

func start_race_game():
	WALLOFDEATH.velocity = Vector2(20,0)
	DOOR.global_position = Vector2(851,668)
	race_started = true
	
	
func end_race_game(end_message : String):
	race_started = false
	WALLOFDEATH.velocity = Vector2.ZERO
	Game_message.text = end_message
	await get_tree().create_timer(5.0).timeout
	for t in range(5,0,-1):
		Game_message.text = "%s %s seconds till restart" %[end_message,t]
		await get_tree().create_timer(1.0).timeout 
	Relayconnect.call_rpc_room(GameManager.change_scene_rpc,["res://SCENES/RaceGame/GAME.tscn",false])

func _on_leave_button_button_down():
	Relayconnect.leave_command.rpc_id(0)


func _on_lobby_button_button_down():
	if Relayconnect.IS_HOST:
		Relayconnect.call_rpc_room(GameManager.change_scene_rpc,["res://SCENES/LOBBY/Multiplayer_Lobby.tscn",false])

