extends Node
onready var head = $dummy_head
onready var body = $dummy_body

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_released("ui_up"):
		move_child ( body, 0 )
		print('up')
	elif Input.is_action_just_released("ui_down"):
		move_child ( body, 1 )
		print('down')
