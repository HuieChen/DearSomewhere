extends SceneTree
## Routed tool input with isolated data; no native/listening acceptance.
var game:Control
var view:SubViewport
var out:=""
var checks:=0
var failures:Array[String]=[]
var moving_location:=""
func _initialize():
	if not str(OS.get_cmdline_user_args()).contains("--final-save=user://qa/"):quit(1);return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	create_timer(60).timeout.connect(func():push_error("Tool consistency timeout");quit(1))
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures.append(label);push_error(label)
func key(code:Key):
	for down in [true,false]:
		var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=down;view.push_input(event,true)
	await process_frame
func press(control:Control,down:bool):
	var event:=InputEventMouseButton.new();event.position=control.get_global_rect().get_center();event.global_position=event.position;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down
	view.push_input(event,true)
	await process_frame
func run():
	DirAccess.make_dir_recursive_absolute(out);root.unfocusable=true;Engine.max_fps=60
	view=SubViewport.new();view.size=Vector2i(1600,900);view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(view);view.notify_mouse_entered()
	game=load("res://scripts/rebuild/final_playable.gd").new();game.allow_display_changes=false;view.add_child(game);game.size=Vector2(1600,900);game.core.new_game();game._world("post_office")
	await create_timer(.5).timeout
	for locale in ["zh","en"]:
		game.preferences.set_value("language",locale);game._camera();await create_timer(.25).timeout
		var camera=game.modal
		var format:Button=camera._format_button
		await press(format,true);await create_timer(.1).timeout
		check(format.scale.x<.99,locale+" camera action has a gentle held press")
		await press(format,false);await create_timer(.18).timeout
		check(format.scale.is_equal_approx(Vector2.ONE) and camera.instant_format,locale+" release restores size and activates once")
		await press(format,true);await create_timer(.1).timeout
		format.disabled=true;await create_timer(.2).timeout
		check(format.scale.is_equal_approx(Vector2.ONE),locale+" disabled while held releases feedback")
		await press(format,false);format.disabled=false
		await press(format,true);await create_timer(.1).timeout
		format.get_window().focus_exited.emit();await process_frame
		check(format.scale.is_equal_approx(Vector2.ONE),locale+" focus loss clears the held press")
		await press(format,false);await create_timer(.15).timeout
		camera.lab.toggle.grab_focus();camera.lab._toggle_panel();await create_timer(.15).timeout
		await key(KEY_ESCAPE);await create_timer(.25).timeout
		check(is_instance_valid(game.modal) and game.modal==camera,locale+" Escape from film panel keeps camera open")
		if not is_instance_valid(camera):game._camera();camera=game.modal
		check(not camera.lab.panel.visible,locale+" Escape collapses film panel")
		check(view.gui_get_focus_owner()==camera.lab.toggle,locale+" film close returns keyboard focus to its opener")
		await key(KEY_ESCAPE);await create_timer(.3).timeout
		check(not is_instance_valid(game.modal),locale+" next Escape exits camera")
		game._recorder();await create_timer(.25).timeout
		var recorder=game.modal
		moving_location="邮局" if locale=="zh" else "Post office"
		recorder.location_provider=func():return moving_location
		await process_frame
		moving_location="集市" if locale=="zh" else "Market"
		await process_frame;await process_frame
		var matched:=false
		for node in recorder._page.get_children():
			if node is Label and node.position==Vector2(270,800) and node.text==moving_location:matched=true
		check(matched,locale+" recorder location follows movement without reopening")
		await press(recorder.library_button,true);await create_timer(.1).timeout
		check(recorder.library_button.scale.x<.99,locale+" recorder shares held press")
		await press(recorder.library_button,false);await create_timer(.2).timeout
		check(recorder.library.get_parent().visible,locale+" one release opens list")
		await key(KEY_ESCAPE);await create_timer(.2).timeout
		check(not recorder.library.get_parent().visible and view.gui_get_focus_owner()==recorder.library_button,locale+" recorder nested close restores opener focus")
		check(recorder.record_button.position==Vector2(1060,128),locale+" preserves latest author-directed record position")
		await RenderingServer.frame_post_draw;view.get_texture().get_image().save_png(out.path_join("recorder_"+locale+".png"))
		recorder.request_close();await create_timer(.3).timeout
	game._street_road.field_sound.shutdown();game.sound.shutdown();game.queue_free();await process_frame;await process_frame;view.queue_free();await process_frame
	FileAccess.open(out.path_join("receipt.json"),FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"method":"Production host; isolated save; routed key/pointer lifecycle and live labels; GPU; not native OS or listening"}))
	print("FIELD_TOOL_CONSISTENCY ",checks," / ",failures.size());quit(0 if failures.is_empty() else 1)
