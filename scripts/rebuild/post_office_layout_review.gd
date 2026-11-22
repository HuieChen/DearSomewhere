extends Control
## Authored postal rooms and standalone layout review; host owns campaign state.
signal room_changed(index: int)
signal close_requested
signal postcard_requested(card:Dictionary, origin:Rect2)

const DESIGN := Vector2(1920, 1080)
const SOURCE := preload("res://assets/authoring/post_office_20261120/post_office_base_no_clock.png")
const COUNTER_SOURCE := preload("res://assets/authoring/post_office_20261120/post_office_counter_foreground.png")
# The supplied replacement is layered so the authored counter foreground is a
# separate occlusion layer. Ambient characters stay in their authored story
# locations; this room remains a clean postal workspace.
const REGIONS := [Rect2(0, 0, 2560, 1440), Rect2(2560, 0, 2560, 1440)]
const DOOR_RECT := Rect2(78, 195, 444, 516)
var room_index := 0
var transitioning := false
var navigation_allowed: Callable
var canvas: Control
var image: TextureRect
var previous_image: TextureRect
var next_arrow: Button
var previous_arrow: Button
var close_button: Button
var _transition: Tween
var _textures: Array[Texture2D] = []
var _counter_textures: Array[Texture2D] = []
var counter_foreground: TextureRect
var postcard_rack:Control

class SceneArrow extends Button:
	var direction := 1
	var is_close := false
	var _motion: Tween
	var _idle_phase := 0.0
	var _hover_amount := 0.0:
		set(value): _hover_amount = value; queue_redraw()
	var _press_amount := 0.0:
		set(value): _press_amount = value; queue_redraw()
	func _ready() -> void:
		flat = true
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())
		mouse_entered.connect(_animate)
		mouse_exited.connect(_animate)
		focus_entered.connect(_animate)
		focus_exited.connect(_animate)
		button_down.connect(_animate)
		button_up.connect(_animate)

	func _animate() -> void:
		if _motion != null and _motion.is_valid(): _motion.kill()
		_motion = create_tween().set_parallel(true)
		_motion.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_motion.tween_property(self,"_hover_amount",1.0 if not disabled and (is_hovered() or has_focus()) else 0.0,0.20)
		_motion.tween_property(self,"_press_amount",1.0 if not disabled and button_pressed else 0.0,0.07)

	func _stroke(points: PackedVector2Array, color: Color, width: float) -> void:
		draw_polyline(points,color,width,true)
		# Rounded ink ends and joins, rather than a double-outline chevron.
		for point: Vector2 in points: draw_circle(point,width*0.5,color,true,-1,true)

	func _process(delta: float) -> void:
		if not is_visible_in_tree() or disabled or is_close: return
		_idle_phase = fposmod(_idle_phase + delta * TAU / 3.2, TAU)
		queue_redraw()

	func _brush_curve(start: Vector2, control_a: Vector2, control_b: Vector2, end: Vector2, ink: Color, width: float) -> void:
		# Smooth, slightly tapered painted strokes, evaluated at fixed positions.
		# No random jitter or moving contour noise at small display sizes.
		var previous := start
		for index in range(1,25):
			var t := float(index) / 24.0
			var point := start.bezier_interpolate(control_a,control_b,end,t)
			var weight := width * (0.78 + 0.22 * sin(PI * t))
			draw_line(previous,point,ink,weight,true)
			draw_circle(point,weight*0.5,ink,true,-1,true)
			previous = point
		draw_circle(start,width*0.39,ink,true,-1,true)

	func _draw() -> void:
		var drift := sin(_idle_phase) * 1.2 * (1.0-_hover_amount) if not is_close else 0.0
		var center := size * 0.5 + Vector2(float(direction)*(drift+3.5*_hover_amount),1.0*_press_amount)
		var drawn_scale := 1.0 + 0.025*_hover_amount - 0.06*_press_amount
		draw_set_transform(center,0.0,Vector2.ONE*drawn_scale)
		var ink := Color("f5e6c9").lerp(Color("fff5df"),_hover_amount)
		if disabled: ink.a = 0.55
		if is_close:
			_stroke(PackedVector2Array([Vector2(-9,-9),Vector2(9,9)]),ink,4.4)
			_stroke(PackedVector2Array([Vector2(9,-9),Vector2(-9,9)]),ink,4.4)
		else:
			var flip := Vector2(float(direction),1.0)
			_brush_curve(Vector2(-20,3)*flip,Vector2(-10,-1)*flip,Vector2(6,-2)*flip,Vector2(17,0)*flip,ink,4.6)
			_brush_curve(Vector2(4,-13)*flip,Vector2(7,-8)*flip,Vector2(12,-2)*flip,Vector2(17,0)*flip,ink,4.8)
			_brush_curve(Vector2(17,0)*flip,Vector2(13,3)*flip,Vector2(7,9)*flip,Vector2(2,12)*flip,ink,4.8)
		if has_focus() and not disabled:
			_stroke(PackedVector2Array([Vector2(-4,25),Vector2(4,25)]),ink,2.0)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for region: Rect2 in REGIONS:
		var texture := AtlasTexture.new()
		texture.atlas = SOURCE
		texture.region = region
		texture.filter_clip = true
		_textures.append(texture)
		var counter_texture := AtlasTexture.new()
		counter_texture.atlas = COUNTER_SOURCE
		counter_texture.region = region
		counter_texture.filter_clip = true
		_counter_textures.append(counter_texture)
	canvas = Control.new()
	canvas.name = "RoomCanvas"
	canvas.size = DESIGN
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	previous_image = _image_node("PreviousRoom")
	image = _image_node("AuthoredRoom")
	room_index = clampi(room_index, 0, 1)
	image.texture = _textures[room_index]
	counter_foreground = _image_node("CounterForeground")
	counter_foreground.texture = _counter_textures[room_index]
	counter_foreground.visible = room_index == 0
	postcard_rack=preload("res://scripts/rebuild/postal_postcard_rack.gd").new()
	postcard_rack.allowed=func():return room_index==0 and not transitioning and (not navigation_allowed.is_valid() or navigation_allowed.call())
	canvas.add_child(postcard_rack)
	postcard_rack.size=DESIGN
	postcard_rack.visible=room_index==0
	postcard_rack.card_requested.connect(func(card:Dictionary,origin:Rect2):postcard_requested.emit(card,origin))
	next_arrow = _arrow("ToWorkroom", Vector2(1810, 492), 1)
	previous_arrow = _arrow("ToCounter", Vector2(34, 492), -1)
	next_arrow.visible = room_index == 0
	previous_arrow.visible = room_index == 1
	next_arrow.pressed.connect(func(): show_room(1))
	previous_arrow.pressed.connect(func(): show_room(0))
	close_button = _arrow("CloseReview", Vector2(1844, 24), 1)
	close_button.size = Vector2(52,52)
	close_button.is_close = true
	close_button.pressed.connect(_request_close)
	resized.connect(_layout)
	_layout()
	# The standalone review scene owns its close path; component QA can observe it.
	if get_tree().current_scene == self:
		get_window().title = "Dear Somewhere · 邮局场景"
		close_requested.connect(func(): get_tree().quit())

