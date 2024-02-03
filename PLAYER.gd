extends CharacterBody2D


var Speed = 300.0 : set = set_speed
const JUMP_VELOCITY = -400.0

var frame_before_pos = Vector2(0,0)
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var is_local_player = false
@export var player_id = 0

func _physics_process(delta):
	if !is_local_player:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * Speed
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)
	
	move_and_slide()
	if frame_before_pos != global_position:
		GameManager.sync_player_pos_all(global_position)


func set_speed(new_speed : int):
	Speed = new_speed
	

