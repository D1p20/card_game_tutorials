extends Control


@onready var menu: Panel = $menu


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("show_menu"):
		menu.visible = not menu.visible
		

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
