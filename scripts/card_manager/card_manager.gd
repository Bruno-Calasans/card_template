extends Node2D
class_name CardManager

var dragged_card: Node2D = null
@onready var screen_size: Vector2 = get_viewport_rect().size

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed('drag'):
		print('click left mouse')
		print(screen_size)
		
		var card = check_for_card()
		if card and card.name.contains('Card'):
			print('Click card')
			dragged_card = card
		
	if event.is_action_released('drag'):
		print('click left mouse released')	
		dragged_card = null
		
# detects any collideble shape using the mouse
func check_for_card():
	var space = get_world_2d().direct_space_state
	var point_parameters = PhysicsPointQueryParameters2D.new()
	point_parameters.collide_with_areas = true
	point_parameters.collision_mask = 1
	point_parameters.position = get_global_mouse_position()
	var result = space.intersect_point(point_parameters)
	
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# drags the card and limit its position to the screen's size
func drag_card():
	if dragged_card:
		var card_area = dragged_card.get_node('CardArea/CardCollision') as CollisionShape2D
		var card_size = card_area.shape.get_rect().size
		var card_width = card_size.x
		var card_height = card_size.y
		print(card_size)
		
		var mouse_pos = get_global_mouse_position()
		var x_pos = clamp(mouse_pos.x, card_width / 2, screen_size.x - card_width / 2)
		var y_pos = clamp(mouse_pos.y, card_height / 2, screen_size.y - card_height / 2)
		dragged_card.global_position = Vector2(x_pos, y_pos)

func _process(delta: float) -> void:
	drag_card()
