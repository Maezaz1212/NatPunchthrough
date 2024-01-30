extends Node

var server_udp = PacketPeerUDP.new()
var peer_udp = PacketPeerUDP.new()
var game_packet_peer = ENetMultiplayerPeer.new();
var client_id = 0
var own_port = 0

@export var rendevous_ip = "127.0.0.1" 
@export var rendevous_port = 3000;

var inputted_room_code = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	server_udp.connect_to_host(rendevous_ip,rendevous_port)
	var _json_data = {
	  "code":"UDPCONNECT",
	  "client_id":0
	}
	send_packet_to_rendevous(_json_data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if server_udp.get_available_packet_count() > 0:
		var data_stream = ""
		var start_stream = false
		var str = server_udp.get_packet().get_string_from_utf8()
		
		if str.begins_with("XSTART"):
			if start_stream == false:
				start_stream = true
				data_stream += str
		
		if str.contains("XENDX"):
			var splits  = str.split("XENDX")
			for split in splits:
				split = split.replace("XSTART","")
				
				print("Receiving Packet\n" + split)
				var _msg_json = JSON.parse_string(split)
				if _msg_json:
					receive_packet(_msg_json)
					
	if peer_udp.get_available_packet_count() > 0:
		var data_stream = ""
		var start_stream = false
		var str = peer_udp.get_packet().get_string_from_utf8()
		
		if str.begins_with("XSTART"):
			if start_stream == false:
				start_stream = true
				data_stream += str
		
		if str.contains("XENDX"):
			var splits  = str.split("XENDX")
			for split in splits:
				split = split.replace("XSTART","")
				
				print("Receiving Packet\n" + split)
				var _msg_json = JSON.parse_string(split)
				if _msg_json:
					receive_packet(_msg_json)

func receive_packet(json):
	print(json)
	var code = json.code
	match code:
		"UDP_CONNECT_SUCCESS":
			client_id = json.client_id
			own_port = json.socket_info.port
			peer_udp.bind(own_port)
			
		"HOST_SUCCESS":
			print("host success:" + json.room_code + " " + client_id)
			game_packet_peer = ENetMultiplayerPeer.new()
			game_packet_peer.create_server(own_port)
			multiplayer.multiplayer_peer = game_packet_peer
			
		"PLAYER_JOINED":
			var json_data = {
				"GREETING":"GREETING"
			}
			send_packet_to_peer(json_data,json.player_info.address,json.player_info.port)
		
		"JOIN_SUCCESS":
			var json_data = {
				"GREETING":"GREETING"
			}
			send_packet_to_peer(json_data,json.host_info.address,json.host_info.port)
			game_packet_peer = ENetMultiplayerPeer.new()
			game_packet_peer.create_client(json.host_info.address,json.host_info.port)
			
			
			

func send_packet_to_rendevous(json):
	var _data = JSON.stringify(json)
	server_udp.put_packet(("XSTART" + _data + "XENDX" ).to_utf8_buffer())

func send_packet_to_peer(json,ip,port):
	print("here")
	var _data = JSON.stringify(json)
	peer_udp.connect_to_host(ip,port)
	peer_udp.put_packet(("XSTART" + _data + "XENDX" ).to_utf8_buffer())

	
func _on_button_button_down():
	host()

func host():
	var json_data = {
		"client_id":client_id,
		"code":"HOST",
		"player_name":"EMPTY"
	}
	
	send_packet_to_rendevous(json_data)
	

func _on_line_edit_text_changed(new_text):
	inputted_room_code = new_text


func _on_join_button_down():
	join()

func join():
	var json_data = {
		"client_id":client_id,
		"code":"JOINHOST",
		"player_name":"EMPTY",
		"room_code":inputted_room_code,
	}
	send_packet_to_rendevous(json_data)
