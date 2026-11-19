extends Control
signal closed
signal cue(kind:String)
signal recording_saved(path:String)
const UI=preload("res://scripts/ui/paper_ui.gd")
const ToolUI=preload("res://scripts/ui/field_tool_ui.gd")
const Metadata=preload("res://scripts/ui/media_metadata.gd")
const FONT=preload("res://assets/fonts/DearRounded.tres")
const BUS:="SolmereAmbience"
const MAX_SECONDS:=120.0
const RECORD_TRIGGER:=Rect2(1060,128,88,88)
const RECORD_HINT:=Rect2(1059,227,90,26)
const MOVEMENT_KEYS:=[KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN,KEY_W,KEY_A,KEY_S,KEY_D]
var locale:="zh"
var location_caption:=""
var location_label:Label
var location_provider:Callable
var visited_locations:Array[String]=[]
var mode_label:Label
var _wave_history:Array[float]=[]
var _wave_clock:=0.0
var _meter_peak:=Vector2.ZERO
var directory:="user://recordings"
var road:Control
var sound:Node
var recording:=false
var elapsed:=0.0
var last_path:=""
var selected_path:=""
var paths:Array[String]=[]
var effect:AudioEffectRecord
var meter:AudioEffectCapture
var playback:AudioStreamPlayer
var pending_audio:AudioStreamWAV
var _pending_metadata:Dictionary={}
var _pending_metadata_path:=""
var _selected_seconds:=0.0
var record_button:Button
var play_button:Button
var clock_label:Label
var status:Label
var library:ItemList
var title_edit:LineEdit
var empty_library:Label
var visual_hint:CheckButton
var levels:=Vector2.ZERO
var aim_point:=Vector2(800,420)
var _closing:=false
var _page:Control
var _ink:Control
var library_button:Button
var _replay_preparing:=false
var _replay_job:Node
var _replay_key:=""
var _replay_cache:Dictionary={}
func t(zh:String,en:String)->String:return en if locale=="en" else zh
func _ready()->void:
	name="FieldRecorder";mouse_filter=Control.MOUSE_FILTER_STOP
	# The recorder is a field tool, not a modal pause screen. Keep the courier
	# input route alive while its library is closed; the library itself pauses it.
	if is_instance_valid(road) and is_instance_valid(road.courier):road.courier.manual_enabled=true
	_page=Control.new();UI.place(_page,self,Rect2(0,0,1600,900));_page.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var surface:=Control.new();surface.name="RecordingWalkSurface";UI.place(surface,_page,Rect2(0,0,1600,900));surface.mouse_default_cursor_shape=Control.CURSOR_CROSS;surface.gui_input.connect(_aim_input)
	# Match the camera's small actions and edge anchors; leave the panorama clear.
	var instrument:=Control.new();instrument.name="RecorderDock";UI.place(instrument,_page,ToolUI.STATUS);instrument.mouse_filter=Control.MOUSE_FILTER_STOP
	instrument.draw.connect(func():
		var paper:=StyleBoxFlat.new();paper.bg_color=UI.ACTION_PAPER;paper.set_corner_radius_all(14)
		instrument.draw_style_box(paper,Rect2(Vector2.ZERO,instrument.size)))
	var style:=StyleBoxFlat.new();style.bg_color=UI.ACTION_PAPER;style.set_corner_radius_all(18)
	ToolUI.label(_page,t("录音机","Recorder"),ToolUI.TITLE,30).name="RecorderHeading"
	location_label=ToolUI.label(_page,location_caption,ToolUI.LOCATION,22)
	location_label.name="RecordingLocation"
	clock_label=label("00:00",Rect2(770,69,72,30),20)
	mode_label=label(t("监听","MONITOR"),Rect2(665,69,99,30),18)
	status=ToolUI.label(_page,"",Rect2(1030,794,450,38),18);status.clip_text=true;status.tooltip_text=""
	record_button=button("",RECORD_TRIGGER,toggle_recording);record_button.name="RecordToggle";record_button.tooltip_text=t("R · 开始 / 停止录音","R · Start / stop recording");record_button.accessibility_name=t("录音 / 停止","Record / stop")
	for state:String in ["normal","hover","pressed","hover_pressed","disabled"]:
		var circle:=StyleBoxFlat.new();circle.bg_color=Color("b86050") if state=="normal" else (Color("a34c40") if state in ["pressed","hover_pressed"] else Color("c77260"));circle.set_corner_radius_all(44)
		record_button.add_theme_stylebox_override(state,circle)
	var record_focus:=StyleBoxFlat.new();record_focus.bg_color=Color.TRANSPARENT;record_focus.set_corner_radius_all(46);record_focus.set_border_width_all(2);record_focus.border_color=UI.ACTION_INK;record_focus.expand_margin_left=4;record_focus.expand_margin_top=4;record_focus.expand_margin_right=4;record_focus.expand_margin_bottom=4;record_button.add_theme_stylebox_override("focus",record_focus)
	record_button.draw.connect(func():
		if recording:
			var stop:=StyleBoxFlat.new();stop.bg_color=UI.ACTION_PAPER;stop.set_corner_radius_all(4);record_button.draw_style_box(stop,Rect2(31,31,26,26))
		else:record_button.draw_circle(Vector2(44,44),16,UI.ACTION_PAPER))
	ToolUI.label(_page,"R",RECORD_HINT,18,HORIZONTAL_ALIGNMENT_CENTER)
	play_button=button(t("P  回听","P  Play"),ToolUI.FIRST_ACTION,toggle_playback);play_button.name="PlaybackToggle"
	library_button=button(t("录音列表","Recordings"),ToolUI.SECOND_ACTION,_toggle_library);library_button.name="RecordingLibrary"
	var close:=button("×",ToolUI.CLOSE,request_close);close.name="CloseRecorder";close.add_theme_font_size_override("font_size",30);close.tooltip_text=t("关闭录音机","Close recorder")
	visual_hint=CheckButton.new();visual_hint.text=t("方向提示 · H","Direction hints · H");visual_hint.add_theme_font_override("font",FONT);visual_hint.add_theme_font_size_override("font_size",18);visual_hint.add_theme_color_override("font_color",UI.ACTION_INK)
	visual_hint.toggled.connect(func(_enabled:bool):cue.emit("paper"))
	visual_hint.visible=is_instance_valid(road)
	var list_panel:=Panel.new();list_panel.add_theme_stylebox_override("panel",style);UI.place(list_panel,_page,Rect2(64,188,510,550));list_panel.hide()
	UI.place(visual_hint,list_panel,Rect2(18,510,474,32))
	library=ItemList.new();library.add_theme_font_override("font",FONT);library.add_theme_font_size_override("font_size",21);UI.place(library,list_panel,Rect2(18,22,474,415));library.item_selected.connect(_select)
	library.focus_entered.connect(_release_movement)
	empty_library=UI.label(list_panel,t("还没有录音","No recordings yet"),Rect2(36,170,438,60),22,Color("776f61"));empty_library.name="EmptyRecordingLibrary";empty_library.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;empty_library.mouse_filter=Control.MOUSE_FILTER_IGNORE
	title_edit=LineEdit.new();title_edit.placeholder_text=t("名称","Name");title_edit.max_length=60;title_edit.add_theme_font_override("font",FONT);title_edit.add_theme_font_size_override("font_size",21);UI.place(title_edit,list_panel,Rect2(18,458,474,48));title_edit.text_submitted.connect(func(_v:String):_save_name());title_edit.focus_exited.connect(_save_name)
	title_edit.focus_entered.connect(_release_movement)
	var list_style:=StyleBoxFlat.new();list_style.bg_color=Color("eee2cc");list_style.set_corner_radius_all(8)
	library.add_theme_stylebox_override("panel",list_style);library.add_theme_color_override("font_color",UI.ACTION_INK);library.add_theme_color_override("font_selected_color",UI.ACTION_INK)
	var selected_style:=StyleBoxFlat.new();selected_style.bg_color=UI.ACTION_PRESSED;selected_style.set_corner_radius_all(5)
	library.add_theme_stylebox_override("selected",selected_style);library.add_theme_stylebox_override("selected_focus",selected_style)
	title_edit.add_theme_stylebox_override("normal",list_style);title_edit.add_theme_color_override("font_color",UI.ACTION_INK);title_edit.add_theme_color_override("font_placeholder_color",Color("776f61"))
	_ink=Control.new();UI.place(_ink,self,Rect2(0,0,1600,900));_ink.mouse_filter=Control.MOUSE_FILTER_IGNORE;_ink.draw.connect(_draw_feedback)
	playback=AudioStreamPlayer.new();playback.bus="SolmereFoley";add_child(playback);playback.finished.connect(_playback_finished)
	effect=AudioEffectRecord.new();effect.format=AudioStreamWAV.FORMAT_16_BITS
	meter=AudioEffectCapture.new();meter.buffer_length=.5
	var bus:=AudioServer.get_bus_index(BUS)
	if bus<0:record_button.disabled=true;status.text=t("声音暂不可用","Audio unavailable")
	else:AudioServer.add_bus_effect(bus,effect);AudioServer.add_bus_effect(bus,meter)
	sound.recorder_focus=true
	if is_instance_valid(road):road.field_sound.set_focus(true,_world_aim())
	_refresh_library();get_window().focus_exited.connect(_focus_lost)
	record_button.grab_focus()
