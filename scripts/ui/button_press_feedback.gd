extends Node
## One cancellable motion per button; interrupted input always releases the paper.
var _button:BaseButton
var _motion:Tween
var _rest_scale:=Vector2.ONE
var _pressing:=false

func _ready()->void:
	_button=get_parent() as BaseButton
	if _button==null:
		set_process(false)
		return
	_rest_scale=_button.scale
	_button.button_down.connect(_press)
	_button.button_up.connect(_release)
	_button.focus_exited.connect(_reset)
	_button.visibility_changed.connect(_visibility_changed)
	# A method on this child automatically disconnects when the button is freed.
	get_window().focus_exited.connect(_reset)
	set_process(false)

func _press()->void:
	if _button.disabled or not _button.is_visible_in_tree():return
	_pressing=true
	set_process(true)
	_animate(_rest_scale*.97,.08)

func _release()->void:
	if not _pressing:return
	_pressing=false
	set_process(false)
	_animate(_rest_scale,.12)

func _animate(target:Vector2,duration:float)->void:
	_cancel_motion()
	_motion=create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_motion.tween_property(_button,"scale",target,duration)

func _cancel_motion()->void:
	if _motion!=null and _motion.is_valid():_motion.kill()
	_motion=null

func _reset()->void:
	_cancel_motion()
	_pressing=false
	set_process(false)
	if is_instance_valid(_button):_button.scale=_rest_scale

func _visibility_changed()->void:
	if not _button.is_visible_in_tree():_reset()

func _process(_delta:float)->void:
	# BaseButton has no disabled_changed signal. Poll only while held down.
	if _button.disabled:_reset()

func _exit_tree()->void:
	_reset()
