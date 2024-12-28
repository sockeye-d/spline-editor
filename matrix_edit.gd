@tool
class_name MatrixEdit extends GridContainer


signal matrix_changed


var edits: Array[MatrixLineEdit]


## please don't modify 🥺
var matrix: Matrix


func _ready() -> void:
	matrix = Matrix.new()
	matrix.width = 4
	matrix.height = 4
	matrix.data = \
	#[
		#[ 1,  0,  0,  0],
		#[-3,  3,  0,  0],
		#[ 3, -6,  3,  0],
		#[-1,  3, -3,  1],
	#]
	[
		[ 1 / 6.0,  4 / 6.0,  1 / 6.0,  0 / 6.0],
		[-3 / 6.0,  0 / 6.0,  3 / 6.0,  0 / 6.0],
		[ 3 / 6.0, -6 / 6.0,  3 / 6.0,  0 / 6.0],
		[-1 / 6.0,  3 / 6.0, -3 / 6.0,  1 / 6.0],
	]
	matrix.changed.connect(_on_matrix_changed)
	
	_regenerate_edits()


func _regenerate_edits() -> void:
	columns = matrix.width
	for edit in edits:
		edit.queue_free()
	edits.resize(matrix.width * matrix.height)
	for i in matrix.width * matrix.height:
		edits[i] = MatrixLineEdit.new()
		edits[i].gui_input.connect(_on_child_edit_gui_input.bind(edits[i]))
		edits[i].changed.connect(func(new_value: float):
			matrix.set_block_signals(true)
			matrix.seti(i, new_value)
			matrix.set_block_signals(false)
			matrix_changed.emit()
		)
		add_child(edits[i])
	_update_edits()


func _update_edits() -> void:
	for i in edits.size():
		edits[i].text = str(matrix.geti(i))


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


func _on_matrix_changed() -> void:
	if matrix.get_width() != columns or matrix.get_height() != get_child_count() / columns:
		_regenerate_edits()
	else:
		_update_edits()
