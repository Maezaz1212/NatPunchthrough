extends Node2D

var player_prefab = preload("res://PLAYER.tscn")
var player_objects

func on_game_start():
	for player_id in Relayconnect.ROOM_DATA.players:
		var player_instance = player_prefab.instantiate()
		add_child(player_instance)
		player_instance.player_id = player_id
		print("SUMMONED")
		if player_id == multiplayer.multiplayer_peer.get_unique_id():
			print("IS_LOCAL_PLAYE: ")
			print(multiplayer.multiplayer_peer.get_unique_id())
			player_instance.is_local_player = true

func _ready():
	on_game_start()	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
