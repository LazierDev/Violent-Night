extends CharacterBody3D

#movement
var move := true
var WALK_SPEED = 4.0
var SPRINT_SPEED = 8.0
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
enum {RELOAD, HOLD, THROW}
var snow_balls := 15
var sb_cool_down := false
var sb_strength := 15
var sb_knockback := 150

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and move:
		rotate_y(deg_to_rad(-event.relative.x * sens))
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
	
	
	if Input.is_action_just_pressed("lmb"):
		match cur_weapon:
			PUNCH : punch()
			SNOWBALL : snow_ball_throw()
			


	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and move:
		velocity.y = JUMP_VELOCITY
		if anim.current_animation != "jump":
			anim.play("jump")
			anim.seek(0.5368)
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if move:
		if direction:
			$graphics.look_at(direction+position)
			$graphics.rotation.x = clamp($graphics.rotation.x, deg_to_rad(0), deg_to_rad(0))
			velocity.x = direction.x * get_speed()
			velocity.z = direction.z * get_speed()
		else:
			if anim.current_animation != "idle" and anim.current_animation != "jump":
				anim.play("idle")
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
			velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
			
		move_and_slide()

func punch():
	if !punch_cool_down:
		anim.play("punch")
		anim.speed_scale = 2.0
		move = false
		for body in $graphics/Skeleton3D/Santa/punch_area.get_overlapping_bodies():
			Engine.time_scale = 0.0
			$Timer.start()
			var dir = ((body.global_position - global_position).normalized()) * punch_knockback
			body.hit(punch_strength,dir)
		punch_cool_down = true
		await anim.animation_finished
		move = true
		punch_cool_down = false
		anim.speed_scale = 1.0

func snow_ball_throw():
	if !sb_cool_down:
		move = false
		if anim.current_animation != "snow_ball":
			anim.play("snow_ball")
		sb_cool_down = true

func get_speed():
	if Input.is_action_pressed("shift"):
		if anim.current_animation != "run" and anim.current_animation != "jump":
			anim.play("run")
			$Origin/SpringArm3D/Camera3D.fov = 90
		return SPRINT_SPEED
	else:
		if anim.current_animation != "walk" and anim.current_animation != "jump":
			anim.play("walk")
			$Origin/SpringArm3D/Camera3D.fov = 75
		return WALK_SPEED


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
