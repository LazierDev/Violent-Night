extends RigidBody3D

var speed : float  # Speed of the bullet
var hit := false

func _ready():
	# Enable continuous collision detection
	continuous_cd = true

func _integrate_forces(state):
	var direction = -transform.basis.z
	var distance = speed * state.get_step()
	var collision = move_and_collide(direction * distance)



func mult_speed(aquired_speed:float):
	speed = aquired_speed


func _on_kaboom_body_entered(body: Node3D) -> void:
	if body != self and body.name != "player" and !hit:
		hit = true
		$MeshInstance3D.visible = false
		$"Snowball-throw-hit7-278174".play()
		$"Snowball-throw-hit7-278174".seek(0.2)
		$snow.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_aim_bot_body_entered(body: Node3D) -> void:
	if body.has_method("freeze") and !body.frozen and !hit:
		hit = true
		body.freeze()
		$MeshInstance3D.visible = false
		$"Snowball-throw-hit7-278174".play()
		$snow.emitting = true
		$"Snowball-throw-hit7-278174".seek(0.2)
		await get_tree().create_timer(1.0).timeout
		queue_free()
