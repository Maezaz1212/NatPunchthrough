extends CharacterBody2D


var Speed = 300.0 : set = set_speed
const JUMP_VELOCITY = -400.0

var frame_before_pos = Vector2(0,0)
var frame_before_move_dir = 0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_local_player = false
@export var owner_id = 0 : set = on_owner_change

@export var jump_command  = false
@export var move_dir = Vector2(0,0)
func _physics_process(delta):
	# Handle jump.
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if jump_command and is_on_floor():
		velocity.y = JUMP_VELOCITY
	jump_command = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if move_dir:
		velocity.x = move_dir * Speed
		if move_dir < 0:
			$AnimatedSprite2D.flip_h = true
		elif move_dir > 0:
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)
	
	move_and_slide()
	


func _process(delta):
	if !is_local_player:
		return

	move_dir = Input.get_axis("ui_left", "ui_right")
	if move_dir != frame_before_move_dir:
		Relayconnect.call_rpc_room(player_move_command,[move_dir],false)
	frame_before_move_dir = move_dir	
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_command = true
		Relayconnect.call_rpc_room(player_jump_command,[jump_command],false)
	
	if Input.is_action_just_pressed("Attack"):
		
		player_attack_command.rpc_id(Relayconnect.ROOM_DATA.host_id)

func set_speed(new_speed : int):
	Speed = new_speed
	
@rpc("any_peer","call_remote","unreliable")	
func player_move_command(new_move_dir : float):
	self.move_dir = new_move_dir
	
@rpc("any_peer","call_remote","unreliable")	
func player_jump_command(new_jump_command : bool):
	self.jump_command = new_jump_command

@rpc("any_peer","call_local","reliable")	
func player_attack_command():
	var new_object_id := multiplayer.multiplayer_peer.generate_unique_id() as int
	var pos = global_position
	var rot = 0
	if $AnimatedSprite2D.flip_h:
		rot = 180
	Relayconnect.call_rpc_room(GameManager.spawn_object_rpc,["res://SCENES/bullet.tscn",pos,rot,new_object_id])
	
func on_owner_change(new_owner_id):
	owner_id = new_owner_id
	if owner_id == multiplayer.get_unique_id():
		is_local_player = true
	else:
		is_local_player = false
		
	if Relayconnect.IS_HOST:
		Relayconnect.call_rpc_room(on_owner_change_rpc,[new_owner_id],false)

@rpc("any_peer","reliable")	
func on_owner_change_rpc(new_owner_id):
	owner_id = new_owner_id
