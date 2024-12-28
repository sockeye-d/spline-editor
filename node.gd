extends Control


@onready var matrix_edit: MatrixEdit = %MatrixEdit
@onready var graphs: Array[Graph] = [
	%Graph0,
	%Graph1,
	%Graph2,
	%Graph3,
]


var drags: Array[DragContainer]


func _ready() -> void:
	drags.assign(get_children().filter(func(e): return e is DragContainer))
	for drag in drags:
		drag.dragged.connect(queue_redraw)


func _draw() -> void:
	var points: PackedVector2Array
	points.resize(100)
	for j in graphs.size():
			graphs[j].points.resize(100)
	for i in 100:
		var t := float(i) / 99
		var t_matrix := Matrix.from_data([[1.0, t, t*t, t*t*t]])
		# bezier
		#var characteristic_matrix := Matrix.from_data([
			#[ 1,  0,  0,  0],
			#[-3,  3,  0,  0],
			#[ 3, -6,  3,  0],
			#[-1,  3, -3,  1],
		#])
		#var characteristic_matrix := Matrix.from_data([
			#[ 1,  4,  1,  0],
			#[-3,  0,  3,  0],
			#[ 3, -6,  3,  0],
			#[-1,  3, -3,  1],
		#]).fmul(1.0 / 6.0)
		var point_matrix_x := Matrix.from_data([
			[drags[0].get_center_position().x],
			[drags[1].get_center_position().x],
			[drags[2].get_center_position().x],
			[drags[3].get_center_position().x],
		])
		var point_matrix_y := Matrix.from_data([
			[drags[0].get_center_position().y],
			[drags[1].get_center_position().y],
			[drags[2].get_center_position().y],
			[drags[3].get_center_position().y],
		])
		
		
		var coeff := t_matrix.matmul(matrix_edit.matrix)
		var x := coeff.matmul(point_matrix_x).value()
		var y := coeff.matmul(point_matrix_y).value()
		
		for j in graphs.size():
			graphs[-1-j].points[i] = coeff.getxy(j, 0)
		
		points[i] = Vector2(x, y)
	
	draw_lines([
		drags[0].get_center_position(),
		drags[1].get_center_position(),
		drags[2].get_center_position(),
		drags[3].get_center_position(),
	], Color.WHITE, 1.0, true)
	draw_polyline(points, Color.RED, 1.0, true)


func draw_lines(points: PackedVector2Array, color: Color, width: float = -1.0, antialiased: bool = false) -> void:
	assert(points.size() >= 2, "must have at least 2 points")
	for i in points.size() - 1:
		draw_line(points[i], points[i + 1], color, width, antialiased)


func _on_matrix_edit_matrix_changed() -> void:
	queue_redraw()
