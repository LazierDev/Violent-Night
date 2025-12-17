extends CharacterBody3D

#movement
var move_lock := false
var slow := false
var move := true
var move_cam := true
var SLOW_SPEED := 2.0
var WALK_SPEED := 4.0
var SPRINT_SPEED := 8.0
var JUMP_VELOCITY = 6.5
var gravity = 25
@onready var pivot: Node3D = $Origin
@onready var anim: AnimationPlayer = $graphics/AnimationPlayer
var sens: float = 0.6

# weapon
enum {PUNCH, SNOWBALL}
var cur_weapon := PUNCH
var holding_punch := false
var holding_sb := false

#punch
var punch_cool_down := false
var punch_strength := 6
var punch_knockback := 150

#snowball
var snow_balls := 15
var sb_cool_down := false
var current_sb_strength := 8.0
var max_sb_strength := 100
var sb_knockback := 250
@onready var snow_ball_spawn: Node3D = $graphics/Skeleton3D/snow_ball_spawn
var snow_ball := preload("res://scenes/snow_ball.tscn")
var sb_instance
var loop := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and move_cam:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		if !move_lock:
			$graphics.rotate_y(deg_to_rad(event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		
		pivot.rotation.y = clamp(pivot.rotation.y, deg_to_rad(-45),deg_to_rad(45))
		pivot.rotation.z = clamp(pivot.rotation.z,deg_to_rad(0),deg_to_rad(0))
		pivot.rotation.x = clamp(pivot.rotation.x,deg_to_rad(-45),deg_to_rad(90))
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	#switch weapon for debug
	if Input.is_action_just_pressed("rmb"):
		if cur_weapon == PUNCH:
			cur_weapon = SNOWBALL
		else:
			cur_weapon = PUNCH
	
	if Input.is_action_pressed("weapon_menu"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$ui/weapon_menu.visible = true
	
	if Input.is_action_just_released("weapon_menu"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$ui/weapon_menu.visible = false
	
	
	if Input.is_action_just_pressed("lmb") and cur_weapon == PUNCH:
		punch()
		
	
	if Input.is_action_pressed("lmb") and cur_weapon == SNOWBALL and !sb_cool_down:
		slow = true
		move_lock = true
		if current_sb_strength < max_sb_strength:
			current_sb_strength += 8 * delta
		if anim.current_animation != "snow_ball":
			anim.play("snow_ball")
			anim.seek(1.8)
		
		if anim.current_animation_position >= 2.3:
			loop = true
			anim.speed_scale = -0.1
		if anim.current_animation_position <= 2.29 and loop == true:
			anim.speed_scale = 0.1
		
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_released("lmb") and cur_weapon == SNOWBALL:
		slow = false
		loop = false
		anim.speed_scale = 1.0
		#this spawns the ball at the correct time
		if (2.4 - anim.current_animation_position) >= 0:
			await get_tree().create_timer(2.4 - anim.current_animation_position).timeout
			snow_ball_throw()
		else:
			snow_ball_throw()

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and move:
		velocity.y = JUMP_VELOCITY
		if anim.current_animation != "jump" and anim.current_animation != "punch" and anim.current_animation != "snow_ball":
			anim.play("jump")
			anim.seek(0.5368)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if move:
		if direction:
			if !move_lock:
				$graphics.look_at(direction+position)
				$graphics.rotation.x = clamp($graphics.rotation.x, deg_to_rad(0), deg_to_rad(0))
			else:
				$graphics.look_at(position)
				$graphics.rotation.x = clamp($graphics.rotation.x, deg_to_rad(0), deg_to_rad(0))
			velocity.x = direction.x * get_speed()
			velocity.z = direction.z * get_speed()
		else:
			if anim.current_animation != "idle" and anim.current_animation != "jump" and anim.current_animation != "punch" and anim.current_animation != "snow_ball":
				anim.play("idle")
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
			velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
			
		move_and_slide()

func punch():
	if !punch_cool_down:
		anim.play("punch")
		anim.speed_scale = 2.0
		for body in $graphics/Skeleton3D/Santa/punch_area.get_overlapping_bodies():
			if body.has_method("hit"):
				var dir = ((body.global_position - global_position).normalized()) * punch_knockback
				body.hit(punch_strength,dir)
		punch_cool_down = true
		await anim.animation_finished
		punch_cool_down = false
		anim.speed_scale = 1.0

func snow_ball_throw():
	if !sb_cool_down:
		sb_cool_down = true
		sb_instance = snow_ball.instantiate()
		sb_instance.global_transform = snow_ball_spawn.global_transform
		get_parent().add_child(sb_instance)
		sb_instance.mult_speed(self.velocity.length()+ current_sb_strength)
		await get_tree().create_timer(0.5).timeout
		anim.stop()
		sb_cool_down = false
		move_lock = false
		current_sb_strength = 8.0

func get_speed():
	if Input.is_action_pressed("shift") and !slow:
		if anim.current_animation != "run" and anim.current_animation != "jump" and anim.current_animation != "punch"  and anim.current_animation != "snow_ball":
			anim.play("run")
			$Origin/SpringArm3D/Camera3D.fov = 90
		return SPRINT_SPEED
	elif !slow:
		if anim.current_animation != "walk" and anim.current_animation != "jump" and anim.current_animation != "punch"  and anim.current_animation != "snow_ball":
			anim.play("walk")
			$Origin/SpringArm3D/Camera3D.fov = 75
		return WALK_SPEED
	else:
		return SLOW_SPEED


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
