extends Node2D

@export var cm:Node2D
const HAND_COUNT:int = 7
const FIXED_Y_POS = 890
const CARD_WIDTH = 132
const CARD_SCENE = preload("res://scenes/cards/card.tscn")
var player_card:Array = []
var center_screen_x:float
var bottom_screen_y:float

func _ready() -> void:
	center_screen_x = get_viewport_rect().size.x/2
	bottom_screen_y = get_viewport_rect().size.y - 100
	for i in range(0,HAND_COUNT):
		var new_card = CARD_SCENE.instantiate()
		cm.add_child(new_card)
		new_card.name  = "Card"
		add_card_to_hand(new_card)
		
		
func add_card_to_hand(card:Node2D)->void:
	if card not in player_card:
		player_card.insert(0,card)
		update_hand_pos()
	else:
		animate_card_to_pos(card,card.card_hand_pos)
func update_hand_pos()->void:
	for i in range(player_card.size()):
		var new_pos:Vector2 = Vector2(calculate_car_pos(i), bottom_screen_y)
		var new_card = player_card[i]
		new_card.card_hand_pos  = new_pos
		animate_card_to_pos(new_card,new_pos)
func calculate_car_pos(index:int)->float:
	var total_width = (player_card.size()-1)* CARD_WIDTH
	var x_offset = center_screen_x  + index * CARD_WIDTH - total_width/2
	return x_offset

func animate_card_to_pos(card,new_pos):
	var tween = get_tree().create_tween()
	tween.tween_property(card,"position",new_pos,0.1)

func  remove_card_from_hand(card)->void:
	if card in player_card:
		player_card.erase(card)
		update_hand_pos()
	
