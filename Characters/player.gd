extends CharacterBody2D


@export var speed : float = 200.0
@export var jump_velocity : float = -150.0
@export var double_jump_velocity : float = -100

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else:
		has_double_jumped = false
		
		if was_in_air == true:
			land()
		
		was_in_air = false
		
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			# Normal jump from floor
			jump()
			velocity.y = jump_velocity
		elif not has_double_jumped:
			# Double jump in air
			velocity.y = double_jump_velocity
			has_double_jumped = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x != 0 && animated_sprite.animation != "jump_end":
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	update_animation()
	update_facing_direction()

func update_animation():
	if not animation_locked:
		if not is_on_floor():
			animated_sprite.play("jump_loop")
			
			
		else:
			if direction.x != 0:
				animated_sprite.play("run")
			else:
				animated_sprite.play("idle")
			

func jump():
	velocity.y= jump_velocity
	animated_sprite.play("jump_start")
	animation_locked = true

func update_facing_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func land():
	animated_sprite.play("jump_end")
	animation_locked = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if(animated_sprite.animation == "jump_end"):
		animation_locked = false