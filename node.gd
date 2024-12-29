extends Control


var spline_matrices: Array[Matrix] = [
	# bezier
	Matrix.from_data([
		[ 1,  0,  0,  0],
		[-3,  3,  0,  0],
		[ 3, -6,  3,  0],
		[-1,  3, -3,  1],
	]),
	# hermite
	Matrix.from_data([
		[ 1,  0,  0,  0],
		[ 0,  1,  0,  0],
		[-3, -2,  3, -1],
		[ 2,  1, -2,  1],
	]),
	# catmull-rom
	Matrix.from_data([
		[ 0,  2,  0,  0],
		[-1,  0,  1,  0],
		[ 2, -5,  4, -1],
		[-1,  3, -3,  1],
	]).fmul(0.5),
	# b-spline
	Matrix.from_data([
		[ 1,  4,  1,  0],
		[-3,  0,  3,  0],
		[ 3, -6,  3,  0],
		[-1,  3, -3,  1],
	]).fmul(1.0 / 6.0),
	
]


@onready var matrix_edit: MatrixEdit = %MatrixEdit
@onready var graphs: Array[Graph] = [
	%Graph0,
	%Graph1,
	%Graph2,
	%Graph3,
]


var drags: Array[DragContainer]
var matrix: Matrix


func _ready() -> void:
	drags.assign(get_children().filter(func(e): return e is DragContainer))
	for drag in drags:
		drag.dragged.connect(queue_redraw)
	matrix_edit.matrix_changed.connect(func(): matrix = matrix_edit.get_matrix())
	matrix = matrix_edit.get_matrix()


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
		
		
		var coeff := t_matrix.matmul(matrix)
		var x := coeff.matmul(point_matrix_x).value()
		var y := coeff.matmul(point_matrix_y).value()
		
		for j in graphs.size():
			graphs[j].points[i] = coeff.getxy(j, 0)
		
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


func _on_option_button_item_selected(index: int) -> void:
	var current_matrix := matrix_edit.get_matrix()
	var new_matrix := spline_matrices[index]
	var lerp_matrix := current_matrix
	#var t := create_tween()
	var update_matrix := func(): matrix_edit.set_matrix(lerp_matrix)
	#t.tween_callback(func(): matrix_edit.editable = false)
	#t.tween_method(
		#func(t: float) -> void:
			#var lerp_mat := current_matrix.lerp_weights(new_matrix, t)
			#matrix_edit.set_matrix(lerp_mat),
		#0.0,
		#1.0,
		#1.0
	#).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	#t.tween_callback(func(): matrix_edit.editable = true)
	#matrix_edit.set_matrix(spline_matrices[index].duplicated())
	for x in current_matrix.get_width():
		for y in current_matrix.get_height():
			var t := create_tween()
			t.tween_method(
				func(t: float) -> void:
					lerp_matrix.setxy(x, y, t)
					update_matrix.call_deferred(),
				current_matrix.getxy(x, y),
				new_matrix.getxy(x, y),
				0.5
			).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
