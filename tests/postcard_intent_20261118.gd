extends SceneTree
var view:SubViewport
var card:Control
var checks:=0
var failures:Array[String]=[]
var closed_count:=0
var out:=""
func _initialize():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures.append(label);push_error(label)
func settle():await create_timer(.4).timeout
func mouse(point:Vector2,down:bool):
	var e:=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down
	view.push_input(e,true);await process_frame
func run():
	root.unfocusable=true;Engine.max_fps=60
	view=SubViewport.new();view.size=Vector2i(1600,900);view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(view);view.notify_mouse_entered()
	card=load("res://scripts/ui/postal_postcard_view.gd").new()
	card.card=JSON.parse_string(FileAccess.get_file_as_string("res://assets/authoring/post_office_20261116/postcards/cards.json")).cards[0]
	card.origin=Rect2(1400,300,70,100);card.closed.connect(func():closed_count+=1);view.add_child(card)
	await settle()
	var inside:Vector2=card.presented_rect.get_center()
	var outside:=Vector2(200,400)
	await mouse(inside,true);await mouse(outside,false);await settle()
	check(not card.leaving,"drag from card to backdrop does not dismiss")
	await mouse(outside,true);await mouse(inside,false);await settle()
	check(not card.leaving,"drag from backdrop onto card does not dismiss")
	await mouse(outside,false);await settle()
	check(not card.leaving,"orphan mouse release does not dismiss")
	await mouse(outside,true);card.notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT);await mouse(outside,false);await settle()
	check(not card.leaving,"focus loss cancels pending backdrop click")
	await mouse(inside,true);await mouse(inside,false);await settle()
	check(not card.leaving,"clicking the card keeps inspection open")
	await mouse(outside,true);await mouse(outside,false);await settle()
	check(card.leaving and closed_count==1,"deliberate backdrop click returns once")
	card.request_close();await settle();check(closed_count==1,"repeated return remains idempotent")
	if not out.is_empty():
		DirAccess.make_dir_recursive_absolute(out)
		FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}))
	card.queue_free();await process_frame;view.queue_free();await process_frame
	print("POSTCARD_INTENT ",checks," / ",failures.size());quit(0 if failures.is_empty() else 1)
