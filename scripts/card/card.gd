extends Node2D
class_name Card

signal hovered_on
signal hovered_off

var start_hand_position: Vector2

func _ready() -> void:
	var parent = get_parent()
	if parent is CardManager:
		parent.connect_card_signals(self)

func on_card_area_mouse_entered() -> void:
	hovered_on.emit(self)


func on_card_area_mouse_exited() -> void:
	hovered_off.emit(self)
