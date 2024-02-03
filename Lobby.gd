extends Node2D


func _ready():
	Relayconnect.JOIN_SUCCESS.connect(_on_join_success)
	Relayconnect.JOIN_FAIL.connect(_on_join_fail)
	Relayconnect.HOST_SUCCESS.connect(_on_host_success)
	Relayconnect.HOST_FAIL.connect(_on_host_fail)
	
func _on_host_success():
	
	print("HOST SUCESS")

func _on_host_fail():
	print("HOST FAIL")

func _on_join_success():
	#print(Relayconnect.ROOM_DATA.room_code)
	print("JOIN SUCCESS")

func _on_join_fail(error_message):
	print(error_message)
	print("JOIN FAIL")
	
func _on_host_button_down():
	Relayconnect.host()


func _on_join_button_down():
	Relayconnect.join()
	


func _on_line_edit_text_changed(new_text):
	Relayconnect.typed_room_code = new_text


func _on_start_game_button_down():
	Relayconnect.call_rpc_room(Relayconnect.change_scene_rpc,["res://GAME.tscn"])
