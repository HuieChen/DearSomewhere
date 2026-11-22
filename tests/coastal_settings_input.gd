extends SceneTree
## Current authored Settings surface smoke: real controls, water contacts,
## language rebuild and close/re-entry at three display sizes.
const Host=preload("res://scripts/rebuild/final_playable.gd")
const OUT="res://test-results/ui-reference-20261016/settings/"
var game:Control
var checks:=0
var failures:Array[String]=[]
var images:Array[String]=[]
func _initialize()->void:_run.call_deferred()
func _run()->void:
	root.unfocusable=true;root.gui_embed_subwindows=true
	for dims:Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440)]:
		root.size=dims;root.content_scale_size=Vector2i(1600,900);root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		game=Host.new();game.allow_display_changes=false;game.preferences_path="user://qa/coastal-settings/"+str(Time.get_ticks_usec())+".json"
		root.add_child(game);game.size=Vector2(1600,900);await process_frame;await process_frame
		await _open_settings()
		_check(game.modal.get_script().resource_path.ends_with("coastal_settings.gd"),"title opens current authored Settings surface")
		_check(game.modal.get_node("CloseSettings").text=="×","compact close affordance is visible")
		_check(game.modal.get_node("SettingsHeading").text in ["设置","Settings"],"settings heading is localized")
		for key:String in ["language","display_mode","resolution","text_speed","master","music","sfx","ambience","sensitivity"]:
			_check(game.modal.controls.has(key),"current settings control exists "+key)
		var font:Font=game.modal.get_node("SettingsHeading").get_theme_font("font")
		_check(font!=null and font.has_char("设".unicode_at(0)),"rounded UI font renders core Chinese glyph")
		await _shot("current_zh_"+str(dims.x))
		var field_before:Dictionary=game.modal.field.snapshot()
		await _button(Vector2(1380,340),true);await _button(Vector2(1380,340),false);await _step(3)
		var pulse:Dictionary=game.modal.field.snapshot()
		_check(int(pulse.taps)>int(field_before.taps),"water click produces a real contact pulse")
		var start:=Vector2(1180,260);var finish:=Vector2(1300,260)
		await _motion(start,Vector2.ZERO,Vector2.ZERO,false)
		await _motion(finish,finish-start,Vector2(1200,0),true);await _step(3)
		_check(int(game.modal.field.snapshot().strokes)>int(pulse.strokes),"held pointer produces a directional wake")
		await _option("language",1);await create_timer(0.18).timeout
		_check(game.preferences.values.language=="en" and game.modal.get_node("SettingsHeading").text=="Settings","language rebuild updates visible UI")
		await _option("text_speed",0)
		_check(game.preferences.text_rate()==20.0,"text speed selection updates the dialogue rate")
		await _option("display_mode",0)
		_check(game.preferences.values.display_mode=="windowed","display mode selection persists")
		await _click_named("CloseSettings");await create_timer(0.20).timeout
		_check(not is_instance_valid(game.modal),"close returns to the title")
		await _open_settings()
		_check(game.modal.controls.text_speed.text=="Slow","re-entry restores saved text speed")
		await _key(KEY_ESCAPE);await create_timer(0.20).timeout
		_check(not is_instance_valid(game.modal),"Esc closes Settings after re-entry")
		game.queue_free();await process_frame;await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var f:=FileAccess.open(OUT+"result.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"images":images,"scope":"Automated current Host Settings controls and water input at three resolutions; no native OS or novice acceptance claim."},"\t"));f.close()
	print("COASTAL SETTINGS: ",checks," checks / ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
func _open_settings()->void:
	await _click_named("OpenSettings")
	var deadline:=Time.get_ticks_msec()+1200
	while Time.get_ticks_msec()<deadline and (not is_instance_valid(game.modal) or not game.modal.has_node("SettingsWater")):
		await process_frame;await create_timer(0.02).timeout
	await _step(6)
	_check(is_instance_valid(game.modal) and game.modal.has_node("SettingsWater"),"settings surface finishes its authored entrance")
func _click_named(name:String)->void:
	var c:Control=game.find_child(name,true,false);_check(c!=null,"visible control "+name)
	if c==null:return
	var p:=c.get_global_rect().get_center();await _button(p,true);await _button(p,false)
func _option(key:String,index:int)->void:
	await _click_named("Setting_"+key);var dropdown:Node=game.modal.find_child("SettingsDropdown",true,false)
	_check(dropdown!=null,"dropdown opens "+key)
	if dropdown!=null:await _click_named("Option_"+key+"_"+str(index));await process_frame;await process_frame
func _button(point:Vector2,down:bool)->void:
	var e:=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.button_mask=MOUSE_BUTTON_MASK_LEFT if down else 0;e.pressed=down;root.push_input(e,true);await process_frame
func _motion(point:Vector2,relative:Vector2,velocity:Vector2,held:bool)->void:
	var e:=InputEventMouseMotion.new();e.position=point;e.global_position=point;e.relative=relative;e.velocity=velocity;e.button_mask=MOUSE_BUTTON_MASK_LEFT if held else 0;root.push_input(e,true);await process_frame
func _key(code:Key)->void:
	for down:bool in [true,false]:
		var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=down;root.push_input(e,true);await process_frame
func _step(frames:int)->void:
	for _i:int in frames:await physics_frame;await process_frame
func _shot(name:String)->void:
	await process_frame;RenderingServer.force_draw(false);DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT));var path:=OUT+name+".png";var image:=root.get_texture().get_image();_check(image.save_png(path)==OK,"render "+name);images.append(path)
func _check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures.append(label);push_error(label)
