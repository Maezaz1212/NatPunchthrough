extends Area2D

@export var textLabel : RichTextLabel
var players_in_start_box := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Relayconnect.IS_HOST or get_parent().race_started:
		set_process(false)
	
	var players = get_tree().get_nodes_in_group("player_instances").size()
	textLabel.text = "PLAYERS TO START %s/%s" %[players_in_start_box,players]
	if (players_in_start_box == players) && players > 0 :
		textLabel.text = ""
		get_parent().start_race_game()


func _on_body_entered(body):
	players_in_start_box += 1



func _on_body_exited(body):
	players_in_start_box -= 1

