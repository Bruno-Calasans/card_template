extends Node2D
class_name CardManager

@export_category('Objects')
@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var player_hand: PlayerHand = get_node("../PlayerHand")

var hovering_card = false # can be one hover effect at once
var dragged_card: Node2D = null

@export_category('Collsion Masks')
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed('drag'):
		var card = check_for_card()
		
		if card is Card:
			start_drag(card)
		
	if event.is_action_released('drag'):
		stop_drag()
		
# detects any collideble shape using the mouse
func check_for_card():
	var space = get_world_2d().direct_space_state
	var point_parameters = PhysicsPointQueryParameters2D.new()
	point_parameters.collide_with_areas = true
	point_parameters.collision_mask = COLLISION_MASK_CARD
	point_parameters.position = get_global_mouse_position()
	
	var results = space.intersect_point(point_parameters)
	var cards: Array[Card] = []
	
	if results.size() == 0: return null
	
	for result in results:
		var card = result.collider.get_parent()
		if  card is Card: cards.append(card)
		
	return get_card_on_top(cards)
		
func check_for_card_slot() -> CardSlot:
	var space = get_world_2d().direct_space_state
	var point_parameters = PhysicsPointQueryParameters2D.new()
	point_parameters.collide_with_areas = true
	point_parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	point_parameters.position = get_global_mouse_position()

	var results = space.intersect_point(point_parameters)
	if results.size() == 0: return null
	
	var card_slot = results[0].collider.get_parent() 
	if card_slot is not CardSlot: return null
	
	return card_slot
	
# drags the card and limit its position to the screen's size
func drag_card():
	if dragged_card:
		var card_area = dragged_card.get_node('CardArea/CardCollision') as CollisionShape2D
		var card_size = card_area.shape.get_rect().size
		var card_width = card_size.x
		var card_height = card_size.y
		
		var mouse_pos = get_global_mouse_position()
		var x_pos = clamp(mouse_pos.x, card_width / 2, screen_size.x - card_width / 2)
		var y_pos = clamp(mouse_pos.y, card_height / 2, screen_size.y - card_height / 2)
		dragged_card.global_position = Vector2(x_pos, y_pos)

# keep the drag effect while the card is being hovered over
func start_drag(card: Card):
	# card being moved out a card slot
	"var card_slot_found = check_for_card_slot()
	print(card_slot_found)
	print(card_slot_found.occupied_card.get_instance_id())
	var is_exiting_card_slot = card_slot_found.occupied_card.get_instance_id() == card.get_instance_id()
	if card_slot_found and is_exiting_card_slot:
		card_slot_found.ocuppied = false
		card_slot_found.occupied_card = null"
		
	dragged_card = card
	dragged_card.scale = Vector2(1.05, 1.05)
	
# stops the drag effect while the hovering stops
func stop_drag():
	if dragged_card:
		# card dropped in a card slot
		var card_slot_found = check_for_card_slot()
		if card_slot_found and not card_slot_found.ocuppied:
			var card_slot_area = card_slot_found.get_node('./CardSlotCollisionArea')
			dragged_card.global_position = card_slot_area.global_position
			card_slot_found.ocuppied = true
			card_slot_found.occupied_card = dragged_card
			player_hand.remove_card_from_hand(dragged_card)
			
		else:
			player_hand.add_card_to_hand(dragged_card)
			
		dragged_card.scale = Vector2(1, 1)
		dragged_card = null

func connect_card_signals(card: Card):
	if card:
		card.connect('hovered_on', hover_over_card)
		card.connect('hovered_off', hover_off_card)
		
func hover_over_card(card: Card):
	if not hovering_card: 
		hovering_card = true
		highlight_card(card, true)
	
func hover_off_card(card: Card):
	if not dragged_card:
		highlight_card(card, false)
		# check if there's a new card after the card
		var new_card = check_for_card()
		if new_card:
			highlight_card(new_card, true)
		else:
			hovering_card = false
		
func highlight_card(card: Card, hovered: bool):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 100
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1

func get_card_on_top(cards: Array[Card]):
	if cards.size() == 0: return
	var top_card = cards[0]
	var top_z_index = cards[0].z_index
	
	for card in cards:
		if card.z_index > top_z_index:
			top_z_index = card.z_index
			top_card = card
	return top_card

func _process(delta: float) -> void:
	drag_card()
