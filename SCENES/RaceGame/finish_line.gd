extends Area2D

var won = false
func _on_body_entered(body):
	
	if won or !Relayconnect.IS_HOST:
		return
	
	if body.get_class() == "CharacterBody2D":
		
		get_parent().end_race_game("PLAYER %s WINS" %body.puppet_master.player_name)
		won = true
