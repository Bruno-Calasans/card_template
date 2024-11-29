extends Node2D
class_name Deck


@onready var player_hand: PlayerHand = get_node("../PlayerHand")
@onready var card_manager: CardManager = get_node("../CardManager")
@onready var card_counter: Label = get_node('CardCounter')
@onready var deck_texture: Sprite2D = get_node('DeckTexture')
@onready var deck_collision: CollisionShape2D = get_node('DeckArea/DeckCollision') 
		
var start_deck_cards = 10
var player_deck: Array[Card] = []

const DEFAULT_DRAW_CARD_SPEED = 0.5

func _ready() -> void:
	create_deck(start_deck_cards)
	update_card_counter(player_deck.size())

func create_deck(quant: int):
	var card_scene: PackedScene = preload("res://scenes/card.tscn")
	var card_database = preload("res://scripts/card_database.gd")

	for i in range(0, quant):
		var card_info = card_database.CARDS[randi_range(0, card_database.CARDS.size() - 1)]
		var card = card_scene.instantiate()
		card.update_name(card_info.name)
		card.update_basic_atk(card_info.basic_atk)
		card.update_desc(card_info.desc)
		card.update_health(card_info.health)
		card.update_type(card_info.type)
		card.update_card_image(card_info.path)
		player_deck.append(card)

func update_card_counter(value: int):
	card_counter.text = str(value)

func draw_card(quant: int = 1, exact = false):
	
	# cant draw the exact cards
	if exact and player_deck.size() != quant: 
		return false
		
	# no cards to draw (deck out)
	if player_deck.size() == 0: 
		deck_collision.disabled = false
		deck_texture.visible = false
		card_counter.visible = false
	
	else:
		# can draw cards	
		for i in range(0, quant):
			var card = player_deck[i]
			card_manager.add_child(card)
			player_hand.add_card_to_hand(card, DEFAULT_DRAW_CARD_SPEED)
			card.card_animation.play('flip')
		player_deck = player_deck.slice(quant)
		update_card_counter(player_deck.size())
	
