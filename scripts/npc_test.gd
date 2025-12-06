extends CharacterBody3D

var health := 16
var knock_out_time := 3
@onready var torso: PhysicalBone3D = $metarig_002/Skeleton3D/PhysicalBoneSimulator3D/TORSO
@onready var bones: PhysicalBoneSimulator3D = $metarig_002/Skeleton3D/PhysicalBoneSimulator3D
@onready var anim: AnimationPlayer = $AnimationPlayer

func slap_a_bitch(dir : Vector3, half_strength : bool):
	$metarig_002.visible = true
	$metarig_001.visible = false
	bones.physical_bones_start_simulation()
	if half_strength:
		torso.linear_velocity = (dir / 2)
	else:
		torso.linear_velocity = dir
		


func hit(dmg:int, dir : Vector3):
	health -= dmg
	if health <= 0:
		$metarig_002/Skeleton3D/normal/eye_alive.visible = false
		$metarig_002/Skeleton3D/BoneAttachment3D/eye_dead.visible = true
		$Npcdie.play()
		$CollisionShape3D.disabled = true
		$Timer.start()
		Engine.time_scale = 0.0
		slap_a_bitch(dir,false)
	else:
		$Hurt.play()
		if dmg <= 5:
			flash_white_anim()
		else:
			$CollisionShape3D.disabled = true
			slap_a_bitch(dir,true)
			flash_white_rag()
			await get_tree().create_timer(knock_out_time).timeout
			$metarig_002/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_stop_simulation()
			for bone in $metarig_002/Skeleton3D.get_bone_count():
				$metarig_002/Skeleton3D.reset_bone_pose(bone)
			
			#reset arms to at side postion, makes ragdoll look better
			$metarig_002/Skeleton3D.set_bone_pose_rotation(10,Quaternion(-0.264,-0.711,0.534,0.374)) 
			$metarig_002/Skeleton3D.set_bone_pose_rotation(17, Quaternion(0.264,0.711,-0.534,-0.374))
			$CollisionShape3D.disabled = false
			$metarig_002.visible = false
			$metarig_001.visible = true
			


func flash_white_rag():
	$metarig_002/Skeleton3D/normal.visible = false
	$metarig_002/Skeleton3D/white.visible = true
	await get_tree().create_timer(0.2).timeout
	$metarig_002/Skeleton3D/normal.visible = true
	$metarig_002/Skeleton3D/white.visible = false
	await get_tree().create_timer(0.2).timeout
	$metarig_002/Skeleton3D/normal.visible = false
	$metarig_002/Skeleton3D/white.visible = true
	await get_tree().create_timer(0.2).timeout
	$metarig_002/Skeleton3D/normal.visible = true
	$metarig_002/Skeleton3D/white.visible = false
func flash_white_anim():
	$metarig_001/Skeleton3D/normal.visible = false
	$metarig_001/Skeleton3D/white.visible = true
	await get_tree().create_timer(0.2).timeout
	$metarig_001/Skeleton3D/normal.visible = true
	$metarig_001/Skeleton3D/white.visible = false


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
