@tool
class_name Graph extends Control


@export var axis: Vector2.Axis = Vector2.AXIS_X:
	set(value):
		axis = value
		queue_redraw()
@export var ratio: float = 1.0:
	set(value):
		ratio = value
		update_minimum_size()
@export var points: PackedFloat64Array:
	set(value):
		points = value
		queue_redraw()
@export var min_y: float = -0.5:
	set(value):
		min_y = value
		queue_redraw()
@export var max_y: float = 1.0:
	set(value):
		max_y = value
		queue_redraw()
@export var draw_center: bool:
	set(value):
		draw_center = value
		queue_redraw()
@export var graph_color: Color = Color.WHITE
@export var center_color: Color = Color(1.0, 1.0, 1.0, 0.2)
@export var graph_thickness: float = 1.0
@export var center_thickness: float = 1.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		update_minimum_size()


func _draw() -> void:
	var center := Vector2(0.5 * size.x, remap(0.0, min_y, max_y, size.y, 0.0))
	draw_line(Vector2(0.0, center.y), Vector2(size.x, center.y), center_color, center_thickness, true)
	draw_line(Vector2(center.x, 0.0), Vector2(center.x, size.y), center_color, center_thickness, true)
	var points_scaled: PackedVector2Array
	points_scaled.resize(points.size())
	for i in points.size():
		points_scaled[i] = Vector2(
			remap(i, 0.0, points.size() - 1, 0.0, size.x),
			remap(points[i], min_y, max_y, size.y, 0.0)
		)
	draw_polyline(points_scaled, graph_color, graph_thickness, true)


func _get_minimum_size() -> Vector2:
	if axis == Vector2.AXIS_X:
		return Vector2(size.y * ratio, 0.0)
	if axis == Vector2.AXIS_Y:
		return Vector2(0.0, size.x * ratio)
	return Vector2.ZERO
