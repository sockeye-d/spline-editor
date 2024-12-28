class_name MatrixLineEdit extends LineEdit


signal changed(new_value)


func _init() -> void:
	text_submitted.connect(_on_text_submitted)


func _on_text_submitted(new_text: String) -> void:
	var exp := Expression.new()
	var err := exp.parse(new_text)
	var val = exp.execute()
	delete_text(0, text.length())
	insert_text_at_caret(str(val))
	changed.emit(val) 
	edit.call_deferred()