func label(text:String,rect:Rect2,px:int)->Label:
	var value:=UI.label(_page,text,rect,px,UI.ACTION_INK);value.autowrap_mode=TextServer.AUTOWRAP_OFF;value.clip_text=true;value.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;value.size=rect.size;value.mouse_filter=Control.MOUSE_FILTER_IGNORE;return value
func button(text:String,rect:Rect2,callback:Callable)->Button:
	var value:=ToolUI.button(_page,text,rect);value.pressed.connect(callback)
	return value
func allows_world_walk()->bool:
	return not _closing and is_instance_valid(road) and not library.get_parent().visible
func _world_aim()->Vector2:return road.world.get_global_transform().affine_inverse()*get_global_transform()*aim_point if is_instance_valid(road) else aim_point
func _aim_input(event:InputEvent)->void:
	if event is InputEventMouseMotion:
		aim_point=(get_global_transform().affine_inverse()*get_global_mouse_position()).clamp(Vector2(20,20),Vector2(1580,800))
	elif event is InputEventMouseButton and allows_world_walk():
		var ground:InputEventMouseButton=event.duplicate()
		# GUI events are local to the recorder; the panorama has already scrolled.
		# Convert into world-local space or a right-hand click can walk left.
		ground.position=road.world.get_global_transform().affine_inverse()*get_global_transform()*event.position
		road.world.get_node("WalkTarget")._ground_input(ground)
