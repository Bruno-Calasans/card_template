extends Node2D
class_name PlayerHand

@onready var screen_x_center = get_viewport().size.x / 2
@onready var screen_y_center = get_viewport().size.y / 2

@export var hand_card_count = 4
var player_hand: Array[Card] = []

const CARD_WIDTH = 100
const HAND_Y_POSITION = 200

func _ready() -> void:
	var card_scene: PackedScene = preload("res://scenes/card.tscn")
	
	for hand in hand_card_count:
		var card = card_scene.instantiate()
		var card_manager = get_node('../CardManager')
		card_manager.add_child(card)
		add_card_to_hand(card)
		
func add_card_to_hand(card: Card):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.start_hand_position)
	
func remove_card_from_hand(card: Card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
	
# determines hand card position
func update_hand_positions():
	for card_index in range(0, player_hand.size()):
		var card = player_hand[card_index]
		var new_position = Vector2(calculate_card_position(card_index), HAND_Y_POSITION)
		card.start_hand_position = new_position
		animate_card_to_position(card, new_position)
		
# to where t he card is gonna desclocate
func calculate_card_position(index: int):
	var total_hand_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = screen_x_center - index * CARD_WIDTH - total_hand_width / 2
	return x_offset
	
func animate_card_to_position(card: Card, position: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(card, 'position', position, 0.2)
	tween.play()
	
