extends PhysicalBoneSimulator3D


# spring stuff
@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0

var physics_bones = [] # all physical bones

# turn it into ragdoll
@export var ragdoll_mode := false


@onready var physical_skel : PhysicalBoneSimulator3D = $"."
@onready var animated_skel : Skeleton3D = $"../../../metarig_001/Skeleton3D"

func _ready():
	print("dih")
	physical_skel.physical_bones_start_simulation()# activate ragdoll
	for child in physical_skel.get_children():
		if child is PhysicalBone3D:
			physics_bones.append(child)
	print(physics_bones)
