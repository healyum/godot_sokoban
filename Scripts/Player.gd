extends KinematicBody2D

onready var ray = $RayCast2D
onready var rayUP = $RayUP
onready var rayDOWN = $RayDOWN
onready var rayLEFT = $RayLEFT
onready var rayRIGHT = $RayRIGHT

var speed = 256 # big number because it's multiplied by delta
var tile_size = 32 # size in pixels of tiles on the grid

export var push_speed : = 125.0

var last_position = Vector2() # last idle position
var target_position = Vector2() # desired position to move towards
var movedir = Vector2() # move direction

func _ready():
	position = position.snapped(Vector2(tile_size, tile_size)) # make sure player is snapped to grid
	last_position = position
	target_position = position

func _physics_process(delta):
	
	# MOVEMENT
	if ray.is_colliding():
		position = last_position
		target_position = last_position
	else:
		position += speed * movedir * delta
		
		if position.distance_to(last_position) >= tile_size - speed * delta: # if we've moved further than one space
			position = target_position # snap the player to the intended position
	
	# IDLE
	if position == target_position:
		get_movedir()
		last_position = position # record the player's current idle position
		target_position += movedir * tile_size # if key is pressed, get new target (also shifts to moving state)
	
	# MOVE BOXES
	if rayLEFT.is_colliding():
		var box = rayLEFT.get_collider().get_parent()
		rayLEFT.get_collider().get_parent().push(Vector2(-tile_size, 0))		
		
	if rayRIGHT.is_colliding():
		var box = rayRIGHT.get_collider().get_parent()
		rayRIGHT.get_collider().get_parent().push(Vector2(tile_size, 0))
		
	if rayUP.is_colliding():
		var box = rayUP.get_collider().get_parent()
		#print(box.position)
		#position = rayUP.get_collider().get_parent().position - Vector2(0, tile_size)
		print(rayUP.get_collider().get_parent().push(Vector2(0, -tile_size)))
		#print(rayUP.get_collider().get_parent().get_name())		
		
	if rayDOWN.is_colliding():
		var box = rayDOWN.get_collider().get_parent()
		rayDOWN.get_collider().get_parent().push(Vector2(0, tile_size))
	
# GET DIRECTION THE PLAYER WANTS TO MOVE
func get_movedir():
	var LEFT = Input.is_action_pressed("ui_left")
	var RIGHT = Input.is_action_pressed("ui_right")
	var UP = Input.is_action_pressed("ui_up")
	var DOWN = Input.is_action_pressed("ui_down")

	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)
	
	if movedir.x != 0 && movedir.y != 0: # prevent diagonals
		movedir = Vector2.ZERO
	if movedir != Vector2.ZERO:
		ray.cast_to = movedir * tile_size / 2
		ray.force_raycast_update() #useful ?
