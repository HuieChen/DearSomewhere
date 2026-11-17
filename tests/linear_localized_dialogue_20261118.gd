extends SceneTree
var out:=""
var checks:=0
var failures:Array[String]=[]
func _initialize():
	for arg:String in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	if out.is_empty() or not str(OS.get_cmdline_user_args()).contains("--final-save=user://qa/"):quit(1);return
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures.append(label);push_error(label)
func run():
	root.unfocusable=true;Engine.max_fps=60;root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1600,900);root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	DirAccess.make_dir_recursive_absolute(out)
	var lib=preload("res://scripts/rebuild/supplied_dialogue.gd")
	var game=load("res://scripts/rebuild/final_playable.gd").new();game.allow_display_changes=false;root.add_child(game);game.size=Vector2(1600,900);game.core.new_game();game.preferences.values.text_speed="instant"
	check(not game.has_method("_supplied_scene_menu"),"no selectable manuscript scene menu")
	for actor:String in ["record_clerk","FoodTruckGuest"]:
		for language:String in ["zh","en"]:
			game.core.state.location="tarot_shop" if actor=="record_clerk" else "community_center"
			game.preferences.values.language=language;game._world();await create_timer(.3).timeout
			var before:=JSON.stringify(game.core.state)
			var lines:Array=lib.ambient_lines(actor,language)
			check(not lines.is_empty(),"localized conversation present "+actor+language)
			check(game._supplied_conversation(actor),"conversation opens directly "+actor+language);await create_timer(.5).timeout
			var d=game.modal;d.set_text_rate(0)
			check(not d._showing_choices,"no dialogue selection "+actor+language)
			for i:int in lines.size():
				check(d.get_node("SpokenLine").get_parsed_text()==lines[i].text,"page matches "+actor+language+str(i))
				check(d.get_node("SpokenLine").get_content_height()<=d.get_node("SpokenLine").size.y,"page fits "+actor+language+str(i))
				if language=="en":
					var chinese_found:=false
					for character:String in str(lines[i].text):
						if character.unicode_at(0)>=0x4e00 and character.unicode_at(0)<=0x9fff:chinese_found=true
					check(not chinese_found,"English page has no Chinese fallback")
				if i==0:await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/"+actor+"-"+language+".png")
				d._advance();await create_timer(.25).timeout
			check(JSON.stringify(game.core.state)==before,"dialogue preserves campaign state")
	game.sound.shutdown();game.queue_free();await process_frame
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));quit(0 if failures.is_empty() else 1)
