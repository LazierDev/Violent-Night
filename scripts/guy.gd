extends Node3D

@onready var bones:PhysicalBoneSimulator3D = $metarig_002/Skeleton3D/PhysicalBoneSimulator3D


func _ready() -> void:
	slap_a_bitch(Vector3(0,50,-100))

func slap_a_bitch(dir : Vector3):
	await get_tree().create_timer(2.0).timeout
	$metarig_002.visible = true
	$metarig_001.visible = false
	bones.physical_bones_start_simulation()
	$metarig_002/Skeleton3D/PhysicalBoneSimulator3D/TORSO.linear_velocity = dir
