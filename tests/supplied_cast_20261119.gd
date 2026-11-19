extends SceneTree
const Cast=preload("res://scripts/rebuild/supplied_character_art.gd")
const Dialogue=preload("res://scripts/rebuild/scene_dialogue.gd")
const Host=preload("res://scripts/rebuild/final_playable.gd")
var checks:=0
var failures:Array[String]=[]
var out:="D:/Codex-build-cache/cast-20261119/art"
func _initialize()->void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	run.call_deferred()
func check(value:bool,label:String)->void:
	checks+=1
	if not value:failures.append(label)
func shot(name:String)->void:
	await process_frame
	if DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(name+".png"))
func run()->void:
	root.unfocusable=true;root.size=Vector2i(1600,900);root.content_scale_size=Vector2i(1600,900)
	DirAccess.make_dir_recursive_absolute(out)
	var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(Cast.MANIFEST))
	for key:String in manifest.assets:
		var entry:Dictionary=manifest.assets[key]
		check(FileAccess.get_sha256(entry.path)==entry.sha256,"unchanged source bytes "+key)
		var tex:=Cast.texture(key)
		check(tex!=null and tex.get_width()>100,"runtime texture "+key)
		check(tex.atlas.get_image().get_pixel(0,0).a<0.01,"transparent source "+key)
	check(Cast.texture("nanxing_smile").region==Cast.texture("nanxing_neutral").region and Cast.texture("nanxing_happy").region==Cast.texture("nanxing_smile").region,"expressions share exact anchor and scale")
	var back:=ColorRect.new();back.color=Color("e7dfc9");back.size=Vector2(1600,900);root.add_child(back)
	for speaker:String in ["Mossner","周晓六","宇星晴","BEETMAN","南星"]:
		var dialog:=Dialogue.new();dialog.size=Vector2(1600,900);dialog.authored_text_enabled=true;root.add_child(dialog)
		dialog.configure(speaker,"……",[],"courier_source.jpg","")
		await create_timer(.35).timeout
		check(dialog._right_portrait.texture==Cast.texture(Cast.portrait_key(speaker)),"real dialogue selects supplied portrait "+speaker)
		check(dialog._right_portrait.material==null,"original colors retained "+speaker)
		await shot(Cast.PORTRAITS[speaker])
		dialog.set_line("Anne","……");await create_timer(.2).timeout
		check(dialog._right_portrait.texture==Cast.texture(Cast.portrait_key(speaker)),"listener retained for player reply "+speaker)
		dialog.queue_free();await process_frame
	back.queue_free();await process_frame
	var host:=Host.new();host.size=Vector2(1600,900);root.add_child(host)
	host.core.save_path="user://qa/cast-20261119/legacy.json"
	host.campaign.journey.path="user://qa/cast-20261119/journey.json"
	host.campaign.journey.new_journey()
	for event:Dictionary in host.campaign.journey.catalog.events:
		for index:int in event.steps.size():
			var step:Dictionary=event.steps[index]
			if not str(step.get("speaker","")) in ["周晓六","宇星晴"]:continue
			for id:String in host.campaign.journey.state.events:host.campaign.journey.state.events[id].done=true
			host.campaign.journey.state.day=event.day;host.campaign.journey.state.selected=event.id
			host.campaign.journey.state.events[event.id]={"step":index,"done":false,"work":{},"choices":{}}
			host.core.state.location=step.place;host._world(step.place)
			check(is_instance_valid(host.campaign.supplied_actor),"story encounter shows chibi "+str(step.speaker))
			await shot("world_"+Cast.CHIBIS[step.speaker])
			break
	for pair:Array in [["mayor","nanxing_smile"],["returned_mayor","nanxing_neutral"],["dog_gift","nanxing_happy"]]:
		for id:String in host.campaign.journey.state.events:host.campaign.journey.state.events[id].done=true
		var event:Dictionary=host.campaign.journey.event(pair[0])
		host.campaign.journey.state.day=event.day;host.campaign.journey.state.selected=event.id
		host.campaign.journey.state.events[event.id]={"step":0,"done":false,"work":{},"choices":{}}
		host.core.state.location="community_center";host._world("community_center")
		check(host.campaign.supplied_actor.texture==Cast.texture(pair[1]),"Nanxing story expression "+pair[0])
		await shot("world_"+pair[1])
	host.core.state.location="food_truck";host._world("food_truck");await create_timer(.35).timeout
	check(is_instance_valid(host._street_road.world.find_child("BEETMAN",true,false)),"BEETMAN is at the canned-food stall")
	check(is_instance_valid(host._street_road.world.find_child("Siri",true,false)),"raccoon is at the canned-food stall")
	await shot("canned_food_stall_cast")
	host._post_office_room(0);await create_timer(.35).timeout
	check(is_instance_valid(host.stage.find_child("MossnerPostalActor",true,false)),"Mossner is inside the post office")
	await shot("post_office_mossner")
	host.queue_free();await process_frame
	var receipt:={"checks":checks,"failures":failures,"method":"exact source hashes, live dialogue renderer, isolated production campaign encounters"}
	FileAccess.open(out.path_join("receipt.json"),FileAccess.WRITE).store_string(JSON.stringify(receipt))
	print("SUPPLIED_CAST_20261119 ",JSON.stringify(receipt))
	quit(0 if failures.is_empty() else 1)
