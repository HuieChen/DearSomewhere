extends Button
## The whole painted doorway is an exit. No drawn handle or hover overlay.
signal activated
var interaction_allowed:Callable
func _ready()->void:
	flat=true
	action_mode=BaseButton.ACTION_MODE_BUTTON_PRESS
	mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	for state:String in ["normal","hover","pressed","hover_pressed","focus","disabled"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
	pressed.connect(_activate)
func _process(_delta:float)->void:
	disabled=interaction_allowed.is_valid() and not interaction_allowed.call()
func _activate()->void:
	if interaction_allowed.is_valid() and not interaction_allowed.call():return
	activated.emit()
