extends KinematicBody2D

# External nodes
onready var animation_tree = get_node("animation_tree")
onready var animation_mode = animation_tree.get("parameters/playback")
onready var sprites = get_node("sprites")
onready var sfx_manager = get_node("sfx_manager")
onready var hand_right_area = get_node("sprites/Abdomen/Chest/BicepRight/HandRight/hand_right_area")

# Character properties
var attack_damage_value = 10
var health = 100 

# Movement consts
const GRAVITY = 3200.0
const WALK_SPEED = 55
const MAX_WALK_SPEED = 600
const JUMP_SPEED = 110000
const JUMP_ANIMATION_DELAY = 0.2
const CAN_JUMP_COOLDOWN = 0.2
const STAND_BY_ANIMATION_COOLDOWN = 10

# Movement data handlers
var jump_animation_delay_current = 0
var is_jump_animation_delay = false
var velocity = Vector2()
var checking_landing = false
onready var can_jump_cooldown_current = CAN_JUMP_COOLDOWN
var is_on_air_valid = false
var is_on_air_valid_count = 0
var is_on_air_valid_count_max = 5

# Animation data handlers
var stand_by_animation_current = 0
var can_stand_by_animation = true

# Input data handlers
var is_pressing_right = false
var is_pressing_left = false
var is_pressing_up = false
var is_pressing_down = false
var is_pressing_click = false
var is_pressing_debug = false

func _ready():
	animation_tree.active = true
	enable_hand_right_rb(false)
	hand_right_area.connect("body_entered",self,"apply_damage")
	
func _process(delta):
	
	# --- STAND BY ANIMATION ---
	if can_stand_by_animation:
		stand_by_animation_current += delta
		
	if (stand_by_animation_current > STAND_BY_ANIMATION_COOLDOWN):
		stand_by_animation_current = 0
		animation_mode.travel("stand_by")
	
	# --- SPRITE'S COLOR TO WHITE ---
	if sprites.modulate.r < 1:
		sprites.modulate.r += delta
	if sprites.modulate.g < 1:
		sprites.modulate.g += delta
	if sprites.modulate.b < 1:
		sprites.modulate.b += delta
	
func _physics_process(delta):
	
	# --- VALIDATE ON FLOOR ---
	if is_on_floor(): 
		is_on_air_valid = false
		is_on_air_valid_count = 0
	else: 
		is_on_air_valid_count += 1
		if is_on_air_valid_count >= is_on_air_valid_count_max:
			is_on_air_valid = true
	
	# --- MOVEMENT ---
	if Input.is_action_pressed("right"):
		sprites.scale.x = 1
		velocity.x += WALK_SPEED
		if velocity.x > MAX_WALK_SPEED:
			velocity.x = MAX_WALK_SPEED
	elif Input.is_action_pressed("left"):
		sprites.scale.x = -1
		velocity.x -= WALK_SPEED
		if velocity.x < -MAX_WALK_SPEED:
			velocity.x = -MAX_WALK_SPEED
	else:
		if abs(velocity.x) < WALK_SPEED * 2:
			velocity.x = 0
		elif velocity.x < 0:
			velocity.x += WALK_SPEED
		elif velocity.x > 0:
			velocity.x -= WALK_SPEED
	
	# --- GRAVITY ---
	velocity.y += delta * GRAVITY
	if velocity.y > 1000:
		velocity.y = 1000
	if is_on_floor() and !checking_landing: 
		velocity.y = 0
		
	# --- JUMP ---
	if is_on_floor(): # When on floor
		if checking_landing: # Landing
			checking_landing = false
			can_jump_cooldown_current = 0
			if velocity.x == 0:
				animation_mode.travel("land")
			else:
				animation_mode.travel("land_run")
		if Input.is_action_pressed("up"): # Read input
			if can_jump_cooldown_current > CAN_JUMP_COOLDOWN:
				is_jump_animation_delay = true
				can_jump_cooldown_current = 0
				if velocity.x == 0:
					animation_mode.travel("jump") # Animation jump
				else:
					animation_mode.travel("run_jump") # Animation jump
	elif is_on_air_valid: # Falling without jumping
		if not checking_landing:
			checking_landing = true
		if velocity.x == 0:
			if (animation_mode.get_current_node()!="air"):
				animation_mode.travel("air")
		else :
			if (animation_mode.get_current_node()!="air_leaning"):
				animation_mode.travel("air_leaning")
	if (is_jump_animation_delay): # Delay jump for animation
		jump_animation_delay_current += delta
		if (jump_animation_delay_current > JUMP_ANIMATION_DELAY):
			jump_animation_delay_current = 0
			is_jump_animation_delay = false
			velocity.y = -JUMP_SPEED * delta # Jump
			checking_landing = true
	can_jump_cooldown_current += delta # Prevent spamming jump
	
	# --- FINALIZE MOVE ---
	move_and_slide(velocity, Vector2(0,-1))
	
	# --- IDLE & STAND BY ANIMATION ---
	if is_on_floor() and !checking_landing and jump_animation_delay_current == 0 and velocity.x == 0:
		if animation_mode.get_current_node() != "idle":
			can_stand_by_animation = true
			stand_by_animation_current = 0
			animation_mode.travel("idle")
	else:
		can_stand_by_animation = false


func _unhandled_input(event):
	# --- CLICK ---
	if event.is_action_pressed("click"):
		is_pressing_click = true
		if checking_landing:
			animation_mode.travel("air_attack_punch")
		else:
			if velocity.x == 0:
				animation_mode.travel("attack_punch")
			else:
				animation_mode.travel("attack_punch_run")
	elif event.is_action_released("click"):
		is_pressing_click = false
		
	# --- RIGHT ---
	if event.is_action_pressed("right"):
		is_pressing_right = true
		if is_on_floor():
			animation_mode.travel("run")
	elif event.is_action_released("right"):
		is_pressing_right = false
		
	# --- LEFT ---
	if event.is_action_pressed("left"):
		is_pressing_left = true
		if is_on_floor():
			animation_mode.travel("run")
	elif event.is_action_released("left"):
		is_pressing_left = false
		
	# --- UP ---
	if event.is_action_pressed("up"):
		is_pressing_up = true
	elif event.is_action_released("up"):
		is_pressing_up = false
	
	if (is_pressing_click or is_pressing_right or is_pressing_left or is_pressing_up):
		stand_by_animation_current = 0
	
	# --- DEBUG ---
	if event.is_action_pressed("debug"):
		receive_damage(10)
		
func play_sfx(sfx_name:String):
	if sfx_name == "footstep":
		sfx_manager.play_sfx_footstep()
	elif sfx_name == "squat":
		sfx_manager.play_sfx_squat()
	elif sfx_name == "jump":
		sfx_manager.play_sfx_jump()
	elif sfx_name == "attack_punch":
		sfx_manager.play_sfx_attack_punch()

func attack(name:String):
	if name == "punch":
		enable_hand_right_rb(true)

func stop_attacking():
	enable_hand_right_rb(false)

func enable_hand_right_rb(is_enabled:bool):
	hand_right_area.visible = is_enabled
	hand_right_area.monitoring = is_enabled

func apply_damage(body):
	if body != self:
		if body.has_method("receive_damage"):
			body.receive_damage(attack_damage_value)
	
func receive_damage(damage_value:int):
	health -= damage_value
	sprites.modulate = Color(1,0.2,0.2)
	if checking_landing:
		animation_mode.travel("damaged_air")
	else:
		if velocity.x == 0:
			animation_mode.travel("damaged")
		else:
			animation_mode.travel("damaged_run")
