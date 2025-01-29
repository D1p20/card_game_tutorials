extends Node2D

enum CARD_STATE { READY, DRAG, RELEASED }
const _CARD_COL_MASK: int = 1
const _SLOT_COL_MASK: int = 2
var _card_state: CARD_STATE = CARD_STATE.READY
var _current_card: Node2D = null
var _screen_size: Vector2
var _sprite_width: float = 90.0
var _sprite_height: float = 133.0
var _card_start: Vector2 = Vector2.ZERO
var _is_cared_hovered: bool = false
#@onready var player: Node2D = $card
@onready var player_hand: Node2D = $"../player_hand"

func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	_screen_size = get_viewport_rect().size

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_current_card = _card_raycast_detection()
			if _current_card:
				_card_state = CARD_STATE.DRAG
				_card_start = get_global_mouse_position() - _current_card.global_position
		else:
			if _card_state == CARD_STATE.DRAG:
				_card_state = CARD_STATE.RELEASED

func _process(_delta: float) -> void:
	match _card_state:
		CARD_STATE.DRAG:
			var mouse_pos = get_global_mouse_position() - _card_start
			_current_card.position = Vector2(
				clamp(mouse_pos.x, _sprite_width / 2, _screen_size.x - _sprite_width / 2),
				clamp(mouse_pos.y, _sprite_height / 2, _screen_size.y - _sprite_height / 2)
			)
		CARD_STATE.RELEASED:
			if _current_card:
				_dragged_finished()

func _dragged_finished() -> void:
	var current_slot: Node2D = _slot_raycast_detection()
	if current_slot and not current_slot.is_slot_occupied:
		_slotted_card_manager(current_slot, _current_card)
		player_hand.remove_card_from_hand(_current_card)
		_current_card = null
	else:
		player_hand.add_card_to_hand(_current_card)
		_current_card = null
		
	_card_state = CARD_STATE.READY

# Detect which card is clicked on
func _card_raycast_detection() -> Node2D:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = _CARD_COL_MASK
	var result: Array[Dictionary] = space_state.intersect_point(parameters)
	if result.size() > 0:
		var top_card: Node2D = _get_top_card(result)
		return top_card
	else:
		return null

func _slot_raycast_detection() -> Node2D:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = _SLOT_COL_MASK
	var result: Array[Dictionary] = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	else:
		return null

func _get_top_card(cards: Array[Dictionary]):
	var top_card: Node2D = cards[0].collider.get_parent()
	var top_z_index: int = top_card.z_index

	for i in range(1, cards.size()):
		var current_card: Node2D = cards[i].collider.get_parent()
		if current_card.z_index > top_z_index:
			top_card = current_card
			top_z_index = current_card.z_index
	return top_card

func _on_window_size_changed() -> void:
	_screen_size = get_viewport_rect().size

func _get_dragged_vector() -> Vector2:
	return get_global_mouse_position() - position

func _connect_to_card(card: Node2D) -> void:
	card.mouse_entered.connect(_on_mouse_entered)
	card.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered(card: Node2D) -> void:
	if not _is_cared_hovered:
		_is_cared_hovered = true
		_highlight_card(card, true)

func _on_mouse_exited(card: Node2D) -> void:
	_highlight_card(card, false)
	var new_card: Node2D = _card_raycast_detection()
	if new_card:
		_highlight_card(new_card, true)
	else:
		_is_cared_hovered = false

func _highlight_card(card: Node2D, is_hovered: bool) -> void:
	if is_hovered:
		card.scale = Vector2(1.03, 1.03)
		card.z_index = 3
	else:
		card.scale = Vector2(1,1)
		card.z_index = 2

func _slotted_card_manager(slot: Node2D, card:Node2D) -> void:
	card.global_position = slot.global_position
	#card.get_node("draggable_area_card/CollisionShape2D").disabled = true
	#card.scale = Vector2(1,1)
	card.set_card_col_state(true)
	slot.change_slot_state(true)
	
