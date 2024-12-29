@tool
class_name MatrixEdit extends GridContainer


signal matrix_changed


@export var matrix_width: int:
	set(value):
		matrix_width = value
		_regenerate_edits()
@export var matrix_height: int:
	set(value):
		matrix_height = value
		_regenerate_edits()
@export var editable: bool = true:
	set(value):
		editable = value
		for edit in edits:
			edit.editable = editable


var edits: Array[MatrixLineEdit]


var _data: PackedFloat64Array


func _ready() -> void:
	var matrix := Matrix.from_data(
	##[
		##[ 1,  0,  0,  0],
		##[-3,  3,  0,  0],
		##[ 3, -6,  3,  0],
		##[-1,  3, -3,  1],
	##]
	[
		[ 1 / 6.0,  4 / 6.0,  1 / 6.0,  0 / 6.0],
		[-3 / 6.0,  0 / 6.0,  3 / 6.0,  0 / 6.0],
		[ 3 / 6.0, -6 / 6.0,  3 / 6.0,  0 / 6.0],
		[-1 / 6.0,  3 / 6.0, -3 / 6.0,  1 / 6.0],
	])
	
	set_matrix(matrix)
	#matrix_changed.emit()


func _regenerate_edits() -> void:
	var length := matrix_width * matrix_height
	columns = matrix_width
	for edit in edits:
		remove_child(edit)
		edit.queue_free()
	edits.resize(length)
	_data.resize(length)
	for i in length:
		edits[i] = MatrixLineEdit.new()
		edits[i].gui_input.connect(_on_child_edit_gui_input.bind(edits[i]))
		edits[i].changed.connect(func(new_value: float):
			_data[i] = new_value
			matrix_changed.emit()
		)
		add_child(edits[i])
	_update_edits()


func _update_edits() -> void:
	for i in edits.size():
		edits[i].text = str(_data[i])


func _on_child_edit_gui_input(event: InputEvent, child: MatrixLineEdit) -> void:
	if child.has_focus():
		if event.is_action_pressed(&"ui_right", true) and child.caret_column == child.text.length():
			_move_caret(child, 1)
		if event.is_action_pressed(&"ui_left", true) and child.caret_column == 0:
			_move_caret(child, -1)
		
		if event.is_action_pressed(&"ui_down", true):
			_move_caret(child, columns)
		if event.is_action_pressed(&"ui_up", true):
			_move_caret(child, -columns)


func _move_caret(child: MatrixLineEdit, amount: int) -> void:
	var child_i := edits.find(child)
	if child_i == -1:
		return
	child_i += amount
	if child_i < 0 or child_i >= edits.size():
		return
	child.unedit()
	edits[child_i].edit.call_deferred()


func set_matrix(new_matrix: Matrix) -> void:
	_data = new_matrix.get_array()
	
	if new_matrix.get_width() != matrix_width or new_matrix.get_height() != matrix_height:
		# these will regenerate the edits
		matrix_width = new_matrix.get_width()
		matrix_height = new_matrix.get_height()
	else:
		_update_edits()
	
	matrix_changed.emit()


func get_matrix() -> Matrix:
	return Matrix.from_array(_data, matrix_width)
