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
	var catalog:Dictionary=lib.catalog()
	var covered:Dictionary={}
	for scene:Dictionary in catalog.playable_scenes:
		for line:Dictionary in scene.lines:covered[str(line.source_id)]=true
	for line:Dictionary in catalog.records:
		if line.actor!="courier":check(covered.has(str(line.id)),"named NPC line reachable: "+str(line.id))
	var game=load("res://scripts/rebuild/final_playable.gd").new();game.allow_display_changes=false;root.add_child(game);game.size=Vector2(1600,900);game.core.new_game();game.preferences.values.text_speed="instant"
	game.core.state.location="community_center";game._world();await create_timer(.5).timeout
	var before:=JSON.stringify(game.core.state)
	for actor:String in ["record_clerk","FoodTruckGuest","community","lookout","chef","grocer","Naonao","TarotGuest"]:
		var scenes:Array=lib.playable_scenes(actor)
		check(not scenes.is_empty(),"actor has scenes: "+actor)
		check(game._supplied_scene_menu(actor),"menu opens: "+actor)
		await create_timer(.4).timeout
		check(game.modal._showing_choices,"menu visible: "+actor)
		check(game.modal.has_node("Choice_"+str(scenes[0].id)),"first scene selectable: "+actor)
		if actor=="community":
			await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/scene-menu-cici.png")
			check(game.modal.has_node("ChoicePageNext"),"scene menu has next page")
			game.modal.get_node("ChoicePageNext").pressed.emit();await process_frame
			check(game.modal.has_node("Choice_"+str(scenes[4].id)),"second page exposes additional scene")
			game.modal.get_node("ChoicePagePrevious").pressed.emit();await process_frame
		game.modal._choose(str(scenes[0].id));await create_timer(.5).timeout
		var lines:Array=lib.paginate(scenes[0].lines)
		check(game.modal.get_meta("supplied_scene","")==str(scenes[0].id),"selected scene opened: "+actor)
		check(game.modal.get_node("SpokenLine").get_parsed_text()==lines[0].text,"first line visible: "+actor)
		check(game.modal.get_node("Speaker").text==lines[0].speaker,"speaker visible: "+actor)
		game.modal.set_text_rate(0);game.modal._advance();await create_timer(.25).timeout
		if lines.size()>1:check(game.modal.get_node("SpokenLine").get_parsed_text()==lines[1].text,"second line visible: "+actor)
		game._close();await create_timer(.1).timeout
	check(JSON.stringify(game.core.state)==before,"scene playback changes no campaign state")
	game.core.state.location="tarot_shop";game._world();await create_timer(.3).timeout
	check(game._street_road.world.has_node("Talk_Supplied_TarotGuest"),"tarot actor clickable")
	game.core.state.location="post_office";game._world();await create_timer(.3).timeout
	check(game._street_road.world.has_node("Talk_Supplied_Naonao"),"Naonao actor clickable")
	game.sound.shutdown();game.queue_free();await process_frame
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));quit(0 if failures.is_empty() else 1)
