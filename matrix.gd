@tool
class_name Matrix


var data: Array[PackedFloat64Array]


func getxy(x: int, y: int) -> float:
	return data[y][x]


func geti(i: int) -> float:
	return getxy(i % get_width(), i / get_width())


func getv(v: Vector2i) -> float:
	return getxy(v.x, v.y)


func setxy(x: int, y: int, value: float) -> void:
	data[y][x] = value


func seti(i: int, value: float) -> void:
	setxy(i % get_width(), i / get_width(), value)


func setv(v: Vector2i, value: float) -> void:
	setxy(v.x, v.y, value)


func transposed() -> Matrix:
	var m := Matrix.from_size(get_height(), get_width())
	for y in get_height():
		for x in get_width():
			m.setxy(y, x, getxy(x, y))
	return m


func get_width() -> int:
	return data[0].size()


func get_height() -> int:
	return data.size()


func get_size() -> Vector2i:
	return Vector2i(get_width(), get_height())


func duplicated() -> Matrix:
	var m := Matrix.new()
	m.data = data.duplicate(true)
	return m


func _to_string() -> String:
	return "[%s,]" % ",\n".join(data)


func to_string_rich() -> String:
	var s := "[table=%s]" % (get_width() + 1)
	s += "".join(([""] + range(get_width())).map(func(e): return "[cell padding=1,0,1,0 border=#FFFFFF22]%s[/cell]" % e))
	var row_i := 0
	for row in data:
		s += "[cell padding=1,0,1,0 border=#FFFFFF22]%s[/cell]" % row_i
		for entry in row:
			s += "[cell padding=1,0,1,0 border=#FFFFFF88]%s[/cell]" % entry
		row_i += 1
	s += "[/table]"
	
	return s


func matmul(other: Matrix) -> Matrix:
	assert(get_width() == other.get_height(), "Matrix A must have the same width as matrix B's height")
	var m := Matrix.from_size(other.get_width(), get_height())
	
	for x in m.get_width():
		for y in m.get_height():
			var v := 0.0
			for i in other.get_height():
				v += getxy(i, y) * other.getxy(x, i)
			m.setxy(x, y, v)
	
	return m


func fmul(other: float) -> Matrix:
	var m := Matrix.from_sizev(get_size())
	m.set_all(func(x: int, y: int): return getxy(x, y) * other)
	return m


func set_all(fn: Callable) -> void:
	for y in get_height():
		for x in get_width():
			setxy(x, y, fn.call(x, y))


func get_row(row: int) -> PackedFloat64Array:
	return data[row]


func get_col(col: int) -> PackedFloat64Array:
	var a: PackedFloat64Array
	a.resize(get_height())
	for i in get_height():
		a[i] = data[i][col]
	return a


func value() -> float:
	assert(get_width() == 1)
	assert(get_height() == 1)
	return getxy(0, 0)


func resize(new_width: int, new_height: int) -> void:
	data.resize(new_height)
	for row in data:
		row.resize(new_width)
	


func resized(new_width: int, new_height: int) -> Matrix:
	var m := Matrix.new()
	m.resize(new_width, new_height)
	
	return m


func balance() -> void:
	var max_width := 0
	for row in data:
		max_width = maxi(row.size(), max_width)
	for row in data:
		row.resize(max_width)


func is_balanced() -> bool:
	for row in data:
		if row.size() != data[0].size():
			return false
	return true


func get_array() -> PackedFloat64Array:
	var arr: PackedFloat64Array
	arr.resize(get_width() * get_height())
	for i in arr.size():
		arr[i] = geti(i)
	return arr


func lerp_weights(to_matrix: Matrix, weight: float) -> Matrix:
	assert(get_size() == to_matrix.get_size())
	return Matrix.from_fn(
		get_width(),
		get_height(),
		func(x: int, y: int) -> float:
			return lerpf(getxy(x, y), to_matrix.getxy(x, y), weight)
	)


func lerp_weights_multi(to_matrix: Matrix, weight: Matrix) -> Matrix:
	assert(get_size() == to_matrix.get_size() and get_size() == weight.get_size())
	return Matrix.from_fn(
		get_width(),
		get_height(),
		func(x: int, y: int) -> float:
			return lerpf(getxy(x, y), to_matrix.getxy(x, y), weight.getxy(x, y))
	)


static func from_sizev(size: Vector2i) -> Matrix:
	return Matrix.from_size(size.x, size.y)


static func from_size(width: int, height: int) -> Matrix:
	var m := Matrix.new()
	m.resize(width, height)
	
	return m


static func from_data(data: Array[PackedFloat64Array]) -> Matrix:
	var m := Matrix.new()
	for row in data:
		assert(row.size() == data[0].size(), "All rows must be the same size")
	m.data = data
	return m


static func from_array(array: PackedFloat64Array, width: int) -> Matrix:
	# maybe not necessary since unfilled cells can remain 0.0
	assert(array.size() % width == 0, "Array size must be multiple of width")
	
	var m := Matrix.from_size(width, array.size() / width)
	for i in array.size():
		m.seti(i, array[i])
	return m


static func from_fn(width: int, height: int, fn: Callable) -> Matrix:
	var m := Matrix.from_size(width, height)
	m.set_all(fn)
	return m
