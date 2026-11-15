extends SceneTree
const Host=preload("res://scripts/rebuild/final_playable.gd")
const Camera=preload("res://scripts/ui/field_camera.gd")
var checks:=0
var failures:Array[String]=[]
var out:=""
class CloseProbe extends Host:
	var completed_close_requests:=0
	func _close_window_after_save()->void:
		if busy:_window_close_deferred=true;return
		completed_close_requests+=1
func _initialize()->void:
	for arg:String in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	if out.is_empty() or not str(OS.get_cmdline_user_args()).contains("--final-save=user://qa/"):quit(1);return
	create_timer(65).timeout.connect(func():push_error("Integrity fixture timeout");quit(1))
	run.call_deferred()
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures.append(label);push_error(label)
func send(code:Key,pressed:bool)->void:
	var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=pressed
	root.push_input(event,true)
func write(path:String,text:String)->void:
	var file:=FileAccess.open(path,FileAccess.WRITE);file.store_string(text);file.close()
func run()->void:
	DirAccess.make_dir_recursive_absolute(out)
	root.unfocusable=true;root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1600,900);root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var game=Host.new();game.allow_display_changes=false;root.add_child(game);game.size=Vector2(1600,900)
	game.core.new_game();game.core.state.location="community_center";game._world("food_truck")
	await create_timer(.4).timeout
	for locale:String in ["zh","en"]:
		game.preferences.values.language=locale
		game.core.save_path="user://qa/integrity/"+locale+"/save.json"
		game._recorder();await create_timer(.2).timeout
		var recorder=game.modal
		check(recorder.empty_library.visible and not recorder.title_edit.editable,locale+" empty library has a non-editable empty state")
		recorder.record_button.grab_focus();send(KEY_D,true)
		check(game.walker._tool_movement_keys.has(KEY_D),locale+" forwards fresh movement")
		recorder._toggle_library();send(KEY_D,false)
		check(game.walker._tool_movement_keys.is_empty(),locale+" library transition clears held movement and key-up")
		recorder._toggle_library();await process_frame
		check(game.walker._manual_direction()==Vector2.ZERO,locale+" leaving library cannot resume stale movement")
		recorder.record_button.grab_focus();send(KEY_A,true);recorder._focus_lost()
		check(game.walker._tool_movement_keys.is_empty(),locale+" native focus loss clears explicit tool keys")
		send(KEY_A,false)
		recorder._toggle_library();recorder.title_edit.grab_focus();send(KEY_ESCAPE,true);send(KEY_ESCAPE,false)
		await create_timer(.2).timeout
		check(is_instance_valid(game.modal) and game.modal==recorder,locale+" Escape from naming keeps recorder open")
		if not is_instance_valid(game.modal) or game.modal!=recorder:
			game._recorder();recorder=game.modal
		check(not recorder.library.get_parent().visible,locale+" Escape closes nested library first")
		check(root.gui_get_focus_owner()==recorder.library_button,locale+" nested back restores library opener")
		# Metadata retry keeps the already saved WAV and its exact sidecar data.
		var clip:String=recorder.directory.path_join("Recording_integrity_"+locale+".wav")
		DirAccess.make_dir_recursive_absolute(recorder.directory)
		var audio:=AudioStreamWAV.new();audio.format=AudioStreamWAV.FORMAT_16_BITS;audio.mix_rate=8000;audio.data=PackedByteArray();var samples:=PackedByteArray();samples.resize(32000);audio.data=samples;audio.save_to_wav(clip)
		var clip_hash:=FileAccess.get_sha256(clip)
		var clip_data:={"version":2,"name":"","location":"Fountain","locations":["Fountain","Market"],"seconds":2.0,"captured_bus":"SolmereAmbience"}
		recorder._pending_metadata=clip_data.duplicate(true);recorder._pending_metadata_path=clip
		DirAccess.make_dir_recursive_absolute(clip+".json.tmp")
		check(not recorder._persist_pending(),locale+" recording details failure is retryable")
		check(recorder._metadata(clip).get("locations",[])==clip_data.locations,locale+" unsaved recording details remain available in memory")
		DirAccess.rename_absolute(ProjectSettings.globalize_path(clip+".json.tmp"),ProjectSettings.globalize_path(clip+".blocked"))
		check(recorder._persist_pending() and recorder._pending_metadata_path.is_empty(),locale+" details retry completes without a second audio capture")
		check(recorder.status.text==recorder.t("已保存","Saved"),locale+" successful details retry clears stale error status")
		check(FileAccess.get_sha256(clip)==clip_hash,locale+" details retry preserves exact WAV bytes")
		recorder.selected_path=clip;recorder._refresh_library();await process_frame;await process_frame
		check(recorder.title_edit.editable and not recorder.empty_library.visible,locale+" saved recording replaces empty state")
		check(recorder.clock_label.text=="00:02",locale+" idle clock shows selected recording duration")
		write(clip+".json.bak",JSON.stringify(clip_data));write(clip+".json","{damaged recording")
		recorder.title_edit.text="Recovered "+locale
		check(recorder._save_name(),locale+" recording name saves with recovered sidecar")
		check(recorder._metadata(clip).get("locations",[])==clip_data.locations and recorder._metadata(clip).get("name","")=="Recovered "+locale,locale+" rename keeps route and duration metadata")
		for pixels:Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440)]:
			root.size=pixels;recorder.open_library();await process_frame;await RenderingServer.frame_post_draw
			check(Rect2(Vector2.ZERO,Vector2(1600,900)).encloses(recorder.title_edit.get_global_rect()),locale+" library naming fits design canvas "+str(pixels.x))
			root.get_texture().get_image().save_png(out.path_join(locale+"_library_"+str(pixels.x)+".png"))
		check(recorder.get_node_or_null("RecorderDock")==null and recorder._page.has_node("RecorderDock") and recorder.library_button.text==recorder.t("收起列表","Hide list"),locale+" retains latest compact recorder dock and nested list state")
		recorder._toggle_library()
		recorder.request_close();await process_frame
		game._bag();game._bag_recordings();await create_timer(.2).timeout
		recorder=game.modal
		check(recorder.library.get_parent().visible and not game.walker.manual_enabled,locale+" bag entry uses paused library state")
		check(root.gui_get_focus_owner()==recorder.library,locale+" bag library entry focuses recordings")
		recorder.request_close();await process_frame
		check(is_instance_valid(game.modal) and game.modal.name=="MailBag",locale+" recorder close returns to bag")
		game._close()
	# A valid sidecar backup must restore the whole media record, not only text.
	var directory:=out.path_join("photos");DirAccess.make_dir_recursive_absolute(directory)
	var path:=directory.path_join("DearSomewhere_integrity.png")
	var pixels:=Image.create(80,60,false,Image.FORMAT_RGB8);pixels.fill(Color("789989"));pixels.save_png(path)
	var photo_hash:=FileAccess.get_sha256(path)
	var original:={"version":2,"caption":"Recovered note","favorite":true,"location":"Seaside","original":"originals/untouched.png","camera":{"recipe":"Berry","controls":{"exposure":.7}},"future_field":{"keep":true}}
	write(path+".json.bak",JSON.stringify(original));write(path+".json","{damaged")
	check(Camera.photo_metadata(path)==JSON.parse_string(JSON.stringify(original)),"photo metadata recovers full backup")
	check(Camera._write_caption(path,"Updated note"),"caption saves over damaged primary")
	var recovered:=Camera.photo_metadata(path)
	check(recovered.get("favorite",false) and recovered.get("location","")=="Seaside","caption recovery retains favorite and location")
	check(recovered.get("camera",{})==original.camera and recovered.get("future_field",{})==original.future_field,"caption recovery retains recipe and unknown fields")
	check(recovered.get("version",0)==2,"caption edit retains media schema version")
	check(JSON.parse_string(FileAccess.get_file_as_string(path+".json.bak")) is Dictionary,"last valid backup survives damaged-primary write")
	var preserved_damage:=false
	for filename:String in DirAccess.open(directory).get_files():
		if filename.contains(".corrupt-") and FileAccess.get_file_as_string(directory.path_join(filename))=="{damaged":preserved_damage=true
	check(preserved_damage,"damaged primary is retained with its original bytes")
	var camera=Camera.new();camera.save_directory=directory;camera.gallery_only=true;camera.initial_photo_path=path;root.add_child(camera);camera.size=Vector2(1600,900)
	await process_frame
	camera._toggle_favorite()
	check(not Camera.photo_metadata(path).get("favorite",true) and Camera.caption_for(path)=="Updated note","favorite update preserves current caption")
	check(Camera.caption_for(path+".json")=="","unrelated filenames are not treated as photo notes")
	# Put a directory where the temp file belongs: failed update must keep bytes.
	var before:=FileAccess.get_sha256(path+".json")
	DirAccess.make_dir_recursive_absolute(path+".json.tmp")
	camera._toggle_favorite()
	check(FileAccess.get_sha256(path+".json")==before,"blocked metadata write preserves current sidecar bytes")
	check(not camera._caption_notice.text.is_empty(),"blocked favorite update reports failure")
	DirAccess.rename_absolute(path+".json.tmp",path+".blocked")
	camera._toggle_favorite()
	check(Camera.photo_metadata(path).get("favorite",false) and camera._caption_notice.text.is_empty(),"favorite retry succeeds and clears stale failure message")
	check(FileAccess.get_sha256(path)==photo_hash,"all sidecar edits preserve original photo bytes")
	camera.queue_free();await process_frame
	game._street_road.field_sound.shutdown();game.sound.shutdown();game.queue_free();await process_frame;await create_timer(.25).timeout
	# Observe deferred quit dispatch without closing the test process itself.
	var probe:=CloseProbe.new();probe.allow_display_changes=false;root.add_child(probe);probe.size=Vector2(1600,900)
	probe._start();await create_timer(.1).timeout
	probe._close_window_after_save()
	check(probe._window_close_deferred,"close during new-journey loading is queued")
	while probe.busy:await process_frame
	await process_frame;await process_frame
	check(probe.completed_close_requests==1,"new-journey completion dispatches queued close exactly once")
	probe.sound.shutdown();probe.queue_free();await process_frame;await create_timer(.25).timeout
	FileAccess.open(out.path_join("receipt.json"),FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	print("EXPLORATION_STATE_INTEGRITY ",checks," / ",failures.size())
	quit(0 if failures.is_empty() else 1)
