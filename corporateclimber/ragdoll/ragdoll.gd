extends Node3D

@onready var camera_root: Node3D = $CameraRoot
@onready var head: PhysicalBone3D = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_Head"
@onready var body_bones: Array[PhysicalBone3D] = [$"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_Spine2", $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_Hips"]
@onready var left_hand: PhysicalBone3D = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_LeftForeArm"
@onready var right_hand: PhysicalBone3D = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_RightForeArm"

@onready var body_control: Node3D = $BodyControl
@onready var left_leg_control: Node3D = $LeftLegControl
@onready var right_leg_control: Node3D = $RightLegControl
@onready var left_arm_control: Node3D = $LeftArmControl
@onready var right_arm_control: Node3D = $RightArmControl

var MOUSE_SENSITIVITY = 0.05
var WALK_SPEED = 0.5

var walk_animation_timer = 0
var WALK_ANIMATION_SPEED = 0.5
var is_walking: bool = false

@onready var jump_ray_cast_3d: RayCast3D = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_Hips/JumpRayCast3D"
var can_jump: bool = true
var JUMP_STRENGTH = 100

var left_hand_active: bool = false
var right_hand_active: bool = false
var left_hand_grab = null
var right_hand_grab = null

@onready var left_grab_joint: PinJoint3D = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_LeftForeArm/GrabJoint"
@onready var right_grab_joint: PinJoint3D = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_RightForeArm/GrabJoint"


func _ready() -> void:
	$Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()

func _process(delta: float) -> void:
	camera_root.global_transform.origin = head.global_transform.origin
	
	HandleRotation()
	HandleWalk()
	HandleGrab()

func HandleGrab():
	if Input.is_action_pressed("left_mouse"):
		left_arm_control.rotation.x = camera_root.rotation.x * 2
		left_hand_active = true
		
		left_arm_control.get_node("Generic6DOFJoint3D").set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		left_arm_control.get_node("Generic6DOFJoint3D").set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		left_arm_control.get_node("Generic6DOFJoint3D").set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		left_arm_control.get_node("Generic6DOFJoint3D2").set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		left_arm_control.get_node("Generic6DOFJoint3D2").set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		left_arm_control.get_node("Generic6DOFJoint3D2").set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
	else:
		left_arm_control.get_node("Generic6DOFJoint3D").set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		left_arm_control.get_node("Generic6DOFJoint3D").set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		left_arm_control.get_node("Generic6DOFJoint3D").set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		left_arm_control.get_node("Generic6DOFJoint3D2").set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		left_arm_control.get_node("Generic6DOFJoint3D2").set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		left_arm_control.get_node("Generic6DOFJoint3D2").set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		left_hand_active = false
		left_grab_joint.set_node_a("")
		left_grab_joint.set_node_b("")
		left_hand_grab = null
	
	if Input.is_action_pressed("right_mouse"):
		right_arm_control.rotation.x = camera_root.rotation.x * 2
		right_hand_active = true
		
		right_arm_control.get_node("Generic6DOFJoint3D").set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		right_arm_control.get_node("Generic6DOFJoint3D").set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		right_arm_control.get_node("Generic6DOFJoint3D").set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		right_arm_control.get_node("Generic6DOFJoint3D2").set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		right_arm_control.get_node("Generic6DOFJoint3D2").set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
		right_arm_control.get_node("Generic6DOFJoint3D2").set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, true)
	else:
		right_arm_control.get_node("Generic6DOFJoint3D").set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		right_arm_control.get_node("Generic6DOFJoint3D").set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		right_arm_control.get_node("Generic6DOFJoint3D").set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		right_arm_control.get_node("Generic6DOFJoint3D2").set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		right_arm_control.get_node("Generic6DOFJoint3D2").set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		right_arm_control.get_node("Generic6DOFJoint3D2").set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_SPRING, false)
		right_hand_active = false
		right_grab_joint.set_node_a("")
		right_grab_joint.set_node_b("")
		right_hand_grab = null

func HandleRotation():
	body_control.rotation.y = camera_root.rotation.y
	left_leg_control.rotation.y = camera_root.rotation.y
	right_leg_control.rotation.y = camera_root.rotation.y
	left_arm_control.rotation.y = camera_root.rotation.y
	right_arm_control.rotation.y = camera_root.rotation.y

func HandleWalk():
	is_walking = false
	for bone in body_bones:
		if Input.is_action_pressed("forward"):
			bone.apply_central_impulse(-body_control.transform.basis.z * WALK_SPEED / body_bones.size())
			is_walking = true
		if Input.is_action_pressed("left"):
			bone.apply_central_impulse(-body_control.transform.basis.x * WALK_SPEED / body_bones.size())
			is_walking = true
		if Input.is_action_pressed("right"):
			bone.apply_central_impulse(body_control.transform.basis.x * WALK_SPEED / body_bones.size())
			is_walking = true
		if Input.is_action_pressed("backward"):
			bone.apply_central_impulse(body_control.transform.basis.z * WALK_SPEED / body_bones.size())
			is_walking = true
		
		if Input.is_action_just_pressed("jump"):
			if can_jump:
				if jump_ray_cast_3d.is_colliding():
					if jump_ray_cast_3d.get_collision_normal().y > 0.5:
						can_jump = false
						bone.apply_central_impulse(body_control.transform.basis.y * JUMP_STRENGTH / body_bones.size())
						await get_tree().create_timer(0.25).timeout
						can_jump = true
	
	if is_walking:
		AnimateWalk()
	else:
		left_leg_control.rotation.x = 0
		right_leg_control.rotation.x = 0

func AnimateWalk():
	walk_animation_timer += 0.1
	left_leg_control.rotation.x = sin(walk_animation_timer) * WALK_ANIMATION_SPEED
	right_leg_control.rotation.x = -sin(walk_animation_timer) * WALK_ANIMATION_SPEED

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion:
		camera_root.rotation_degrees.y -= event.relative.x * MOUSE_SENSITIVITY
		camera_root.rotation_degrees.x -= event.relative.y * MOUSE_SENSITIVITY
		camera_root.rotation_degrees.x = clamp(camera_root.rotation_degrees.x, -90, 90)


func _on_RightHand_body_entered(body: Node3D) -> void:
	if right_hand_active:
		if body.is_in_group("CanGrab"):
			if right_hand_grab == null:
				right_grab_joint.set_node_a(right_hand.get_path())
				right_grab_joint.set_node_b(body.get_path())
				right_hand_grab = body


func _on_LeftHand_body_entered(body: Node3D) -> void:
	if left_hand_active:
		if body.is_in_group("CanGrab"):
			if left_hand_grab == null:
				left_grab_joint.set_node_a(left_hand.get_path())
				left_grab_joint.set_node_b(body.get_path())
				left_hand_grab = body
