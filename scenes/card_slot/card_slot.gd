extends Node2D

var is_slot_occupied = false

func change_slot_state(value:bool)->void:
	is_slot_occupied = value
