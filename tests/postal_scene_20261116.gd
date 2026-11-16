extends SceneTree
const Host=preload("res://scripts/rebuild/final_playable.gd")
const Room=preload("res://scripts/rebuild/post_office_layout_review.gd")
var game:Control
var view:SubViewport
var out:="user://qa/postal-scene-20261116/"
var checks:=0
var failures:Array[String]=[]
func _initialize():
	if not str(OS.get_cmdline_user_args()).contains("--final-save=user://qa/"):quit(1);return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=").trim_suffix("/")+"/"
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures.append(label);push_error(label)
func settle():
	await create_timer(.3).timeout
	await process_frame
func click(control:Control):
	var point:=control.get_global_rect().get_center()
	for down in [true,false]:
		var event:=InputEventMouseButton.new();event.position=point;event.global_position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down
		view.push_input(event,true)
	await process_frame
func arrival()->bool:
	var until:=Time.get_ticks_msec()+20000
	while game.busy and Time.get_ticks_msec()<until:await process_frame
	await process_frame
	return not game.busy
func capture(label:String):
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png(out+label+".png")
func run():
	DirAccess.make_dir_recursive_absolute(out)
	root.unfocusable=true;Engine.max_fps=60
	view=SubViewport.new();view.size=Vector2i(1600,900);view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(view);view.notify_mouse_entered()
	game=Host.new();game.allow_display_changes=false;view.add_child(game);game.size=Vector2(1600,900)
	game.core.new_game()
	for locale in ["zh","en"]:
		game.preferences.set_value("language",locale);game._post_office_room();await settle()
		var room=game.stage.get_node("PostOfficeInterior")
		check(room.image.texture.atlas==Room.SOURCE,locale+" production room selects new PSD composite")
		check(not room.close_button.visible,locale+" standalone review close is hidden in production")
		check(not game.stage.get_node("CounterReferenceBook").visible,locale+" removed painted book has no ghost hotspot")
		var door=game.stage.get_node("PostOfficeExit")
		check(door.get_global_rect()==Rect2(Room.DOOR_RECT.position*5.0/6.0,Room.DOOR_RECT.size*5.0/6.0),locale+" painted door bounds follow new source")
		await capture("counter_"+locale)
		await click(room.next_arrow);await settle()
		check(game.post_office_room_index==1 and not door.visible,locale+" right passage switches room and hides outside exit")
		await capture("workroom_"+locale)
		await click(room.previous_arrow);await settle()
		check(game.post_office_room_index==0 and door.visible,locale+" left passage restores correct room and door")
		game._bag();await settle()
		room.show_room(1)
		check(game.post_office_room_index==0,locale+" modal blocks room navigation")
		game._close();await settle()
		var minute:int=game.core.state.minute
		await click(door)
		await create_timer(.17).timeout
		var completed:=await arrival()
		check(completed and game.view=="world" and game.core.state.location=="post_office",locale+" painted door reaches actual postal exterior")
		if completed and game.view=="world":
			await click(game._street_road.entry_hint)
			await create_timer(.2).timeout
			check(await arrival() and game.view=="post_office_room",locale+" exterior reentry restores new interior")
		check(game.core.state.minute==minute,locale+" room travel preserves game time")
	game.sound.shutdown();await create_timer(.4).timeout;game.queue_free();await process_frame;view.queue_free();await process_frame
	FileAccess.open(out+"receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"method":"Production Host with routed viewport input; isolated data; not a novice or listening review."}))
	print("POSTAL_SCENE ",checks," / ",failures.size());quit(0 if failures.is_empty() else 1)
