extends Node2D
class_name CardManager

@export_category('Objects')
@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var player_hand: PlayerHand = get_node("../PlayerHand")
@onready var input_manager: InputManager = get_node('../InputManager')
@onready var deck: Deck = get_node('../Deck')

var hovering_card = false # can be one hover effect at once
var dragged_card: Node2D = null

func _ready() -> void:
	connect_input_manager_signals()

func left_mouse_clicked():
	var card = input_manager.raycast_at_cursor()
	
	if not card: return
	
	if card is Card:
		start_drag(card)
		
	elif card is Deck:
		deck.draw_card(1)
	
func left_mouse_released():
	var card = input_manager.raycast_at_cursor()
	if card and card is Card:
		stop_drag()
	
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
	# todo card being moved out a card slot
	dragged_card = card
	dragged_card.scale = Vector2(1.05, 1.05)
	
# stops the drag effect while the hovering stops
func stop_drag():
	if dragged_card:
		# card dropped in a card slot
		var card_slot_found = input_manager.raycast_at_cursor()
		if card_slot_found and card_slot_found is CardSlot and not card_slot_found.ocuppied:
			var card_slot_area = card_slot_found.get_node('./CardSlotCollisionArea')
			dragged_card.global_position = card_slot_area.global_position
			card_slot_found.ocuppied = true
			card_slot_found.occupied_card = dragged_card
			player_hand.remove_card_from_hand(dragged_card)
			
		else:
			player_hand.add_card_to_hand(dragged_card)
			
		dragged_card.scale = Vector2(1, 1)
		dragged_card = null

func connect_input_manager_signals():
	if input_manager:
		input_manager.connect('left_mouse_clicked', left_mouse_clicked)
		input_manager.connect('left_mouse_released', left_mouse_released)

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
		var new_card = input_manager.raycast_at_cursor()
		if new_card and new_card is Card:
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

func _process(delta: float) -> void:
	drag_card()
