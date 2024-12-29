@tool
class_name DragContainer extends SimpleContainer


signal dragged


const NONE = Vector2(-1, -1)


var initial_drag_location: Vector2 = NONE


func _gui_input(_e: InputEvent) -> void:
	if _e is InputEventMouseButton:
		var e := _e as InputEventMouseButton
		
		if e.pressed and initial_drag_location == NONE:
			initial_drag_location = e.position
		elif not e.pressed:
			initial_drag_location = NONE
	
	if _e is InputEventMouseMotion:
		var e := _e as InputEventMouseMotion
		
		if initial_drag_location != NONE:
			position += e.relative
			dragged.emit()


func get_center_position() -> Vector2:
	return position + size * 0.5
