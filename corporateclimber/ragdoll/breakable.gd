extends RigidBody3D
class_name Breakable

var isBroken: bool = false
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var brokenMaterial: StandardMaterial3D

func Break():
	if isBroken:
		return
	isBroken = true
	
	mesh_instance_3d.set_surface_override_material(0, brokenMaterial)
	$AudioStreamPlayer3D.play()
