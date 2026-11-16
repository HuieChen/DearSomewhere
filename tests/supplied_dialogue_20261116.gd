extends SceneTree
var out := ""
var checks := 0
var failures: Array[String] = []
func _initialize():
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	if out.is_empty() or not str(OS.get_cmdline_user_args()).contains("--final-save=user://qa/"):quit(1);return
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures.append(label);push_error(label)
func run():
	root.unfocusable=true;Engine.max_fps=60
	root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1600,900);root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	DirAccess.make_dir_recursive_absolute(out)
	var lib=preload("res://scripts/rebuild/supplied_dialogue.gd")
	var catalog:Dictionary=lib.catalog()
	check(catalog.chapters.size()==29,"29 chapters indexed")
	check(catalog.aliases["塔罗师"]=="夏透明" and catalog.aliases["餐车摊主"]=="咸鱼","user-confirmed aliases")
	check(catalog.aliases["巫巫"]=="cici" and lib.chapter_records("community",2).size()>0,"NPC design alias 巫巫 is cici")
	check(lib.chapter_records("TarotGuest",12).size()>0,"Tarot dialogue bound to 夏透明")
	check(lib.chapter_records("chef",9).size()>0,"food truck dialogue bound to 咸鱼")
	check(lib.chapter_records("bookseller",18).is_empty(),"missing Maya text not invented")
	check(lib.ambient_lines("lookout").is_empty(),"Rae delivery reaction not exposed in exploration")
	check(lib.ambient_lines("unknown").is_empty(),"unknown actor fails closed")
	for row:Dictionary in catalog.records:
		check(row.kind=="dialogue" and not str(row.actor).is_empty(),"runtime row is bound dialogue: "+str(row.id))
	var game=load("res://scripts/rebuild/final_playable.gd").new()
	game.allow_display_changes=false;root.add_child(game);game.size=Vector2(1600,900);game.core.new_game()
	game.preferences.values.text_speed="instant"
	for actor:String in ["record_clerk","FoodTruckGuest"]:
		game.core.state.location="tarot_shop" if actor=="record_clerk" else "community_center"
		game._world();await create_timer(.3).timeout
		var before:String=JSON.stringify(game.core.state)
		var lines:Array=lib.ambient_lines(actor)
		check(not lines.is_empty(),"ambient lines exist: "+actor)
		check(game._supplied_conversation(actor),"host opens: "+actor)
		await create_timer(.6).timeout
		var dialogue=game.modal
		dialogue.set_text_rate(0)
		for i:int in lines.size():
			check(dialogue.get_node("SpokenLine").get_parsed_text()==lines[i].text,"visible source text "+actor+str(i))
			check(dialogue.get_node("Speaker").text==lines[i].speaker,"source speaker "+actor+str(i))
			check(str(lines[i].text).length()<=105,"bounded text page")
			dialogue._advance();await create_timer(.25).timeout
		check(not is_instance_valid(game.modal),"normal completion closes: "+actor)
		check(JSON.stringify(game.core.state)==before,"chat does not fake delivery or change saves")
		game._supplied_conversation(actor);await create_timer(.4).timeout
		game.modal.get_node("CloseDialogue").pressed.emit();await create_timer(.3).timeout
		check(not is_instance_valid(game.modal),"cross closes: "+actor)
		game._supplied_conversation(actor);await create_timer(.4).timeout
		var escape:=InputEventKey.new();escape.keycode=KEY_ESCAPE;escape.pressed=true
		game.modal._input(escape);await create_timer(.3).timeout
		check(not is_instance_valid(game.modal),"Escape closes: "+actor)
	game.core.state.location="community_center";game._world();await create_timer(.3).timeout
	check(game._street_road.world.has_node("Talk_Supplied_Chenyuan"),"named ambient figure has actual interaction")
	for dims:Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size=dims
		for language:String in ["zh","en"]:
			game.preferences.values.language=language
			game._supplied_conversation("FoodTruckGuest");await create_timer(.5).timeout
			game.modal.set_text_rate(0)
			game.modal._advance();await create_timer(.3).timeout
			check(game.modal.get_node("SpokenLine").get_parsed_text()!="……","authored text not masked in "+language)
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out+"/dialogue-"+str(dims.x)+"-"+language+".png")
			game._close();await create_timer(.1).timeout
	game.sound.shutdown();game.queue_free();await process_frame;await create_timer(.3).timeout
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