func _input(event:InputEvent)->void:
	if not event is InputEventKey:return
	var key:int=event.physical_keycode if event.physical_keycode else event.keycode
	# Key-up belongs to the tool even after focus has moved into an editor or
	# list. Otherwise its explicit movement cache outlives the physical key.
	if key in MOVEMENT_KEYS and not event.pressed and is_instance_valid(road) and is_instance_valid(road.courier):road.courier.set_tool_movement(key,false)
	if key==KEY_ESCAPE and event.pressed and not event.echo and library.get_parent().visible:
		_set_library_visible(false);get_viewport().set_input_as_handled();return
	var focus:=get_viewport().gui_get_focus_owner()
	if focus==title_edit or focus==library or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:return
	if key in MOVEMENT_KEYS and is_instance_valid(road) and allows_world_walk() and is_instance_valid(road.courier):
		road.courier.set_tool_movement(key,event.pressed)
	# The walker reads these physical keys. Prevent buttons from also navigating.
	if key in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN,KEY_W,KEY_A,KEY_S,KEY_D,KEY_E]:get_viewport().set_input_as_handled()
func _unhandled_key_input(event:InputEvent)->void:
	if not event is InputEventKey or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:return
	var key:int=event.physical_keycode if event.physical_keycode else event.keycode
	if get_viewport().gui_get_focus_owner()==title_edit and key!=KEY_ESCAPE:return
	if event.pressed and not event.echo:
		if key==KEY_ESCAPE:
			if library.get_parent().visible:_toggle_library()
			else:request_close()
			get_viewport().set_input_as_handled()
		elif key==KEY_R:toggle_recording();get_viewport().set_input_as_handled()
		elif key==KEY_P:toggle_playback();get_viewport().set_input_as_handled()
		elif key==KEY_H:visual_hint.button_pressed=not visual_hint.button_pressed;get_viewport().set_input_as_handled()
