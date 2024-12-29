@tool
class_name SimpleContainer extends Container


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
