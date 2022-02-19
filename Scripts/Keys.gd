extends Node2D

onready var kEyA = $A
onready var kEyW = $W
onready var kEyS = $S
onready var kEyD = $D
onready var kEyQ = $Q
onready var kEyJ = $J
onready var kEyI = $I


func _process(delta):
	if Input.is_action_pressed("Up"):
		kEyW.visible = false
	else:
		kEyW.visible = true

	if Input.is_action_pressed("Down"):
		kEyS.visible = false
	else:
		kEyS.visible = true

	if Input.is_action_pressed("Left"):
		kEyA.visible = false
	else:
		kEyA.visible = true

	if Input.is_action_pressed("Right"):
		kEyD.visible = false
	else:
		kEyD.visible = true

	if Input.is_action_pressed("SwitchWeapon"):
		kEyQ.visible = false
	else:
		kEyQ.visible = true

	if Input.is_action_pressed("Dash"):
		kEyI.visible = false
	else:
		kEyI.visible = true

	if Input.is_action_pressed("attack"):
		kEyJ.visible = false
	else:
		kEyJ.visible = true
