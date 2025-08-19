extends Node3D
@onready var label_3d: Label3D = $Label3D

var player_near = false

func _ready():
	label_3d.visible = false
	pass

func show_label():
	label_3d.visible = true

func hide_label():
	label_3d.visible = false
