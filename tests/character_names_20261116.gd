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
	root.unfocusable=true;Engine.max_fps=60
	root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1600,900);root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	DirAccess.make_dir_recursive_absolute(out)
	var game:=preload("res://scripts/rebuild/final_playable.gd").new();game.allow_display_changes=false;root.add_child(game);game.size=Vector2(1600,900);game.core.new_game()
	var expected:={"Siri":"Siri","TarotGuest":"夏透明","record_clerk":"Xanni","bookseller":"Maya","Naonao":"闹闹","lookout":"Rae","chef":"咸鱼","FoodTruckGuest":"尘缘","grocer":"冥冥","community":"cici"}
	var seen:Array[String]=[]
	for location:String in ["post_office","community_center","residential","tarot_shop"]:
		game.core.state.location=location;game._world();await process_frame
		for label:Node in game._street_road.world.get_children():
			if not str(label.name).begins_with("Name_"):continue
			var id:=str(label.name).trim_prefix("Name_");seen.append(id)
			check(label.text==expected[id],"source actor name: "+id)
			game.walker.cancel();game.walker.foot=label.foot;game.walker.target=label.foot
			await create_timer(.25).timeout
			check(label.modulate.a>.9 and label.mouse_filter==Control.MOUSE_FILTER_IGNORE,"nearby name readable and click-through: "+id)
			game.walker.hide();await create_timer(.25).timeout
			check(label.modulate.a<.1,"close-up hides world name: "+id);game.walker.show()
	check(seen.size()==10,"all ten supplied characters wired")
	game.core.state.location="community_center";game._world("market");await create_timer(.5).timeout
	var siri:TextureRect=game._street_road.world.get_node("Siri")
	check(siri.texture.get_size()==Vector2(1386,2033),"Siri uses transparent bounds, no giant canvas")
	check(absf(siri.get_rect().end.y-850.0)<1.0,"Siri feet registered to street ground")
	check(absf(siri.get_rect().get_center().x-game.walker.foot.x)<600.0,"Siri visible at market arrival")
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/siri-market.png")
	game.core.state.location="post_office";game._world("bookstore");await create_timer(.3).timeout
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/maya-world.png")
	for language:String in ["zh","en"]:
		game.preferences.values.language=language;game._resident_conversation("bookseller",0);await create_timer(.6).timeout
		check(game.modal.get_node("Speaker").text=="Maya","Maya dialogue name in "+language)
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/maya-"+language+".png")
		game._resident_conversation("bookseller",1);await create_timer(.4).timeout
		check(game.modal.get_node("Speaker").text=="Anne","Anne reply name in "+language)
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/anne-"+language+".png")
		game._close();await create_timer(.2).timeout
		game._chef_conversation(0);await create_timer(.6).timeout
		check(game.modal.get_node("Speaker").text=="咸鱼","managed chef name in "+language)
		game._close();await create_timer(.2).timeout
	game.sound.shutdown();game.queue_free();await process_frame;await create_timer(.3).timeout
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));quit(0 if failures.is_empty() else 1)
