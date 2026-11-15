extends SceneTree
const UI=preload("res://scripts/ui/paper_ui.gd")
var failed:Array[String]=[]
var checks:=0
var callback_count:=0
class SoundProbe extends Node:
	var calls:Array[String]=[]
	func play(kind:String)->void:calls.append(kind)
class Surface extends Control:
	var sound:Node
func _initialize()->void:
	_run.call_deferred()
func _run()->void:
	root.unfocusable=true
	var window_connections:=root.focus_exited.get_connections().size()
	var host:=Surface.new();host.sound=SoundProbe.new();host.add_child(host.sound);root.add_child(host)
	var button:=UI.button(host,"Test",Rect2(0,0,180,50),func():callback_count+=1)
	var other:=Button.new();host.add_child(other)
	var feedback:=button.get_child(0)
	await create_timer(.15).timeout
	_check(not feedback.is_processing(),"idle feedback does not poll")
	button.button_down.emit()
	var press_motion:Tween=feedback.get("_motion")
	await press_motion.finished
	_check(button.scale.is_equal_approx(Vector2.ONE*.97),"press reaches authored scale")
	var old:Tween=feedback.get("_motion")
	for i in range(12):
		button.button_up.emit();button.button_down.emit()
	_check(not old.is_valid(),"rapid clicks cancel previous motion")
	button.button_up.emit()
	await create_timer(.15).timeout
	_check(button.scale.is_equal_approx(Vector2.ONE) and not feedback.is_processing(),"rapid release settles at rest")
	button.button_down.emit();button.disabled=true
	await process_frame
	await process_frame
	_check(button.scale==Vector2.ONE and not feedback.is_processing(),"disable while held releases immediately")
	button.disabled=false;button.button_down.emit();host.hide()
	_check(button.scale==Vector2.ONE and not feedback.is_processing(),"ancestor hide releases immediately")
	host.show();button.grab_focus();button.button_down.emit();other.grab_focus()
	_check(button.scale==Vector2.ONE and not feedback.is_processing(),"focus transfer releases immediately")
	button.button_down.emit();root.focus_exited.emit()
	_check(button.scale==Vector2.ONE and not feedback.is_processing(),"window blur releases immediately")
	button.mouse_entered.emit();button.pressed.emit()
	_check(callback_count==1 and host.sound.calls==["title_hover","paper"],"original callback and audio route preserved")
	button.button_down.emit();button.queue_free()
	await process_frame
	await process_frame
	_check(root.focus_exited.get_connections().size()==window_connections,"freed button auto-disconnects Window handler")
	root.focus_exited.emit()
	host.queue_free()
	await process_frame
	print("PAPER_BUTTON_FEEDBACK: %d checks / %d failures"%[checks,failed.size()])
	quit(0 if failed.is_empty() else 1)
func _check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failed.append(label);push_error(label)

