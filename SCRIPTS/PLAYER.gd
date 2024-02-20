extends CharacterBody2D

var node_path = "res://SCENES/Player.tscn"

var sync_id = ""
var owner_id = 0
var is_local_player = false

var Speed = 300.0 : set = set_speed
const JUMP_VELOCITY = -400.0

var is_dead = false: set = is_dead_changed
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var global_pos_last_frame = Vector2.ZERO
@export var jump_command  = false
@export var move_dir = Vector2.ZERO

signal OnVariableChange(var_name : String)

func _ready():
	var parent = get_parent()
	parent.MoveAxisChangedSignal.connect(onMoveAxisChange)
	parent.LookAxisChangedSignal.connect(onLookAxisChange)
	parent.MousePositionChangeSignal.connect(onMousePositionChange)
	parent.JumpSignal.connect(onJump)
	is_local_player = parent.network_node.is_local_player
	add_to_group("player_instances")
	
func _physics_process(delta):
	# Handle jump.
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if move_dir:
		velocity.x = move_dir.x * Speed
		if move_dir.x < 0:
			$AnimatedSprite2D.flip_h = true
		elif move_dir.x > 0:
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)
	
	move_and_slide()
	

func _process(delta):
	if !is_local_player:
		return
	if !global_pos_last_frame.is_equal_approx(global_position):
		#Relayconnect.call_rpc_room(position_sync,[global_position],false)
		global_pos_last_frame = global_position
		

func set_speed(new_speed : int):
	Speed = new_speed
		
func onMoveAxisChange(new_move_axis : Vector2):
	move_dir = new_move_axis;

func onJump():
	if is_on_floor():
		velocity.y -= 500
	
func onLookAxisChange(new_look_axis : Vector2):
	pass

func onMousePositionChange(new_mouse_pos):
	pass

func is_dead_changed(dead : bool):
	if dead:
		hide()
		get_node("CollisionShape2D").set_deferred("disabled",true) 
	else:
		show()
		get_node("CollisionShape2D").set_deferred("disabled",false)
	is_dead = dead
		