func _process(delta:float)->void:
	if _closing:return
	if location_provider.is_valid():location_caption=location_provider.call()
	if is_instance_valid(location_label) and location_label.text!=location_caption:location_label.text=location_caption
	if recording and location_caption not in visited_locations:visited_locations.append(location_caption)
	if is_instance_valid(road):road.field_sound.set_focus(true,_world_aim())
	var peak:=Vector2.ZERO
	if meter!=null:
		var available:=meter.get_frames_available()
		if available>0:
			for frame:Vector2 in meter.get_buffer(available):peak=Vector2(maxf(peak.x,absf(frame.x)),maxf(peak.y,absf(frame.y)))
	levels=Vector2(maxf(peak.x,levels.x*exp(-delta*4.0)),maxf(peak.y,levels.y*exp(-delta*4.0)))
	_meter_peak=Vector2(maxf(levels.x,_meter_peak.x*exp(-delta*.6)),maxf(levels.y,_meter_peak.y*exp(-delta*.6)))
	_wave_clock+=delta
	if _wave_clock>=.05:
		_wave_clock=0.0;_wave_history.append(clampf((linear_to_db(maxf(peak.length(),.00001))+60.0)/60.0,0.0,1.0))
		if _wave_history.size()>55:_wave_history.pop_front()
	mode_label.text=t("录制","REC") if recording else (t("回听","PLAY") if playback.playing else t("监听","MONITOR"))
	if recording:
		elapsed+=delta
		if elapsed>=MAX_SECONDS:stop_recording()
	var seconds:=elapsed if recording else (playback.get_playback_position() if playback.playing else _selected_seconds)
	clock_label.text="%02d:%02d"%[int(seconds)/60,int(seconds)%60]
	library_button.disabled=recording
	play_button.disabled=recording or (selected_path.is_empty() and last_path.is_empty())
	status.tooltip_text=status.text
	_ink.queue_redraw()
func _draw_feedback()->void:
	_ink.draw_circle(Vector2(653,84),3,Color("b25949") if recording else Color("91a78c"))
	for channel in 2:
		var normalized:=clampf((linear_to_db(maxf(levels[channel],.00001))+60.0)/60.0,0.0,1.0)
		for i in 22:
			var color:=Color("739781") if float(i)/22.0<normalized else Color("d8d8c5")
			_ink.draw_rect(Rect2(850+i*4,76+channel*11,2,5),color)

	if visual_hint.button_pressed:
		_ink.draw_arc(aim_point,16,0,TAU,24,Color("fff3d5"),2,true)
		if is_instance_valid(road):
			var source:Dictionary=road.field_sound.strongest()
			if not source.is_empty():
				var screen:Vector2=get_global_transform().affine_inverse()*road.world.get_global_transform()*source.at
				var delta:Vector2=(screen-aim_point).normalized()
				_ink.draw_line(aim_point+delta*22,aim_point+delta*42,Color("fff3d5"),2,true)
func _toggle_library()->void:
	_set_library_visible(not library.get_parent().visible)
func open_library()->bool:
	return _set_library_visible(true)
func _release_movement()->void:
	if not is_instance_valid(road) or not is_instance_valid(road.courier):return
	for key:Key in MOVEMENT_KEYS:road.courier.set_tool_movement(key,false)
	road.courier.cancel()
func _set_library_visible(visible:bool)->bool:
	if _closing or recording or (not visible and not _save_name()):return false
	if library.get_parent().visible==visible:
		if visible:library.grab_focus()
		return true
	_release_movement()
	library.get_parent().visible=visible
	library_button.text=t("收起列表","Hide list") if visible else t("录音列表","Recordings")
	if is_instance_valid(road) and is_instance_valid(road.courier):
		road.courier.manual_enabled=not visible
	if visible:library.grab_focus()
	else:library_button.grab_focus()
	return true
