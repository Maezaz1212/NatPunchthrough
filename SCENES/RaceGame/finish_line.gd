extends Area2D

var won = false
func _on_body_entered(body):
	
	if won or !Relayconnect.IS_HOST:
		return
	
	if body.get_class() == "CharacterBody2D":
		var network_node = body.get_node("NetworkVarSync")
		get_parent().end_race_game("PLAYER %s WINS" %network_node.owner_id)
		won = true
