extends Button
## Feedback follows the visible painted door; original room art stays untouched.
signal activated
const DESIGN:=Vector2(376,488)
var _outline:=PackedVector2Array([Vector2(3,3),Vector2(372,3),Vector2(372,457),Vector2(285,432),Vector2(210,410),Vector2(70,457),Vector2(3,486)])
var interaction_allowed:Callable
var handle_from:=Vector2(330,309)
var handle_to:=Vector2(330,422)
var warmth:=0.0
var pressure:=0.0
var _pending:=false
func _ready()->void:
	flat=true
	mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	for state:String in ["normal","hover","pressed","focus","disabled"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
	pressed.connect(_activate)
	visibility_changed.connect(func():warmth=0.0;pressure=0.0;queue_redraw())
func _has_point(point:Vector2)->bool:
	if size.x<=0.0 or size.y<=0.0:return false
	return Geometry2D.is_point_in_polygon(point/size*DESIGN,_outline)
func _process(delta:float)->void:
	var allowed:bool=not interaction_allowed.is_valid() or interaction_allowed.call()
	disabled=not allowed or _pending
	var target:=1.0 if visible and allowed and (is_hovered() or has_focus() or _pending) else 0.0
	var pressed_target:=1.0 if button_pressed or _pending else 0.0
	warmth=lerpf(warmth,target,1.0-exp(-12.0*delta))
	pressure=lerpf(pressure,pressed_target,1.0-exp(-20.0*delta))
	queue_redraw()
func _activate()->void:
	if _pending or (interaction_allowed.is_valid() and not interaction_allowed.call()):return
	_pending=true
	# Leave a perceptible handle response before the host changes scenes.
	await get_tree().create_timer(0.14).timeout
	if not is_inside_tree():return
	_pending=false
	if not interaction_allowed.is_valid() or interaction_allowed.call():activated.emit()
func _draw()->void:
	if warmth<0.001:return
	draw_set_transform(Vector2.ZERO,0.0,size/DESIGN)
	# Catch a little light inside the existing brass, without painting a second
	# handle or spilling circular glow onto the door and foreground parcel.
	var a:=handle_from.lerp(handle_to,0.09)
	var b:=handle_from.lerp(handle_to,0.90)
	var middle:=a.lerp(b,0.48)
	var glint:=PackedVector2Array([a+Vector2(-1,0),a+Vector2(1.2,4),middle+Vector2(1.6,0),b+Vector2(0,-2),b+Vector2(-1.4,-5),middle+Vector2(-2.4,0),a+Vector2(-2,5)])
	draw_colored_polygon(glint,Color(Color("ffe6a7"),(0.18+0.12*pressure)*warmth))