func toggle_recording()->void:
	if recording:stop_recording();return
	if effect==null or AudioServer.get_bus_index(BUS)<0:return
	if pending_audio!=null and not _persist_pending():return
	if not _persist_metadata():return
	if not _save_name():return
	if not _set_library_visible(false):return
	stop_playback();library.mouse_filter=Control.MOUSE_FILTER_IGNORE;library.focus_mode=Control.FOCUS_NONE;title_edit.editable=false;record_button.grab_focus();effect.set_recording_active(true);elapsed=0;visited_locations=[location_caption];recording=true;status.text="";record_button.queue_redraw();cue.emit("recorder_start")
func stop_recording()->bool:
	if not recording:return _persist_pending()
	effect.set_recording_active(false);recording=false;library.mouse_filter=Control.MOUSE_FILTER_STOP;library.focus_mode=Control.FOCUS_ALL;title_edit.editable=not paths.is_empty();record_button.queue_redraw()
	pending_audio=effect.get_recording()
	if pending_audio==null or pending_audio.data.is_empty():pending_audio=null;status.text=t("录音太短","Recording too short");return true
	var saved:=_persist_pending();cue.emit("recorder_stop");return saved
func _persist_pending()->bool:
	if pending_audio==null:return _persist_metadata()
	if DirAccess.make_dir_recursive_absolute(directory)!=OK:status.text=t("未保存，请重试","Not saved. Retry.");return false
	var stamp:=Time.get_datetime_string_from_system().replace(":","").replace("-","")
	var path:=directory.path_join("Recording_"+stamp+"_"+str(Time.get_ticks_usec())+".wav")
	var temp:=path+".pending.wav"
	if pending_audio.save_to_wav(temp)!=OK or DirAccess.rename_absolute(ProjectSettings.globalize_path(temp),ProjectSettings.globalize_path(path))!=OK:
		status.text=t("未保存，请重试","Not saved. Retry.");return false
	var data:={"version":2,"name":"","location":location_caption,"locations":visited_locations.duplicate(),"seconds":pending_audio.get_length(),"captured_bus":BUS}
	_pending_metadata=data;_pending_metadata_path=path
	var metadata_saved:=_persist_metadata()
	last_path=path;selected_path=path;pending_audio=null;_refresh_library();recording_saved.emit(path)
	if metadata_saved:status.text=t("已保存","Saved")
	return metadata_saved
func _persist_metadata()->bool:
	if _pending_metadata_path.is_empty():return true
	if not Metadata.write(_pending_metadata_path+".json",_pending_metadata):status.text=t("录音已保存；信息待重试","Audio saved; retry details");return false
	_pending_metadata.clear();_pending_metadata_path="";status.text=t("已保存","Saved");return true
func _refresh_library()->void:
	paths.clear();library.clear()
	var dir:=DirAccess.open(directory)
	if dir!=null:
		for file:String in dir.get_files():
			if file.begins_with("Recording_") and file.ends_with(".wav") and not file.ends_with(".pending.wav"):paths.append(directory.path_join(file))
	paths.sort();paths.reverse()
	for i in paths.size():
		var data:=_metadata(paths[i]);var name:String=data.get("name","")
		if name.is_empty():name=t("录音 ","Recording ")+str(paths.size()-i)
		library.add_item(name+" · "+str(data.get("location",""))+" · %ds"%maxi(1,ceili(float(data.get("seconds",0)))))
	if not paths.is_empty():
		if selected_path not in paths:selected_path=paths[0]
		library.select(paths.find(selected_path));title_edit.text=str(_metadata(selected_path).get("name",""))
		_selected_seconds=float(_metadata(selected_path).get("seconds",0.0))
	else:
		selected_path="";last_path="";title_edit.text="";_selected_seconds=0.0
	empty_library.visible=paths.is_empty()
	title_edit.editable=not recording and not paths.is_empty()
func _select(index:int)->void:
	if recording or not _save_name():
		if selected_path in paths:library.select(paths.find(selected_path))
		return
	if index<0 or index>=paths.size():return
	stop_playback();selected_path=paths[index];title_edit.text=str(_metadata(selected_path).get("name",""));_selected_seconds=float(_metadata(selected_path).get("seconds",0.0))
