extends Node2D
class_name InputManager

signal left_mouse_clicked
signal left_mouse_released

@export_category('Ojects')
@onready var card_manager: CardManager = get_node('../CardManager')

@export_category('Collsion Masks')
const COLLISION_LAYER_CARD = 1
const COLLISION_LAYER_CARD_SLOT = 2
const COLLISION_LAYER_DECK = 4

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('drag'):
		raycast_at_cursor()
		left_mouse_clicked.emit()
		
	if event.is_action_released('drag'):
		card_manager.stop_drag()
		left_mouse_released.emit()

# detects nodes where the mouse is
func raycast_at_cursor():
	var space = get_world_2d().direct_space_state
	var point_parameters = PhysicsPointQueryParameters2D.new()
	point_parameters.collide_with_areas = true
	point_parameters.position = get_global_mouse_position()
	var results = space.intersect_point(point_parameters)
	
	if results.size() == 0: return null

	var first_item = results[0].collider as Area2D
	# clicks on a card
	if first_item.collision_layer == COLLISION_LAYER_CARD:
		var cards: Array[Card] = []
		for result in results:
			var card = first_item.get_parent()
			if  card is Card: 
				cards.append(card)
				
		print(cards)
		# drag card on the top
		var card_on_top = get_card_on_top(cards)
		return card_on_top
		
	# clicks on a card slot
	elif first_item.collision_layer == COLLISION_LAYER_CARD_SLOT:
		var card_slot = first_item.get_parent() 
		if card_slot is CardSlot:
			return card_slot
			
	# clicks on the deck
	elif first_item.collision_layer == COLLISION_LAYER_DECK:
		return first_item.get_parent() 
		
func get_card_on_top(cards: Array[Card]) -> Card:
	if cards.size() == 0: return
	var top_card = cards[0]
	var top_z_index = cards[0].z_index
	
	for card in cards:
		if card.z_index > top_z_index:
			top_z_index = card.z_index
			top_card = card
			
	return top_card
