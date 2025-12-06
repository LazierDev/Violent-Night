extends RigidBody3D

var speed : float  # Speed of the bullet
func _ready():
	# Enable continuous collision detection
	continuous_cd = true

func _integrate_forces(state):
	var direction = -transform.basis.z
	var distance = speed * state.get_step()
	var collision = move_and_collide(direction * distance)

	if collision:
		# Handle collision
		var collider := collision.get_collider()
		if collider:
			if collider.has_method("hit_by_raycast"):
				collider.hit_by_raycast()

func mult_speed(aquired_speed:float):
	speed = aquired_speed
