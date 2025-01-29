extends Node2D

signal mouse_entered
signal mouse_exited
@onready var _card_col_state: CollisionShape2D = $draggable_area_card/CollisionShape2D
@onready var label: Label = $Label
var card_hand_pos:Vector2 = Vector2.ZERO

func _ready() -> void:
	get_parent()._connect_to_card(self)


func _on_mouse_entered() -> void:
	#mouse_entered.emit()
	emit_signal("mouse_entered",self)

func _on_mouse_exited() -> void:
	#mouse_exited.emit()
	emit_signal("mouse_exited",self)

func set_card_col_state(value:bool)->void:
	_card_col_state.disabled = value

func set_power(value:int)->void:
	label.text = str(value)
