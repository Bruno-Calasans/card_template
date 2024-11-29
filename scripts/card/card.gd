extends Node2D
class_name Card

signal hovered_on
signal hovered_off

var start_hand_position: Vector2

@onready var card_animation: AnimationPlayer = get_node("CardAnimation")

func _ready() -> void:
	var parent = get_parent()
	if parent is CardManager:
		parent.connect_card_signals(self)
		
		
func update_card_image(path: NodePath):
	var card_img: Sprite2D = get_node('Front/FrontTexture')
	card_img.texture = load(str(path))
	
func update_name(name: String):
	var card_name: Label = get_node('Front/Labels/CardName') 
	card_name.text = name
	
func update_health(health: String):
	var card_health: Label = get_node('Front/Labels/Health') 
	card_health.text = health
	
func update_basic_atk(atk: String):
	var card_basic_atk: Label = get_node('Front/Labels/BasicAtk') 
	card_basic_atk.text = atk

func update_desc(desc: String):
	var card_desc: Label = get_node('Front/Labels/CardDesc') 
	card_desc.text = desc

func update_type(type: String):
	var card_type: Label = get_node('Front/Labels/CardType') 
	card_type.text = type

func on_card_area_mouse_entered() -> void:
	hovered_on.emit(self)

func on_card_area_mouse_exited() -> void:
	hovered_off.emit(self)
