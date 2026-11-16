extends SceneTree
const Host=preload("res://scripts/rebuild/final_playable.gd")
var game:Control
var view:SubViewport
var out:="user://qa/postal-postcards/"
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
func settle(t:float=.35):await create_timer(t).timeout;await process_frame
func click_at(point:Vector2):
	var move:=InputEventMouseMotion.new();move.position=point;move.global_position=point;view.push_input(move,true)
	for down in [true,false]:
		var event:=InputEventMouseButton.new();event.position=point;event.global_position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;view.push_input(event,true)
	await process_frame
func key(code:Key):
	for down in [true,false]:
		var event:=InputEventKey.new();event.keycode=code;event.pressed=down;view.push_input(event,true)
	await process_frame
func capture(label:String):
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png(out+label+".png")
func run():
	DirAccess.make_dir_recursive_absolute(out);root.unfocusable=true;Engine.max_fps=60
	view=SubViewport.new();view.size=Vector2i(1600,900);view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(view);view.notify_mouse_entered()
	game=Host.new();game.allow_display_changes=false;view.add_child(game);game.size=Vector2(1600,900)
	game.core.new_game();game._post_office_room();await settle()
	var state:Dictionary=game.core.state.duplicate(true)
	var room=game.stage.get_node("PostOfficeInterior")
	var rack=room.postcard_rack
	check(rack.cards.size()==9,"nine visible source layers are selectable; fully obscured layers have no invisible hotspots")
	for index in range(rack.cards.size()):
		var card:Dictionary=rack.cards[index]
		var button=rack.get_node(str(card.id))
		var point:=Vector2(card.probe_source_point[0],card.probe_source_point[1])*.625
		check(button._has_point(button.get_global_transform().affine_inverse()*point),str(card.id)+" visible source pixels receive input")
		var excluded:=Vector2(-1,-1)
		for y in range(button.coverage.get_height()):
			for x in range(button.coverage.get_width()):
				if button.coverage.get_pixel(x,y).a<.01:excluded=Vector2(x+.5,y+.5)/Vector2(button.coverage.get_size())*button.size;break
			if excluded.x>=0:break
		check(excluded.x>=0 and not button._has_point(excluded),str(card.id)+" transparent or foreground-covered pixels reject input")
		await click_at(point);await settle()
		check(is_instance_valid(game.modal) and game.modal.name=="PostcardInspection" and game.modal.card.id==card.id,str(card.id)+" real pointer selects the matching individual layer")
		if not is_instance_valid(game.modal):continue
		check(rack.held_id==card.id and rack.patch.visible,str(card.id)+" original shelf slot is cleared while the complete card is held")
		check(game.modal.presented_rect.size.y>400 and game.modal.presented_rect.size.x>300,str(card.id)+" complete card is enlarged")
		if index in [0,5,8]:await capture(str(card.id)+"_open")
		room.show_room(1);await key(KEY_M)
		check(room.room_index==0 and game.modal.name=="PostcardInspection",str(card.id)+" scene arrows and map shortcut cannot interrupt inspection")
		match index%3:
			0:await click_at(game.modal.put_back.get_global_rect().get_center())
			1:await click_at(game.modal.close_button.get_global_rect().get_center())
			2:await key(KEY_ESCAPE);await key(KEY_ESCAPE)
		await settle()
		check(not is_instance_valid(game.modal) and rack.held_id.is_empty() and not rack.patch.visible,str(card.id)+" return completes once and restores the source slot")
		check(game.core.state==state,str(card.id)+" inspection grants no inventory, evidence or game time")
	# Forced teardown also restores the rack; next visit must not inherit a hole.
	var first:Dictionary=rack.cards[0]
	await click_at(Vector2(first.probe_source_point[0],first.probe_source_point[1])*.625)
	await settle(.05);game._close();await settle()
	check(rack.held_id.is_empty() and not rack.patch.visible,"forced modal close restores held layer")
	await click_at(Vector2(first.probe_source_point[0],first.probe_source_point[1])*.625)
	await settle();game.preferences.set_value("language","en")
	game._close();game._post_office_room();await settle()
	room=game.stage.get_node("PostOfficeInterior");rack=room.postcard_rack
	await click_at(Vector2(first.probe_source_point[0],first.probe_source_point[1])*.625);await settle()
	check(game.modal.put_back.text=="Put back","English return control is localized")
	await capture("english_open")
	await click_at(Vector2(550,800));await settle()
	check(not is_instance_valid(game.modal) and rack.held_id.is_empty(),"clicking outside the enlarged card returns it")
	await click_at(room.next_arrow.get_global_rect().get_center());await settle()
	check(room.room_index==1 and not rack.visible,"workroom has no rack ghost hotspots")
	await click_at(room.previous_arrow.get_global_rect().get_center());await settle()
	check(room.room_index==0 and rack.visible and rack.held_id.is_empty(),"return to counter restores all selectable cards")
	await capture("returned")
	game.sound.shutdown();await settle(.4);game.queue_free();await process_frame;view.queue_free();await process_frame
	FileAccess.open(out+"receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"method":"Real routed pointer/key events in production Host; each visible layer, occlusion, slot restoration and unchanged state."}))
	print("POSTAL_POSTCARDS ",checks," / ",failures.size());quit(0 if failures.is_empty() else 1)