func _image_node(node_name: String) -> TextureRect:
	var node := TextureRect.new()
	node.name = node_name
	node.size = DESIGN
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_SCALE
	node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(node)
	# Old book/page/notice masks target objects absent from this new painting.
	return node

func _arrow(node_name: String, at: Vector2, direction: int) -> SceneArrow:
	var node := SceneArrow.new()
	node.name = node_name
	node.position = at
	node.size = Vector2(76,96)
	node.direction = direction
	canvas.add_child(node)
	return node

func _layout() -> void:
	if not is_instance_valid(canvas): return
	var factor := minf(size.x / DESIGN.x, size.y / DESIGN.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN * factor) * 0.5

func show_room(index: int) -> void:
	if transitioning or index == room_index or index < 0 or index > 1: return
	if navigation_allowed.is_valid() and not navigation_allowed.call(): return
	transitioning = true
	postcard_rack.hide()
	next_arrow.disabled = true
	previous_arrow.disabled = true
	previous_image.texture = image.texture
	image.texture = _textures[index]
	if is_instance_valid(counter_foreground):
		counter_foreground.texture = _counter_textures[index]
		counter_foreground.visible = index == 0
	image.modulate.a = 0.0
	room_index = index
	_transition = create_tween()
	_transition.tween_property(image, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_transition.tween_callback(func():
		previous_image.texture = null
		transitioning = false
		next_arrow.disabled = false
		previous_arrow.disabled = false
		next_arrow.visible = room_index == 0
		previous_arrow.visible = room_index == 1
		postcard_rack.visible = room_index == 0
		room_changed.emit(room_index))

func _request_close() -> void:
	if _transition != null: _transition.kill()
	transitioning = false
	close_requested.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_request_close()

func _exit_tree() -> void:
	if _transition != null: _transition.kill()
