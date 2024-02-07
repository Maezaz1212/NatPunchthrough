extends Node2D

const instance_file_path = "res://SCENES/Puppet_Master.tscn"

var owner_id := 0 : set = onOwnerIdChange
var is_local_player := false 

var sync_id := ""

var device_id := 0
var controller := true

var MoveAxis := Vector2(0,0) : set = MoveAxisChanged
var LookAxis := Vector2(0,0) : set = LookAxisChanged
var MousePos := Vector2.ZERO : set = MousePositionChange

signal MoveAxisChangedSignal(move_dir : Vector2)
signal LookAxisChangedSignal(lookDir : Vector2)
signal MousePositionChangeSignal(mouse_pos : Vector2)
signal ButtonPressedSignal(button_pressed : InputEvent)

var joystick_left_deadzone := 0.2
var joystick_right_deadzone := 0.2
var key_bindings_keyboard = {
	"MOVE LEFT":"A",
	"MOVE RIGHT":"D",
	"MOVE UP":"W",
	"MOVE DOWN":"S",
	"SPAWN PLAYER":"Enter",
}

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func _process(delta):
	if !is_local_player: 
		return
		
	if controller:
		
		## Left Joystick
		var joy_left_x = Input.get_joy_axis(device_id,JOY_AXIS_LEFT_X)
		if joy_left_x < joystick_left_deadzone and joy_left_x > (joystick_left_deadzone * -1):
			joy_left_x = 0
			
		var joy_left_y = Input.get_joy_axis(device_id,JOY_AXIS_LEFT_X)
		if joy_left_y < joystick_left_deadzone and joy_left_y > (joystick_left_deadzone * -1):
			joy_left_y = 0
			
		var new_left_stick = Vector2(joy_left_x,joy_left_y)
		if new_left_stick != MoveAxis:
			MoveAxis = new_left_stick
		
		## Right Joystick
		var joy_right_x = Input.get_joy_axis(device_id,JOY_AXIS_RIGHT_X)
		if joy_right_x < joystick_right_deadzone and joy_right_x > (joystick_right_deadzone * -1):
			joy_right_x = 0
			
		var joy_right_y = Input.get_joy_axis(device_id,JOY_AXIS_RIGHT_X)
		if joy_right_y < joystick_right_deadzone and joy_right_y > (joystick_right_deadzone * -1):
			joy_right_y = 0
			
		var new_right_stick = Vector2(joy_right_x,joy_right_y)
		if new_right_stick != LookAxis:
			LookAxis = new_left_stick
	else:
		if Input.get_last_mouse_velocity().is_zero_approx() and !LookAxis.is_zero_approx():
			LookAxis = Vector2(0,0)
	

func _input(event : InputEvent):
	if !is_local_player: 
		return
		
	if controller:
		match event.get_class():
			"InputEventJoypadMotion":
				return
			"InputEventJoypadButton":
				if get_child_count() < 1:
					GameManager.spawn_object("res://SCENES/Player.tscn",Vector2(300,300),0,sync_id)
			
	else:
		
		match event.get_class():
			"InputEventMouseMotion":
				LookAxis = event.velocity/1000
				MousePos = event.position
				return
			"InputEventKey":
				var key = OS.get_keycode_string(event.keycode)
				print(key)
				if event.echo:
					return
				match key_bindings_keyboard.find_key(key):
					"MOVE LEFT":
						if event.pressed:
							MoveAxis.x -= 1
						else:
							MoveAxis.x += 1
					"MOVE RIGHT":
						if event.pressed:
							MoveAxis.x += 1
						else:
							MoveAxis.x -= 1
					"MOVE UP":
						if event.pressed:
							MoveAxis.y += 1
						else:
							MoveAxis.y -= 1
					"MOVE DOWN":
						if event.pressed:
							MoveAxis.y -= 1
						else:
							MoveAxis.y += 1
					"SPAWN PLAYER":
						if get_child_count() < 1:
							GameManager.spawn_object("res://SCENES/Player.tscn",Vector2(300,300),0,sync_id)



		
func MoveAxisChanged(new_move_axis : Vector2):
	MoveAxis = new_move_axis
	if MoveAxis.is_zero_approx():
		MoveAxis = Vector2.ZERO
	
	if is_local_player:
		Relayconnect.call_rpc_room(MoveAxisChangedRPC,[MoveAxis],false)
		
	MoveAxisChangedSignal.emit(MoveAxis)
	
@rpc("any_peer","call_remote","unreliable")
func MoveAxisChangedRPC(new_move_axis):
	MoveAxis = new_move_axis
	
func LookAxisChanged(new_look_axis):
	LookAxis = new_look_axis
	if LookAxis.is_zero_approx():
		LookAxis = Vector2.ZERO
	LookAxisChangedSignal.emit(LookAxis)


func MousePositionChange(new_mouse_pos):
	MousePos = new_mouse_pos
	MousePositionChangeSignal.emit(new_mouse_pos)
		

func onOwnerIdChange(new_owner_id : int):
	owner_id = new_owner_id
	if owner_id == multiplayer.get_unique_id():
		is_local_player = true
	Relayconnect.call_rpc_room(onOwnerIdChangeRPC,[owner_id],false)
	
@rpc("any_peer","call_remote","unreliable")
func onOwnerIdChangeRPC(new_owner_id):
	owner_id = new_owner_id

		
		

