@tool
class_name DragContainer extends Container


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


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var r := get_rect()
		for _child in get_children():
			if _child is not Control:
				continue
			var child := _child as Control
			
			fit_child_in_rect(child, Rect2(Vector2.ZERO, size))


func _get_minimum_size() -> Vector2:
	var minsize := Vector2.ZERO
	for _child in get_children():
		if _child is not Control:
			continue
		var child := _child as Control
		
		minsize = minsize.max(child.get_combined_minimum_size())
	return minsize


func get_center_position() -> Vector2:
	return position + size * 0.5
