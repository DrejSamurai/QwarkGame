extends CharacterBody3D

signal state_changed

const SPEED = 5.0
const JUMP_VELOCITY = 6.5
const LERP_VAL = .15

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var sense_horizontal = 0.5
var states_stack = []
var current_state = null

@onready var anim_tree = $AnimationTree
@onready var spring_arm_pivit = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm3D	
@onready var states_map = {
	'idle': $State/Idle,
	'walk': $State/Walk,
	'jump': $State/Jump,
}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	states_stack.push_front($State/Idle)
	current_state = states_stack[0]
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * sense_horizontal)
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
func _physics_process(delta):
	var is_jumping = false
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimationPlayer.play("jump_animation")
		
		
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
		$AnimationPlayer.play("run")
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
		
	
	anim_tree.set("parameters/BlendSpace1D/blend_position",velocity.length() / SPEED)
	anim_tree.set("parameters/BlendSpace1D 2/blend_position",position.y)
	
	move_and_slide()