func toggle_playback()->void:
	if recording or _closing:return
	if playback.playing or _replay_preparing:stop_playback();return
	var path:=selected_path if not selected_path.is_empty() else last_path
	if path.is_empty():return
	var file:=FileAccess.open(path,FileAccess.READ)
	if file==null:status.text=t("无法打开录音","Recording unavailable");return
	_replay_key="%s:%s:%s"%[path,FileAccess.get_modified_time(path),file.get_length()];file.close()
	if _replay_cache.get("key","")==_replay_key:
		playback.stream=_replay_cache.stream;_begin_replay(float(_replay_cache.gain));return
	_replay_preparing=true
	status.text=t("正在准备回听…","Preparing playback…");play_button.text=t("P  取消","P  Cancel")
	_replay_job=preload("res://scripts/ui/replay_preparation.gd").new()
	get_tree().root.add_child(_replay_job)
	_replay_job.completed.connect(_replay_prepared.bind(_replay_job,_replay_key))
	if _replay_job.start(path)!=OK:
		stop_playback();status.text=t("无法准备回听，请重试","Unable to prepare playback; retry")
func _replay_prepared(result:Dictionary,job:Node,key:String)->void:
	if not _replay_preparing or job!=_replay_job or _closing:return
	_replay_job=null;_replay_preparing=false
	if result.is_empty():
		_playback_finished();status.text=t("无法打开录音","Recording unavailable");return
	# Keep only the last decoded clip, rather than accumulating long recordings.
	_replay_cache={"key":key,"stream":result.stream,"gain":result.gain}
	playback.stream=result.stream;_begin_replay(float(result.gain))
func _begin_replay(gain:float)->void:
	_replay_preparing=false;status.text=""
	# Playback bypasses the recorded environment bus: never records itself.
	sound.recorder_playback=true;playback.volume_db=gain;playback.play();play_button.text=t("P  停止","P  Stop")
func stop_playback()->void:
	if _replay_preparing:status.text=""
	_replay_preparing=false
	if is_instance_valid(_replay_job):_replay_job.cancel()
	_replay_job=null
	if playback!=null:playback.stop()
	_playback_finished()
func _playback_finished()->void:
	if is_instance_valid(sound):sound.recorder_playback=false
	if is_instance_valid(play_button):play_button.text=t("P  回听","P  Play")
func _metadata(path:String)->Dictionary:
	if path==_pending_metadata_path:return _pending_metadata.duplicate(true)
	return Metadata.read(path+".json")
func _write_metadata(path:String,data:Dictionary)->bool:
	if not Metadata.write(path+".json",data):return false
	if path==_pending_metadata_path:_pending_metadata.clear();_pending_metadata_path=""
	return true
func _save_name()->bool:
	if selected_path.is_empty():return true
	var data:=_metadata(selected_path)
	if str(data.get("name",""))==title_edit.text:return true
	data.name=title_edit.text
	if not _write_metadata(selected_path,data):status.text=t("名称未保存","Name not saved");return false
	status.text=t("已保存","Saved")
	var i:=paths.find(selected_path)
	if i>=0:library.set_item_text(i,(title_edit.text if not title_edit.text.is_empty() else t("录音","Recording"))+" · "+str(data.get("location",""))+" · %ds"%maxi(1,ceili(float(data.get("seconds",0)))))
	return true
func _focus_lost()->void:
	_release_movement()
	if recording:stop_recording()
	stop_playback()
func checkpoint_for_quit()->bool:return stop_recording() and _save_name()
func request_close()->void:
	if _closing or not checkpoint_for_quit():return
	_closing=true;stop_playback();closed.emit()
func _exit_tree()->void:
	stop_playback()
	_release_movement()
	if effect!=null:effect.set_recording_active(false)
	if is_instance_valid(sound):sound.recorder_focus=false;sound.recorder_playback=false
	if is_instance_valid(road) and is_instance_valid(road.field_sound):road.field_sound.set_focus(false)
	if playback!=null:playback.stop();playback.stream=null
	var bus:=AudioServer.get_bus_index(BUS)
	if bus>=0:
		for i in range(AudioServer.get_bus_effect_count(bus)-1,-1,-1):
			if AudioServer.get_bus_effect(bus,i) in [effect,meter]:AudioServer.remove_bus_effect(bus,i)
