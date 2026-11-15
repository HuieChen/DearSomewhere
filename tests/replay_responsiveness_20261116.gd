extends SceneTree
var out:=""
var checks:=0
var failures:Array[String]=[]
func _initialize():
	for arg:String in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	if out.is_empty() or not str(OS.get_cmdline_user_args()).contains("--final-save=user://qa/"):quit(1);return
	run.call_deferred()
func check(ok:bool,message:String):
	checks+=1
	if not ok:failures.append(message);push_error(message)
func run():
	root.unfocusable=true;Engine.max_fps=60
	DirAccess.make_dir_recursive_absolute(out)
	var sound:=preload("res://scripts/ui/audio_feedback.gd").new();root.add_child(sound)
	sound.set_process(false)
	var recorder:=preload("res://scripts/ui/field_recorder.gd").new()
	recorder.sound=sound;recorder.directory=out.path_join("recordings");root.add_child(recorder)
	root.focus_exited.disconnect(recorder._focus_lost);recorder.set_process(false)
	DirAccess.make_dir_recursive_absolute(recorder.directory)
	var wav:=AudioStreamWAV.new();wav.format=AudioStreamWAV.FORMAT_16_BITS;wav.mix_rate=44100;wav.stereo=true
	var bytes:=PackedByteArray();bytes.resize(120*44100*4)
	# The loudest sample is at the end: sampling a prefix would overboost it.
	bytes.encode_s16(bytes.size()-2,16384);wav.data=bytes
	var path:=recorder.directory.path_join("long.wav");check(wav.save_to_wav(path)==OK,"120-second stereo fixture saved")
	var original_hash:=FileAccess.get_sha256(path)
	recorder.selected_path=path
	var start:=Time.get_ticks_usec();recorder.toggle_playback()
	var open_ms:=(Time.get_ticks_usec()-start)/1000.0
	check(recorder._replay_preparing and not recorder.playback.playing,"first replay visibly prepares before playing")
	check(not sound.recorder_playback,"preparation leaves environment audible")
	var frames:=0;var wait_started:=Time.get_ticks_usec()
	while recorder._replay_preparing and frames<600:
		frames+=1
		# Processing continues while the private worker reads and scans.
		await process_frame
	var preparation_ms:=(Time.get_ticks_usec()-wait_started)/1000.0
	check(frames>1 and frames<600,"scene frames continue during long replay preparation")
	check(open_ms<50.0,"Play returns within 50 ms without loading or scanning PCM on the main thread")
	check(recorder.playback.playing and sound.recorder_playback,"finished scan starts playback with ambience ducking")
	check(absf(recorder.playback.volume_db-.020599913)<.001,"gain includes the final stereo sample exactly")
	recorder.stop_playback();recorder.toggle_playback()
	check(not recorder._replay_preparing and recorder.playback.playing,"repeat listening uses bounded exact-gain cache")
	recorder.stop_playback();recorder._replay_cache.clear();recorder.toggle_playback();recorder.toggle_playback()
	check(not recorder._replay_preparing and not recorder.playback.playing and recorder._replay_job==null,"second Play cancels preparation and detaches the cancelled job")
	recorder.toggle_playback();recorder._focus_lost()
	check(not recorder._replay_preparing and not sound.recorder_playback,"focus loss cancels pending replay")
	recorder.toggle_playback();recorder.paths=[path];recorder._select(0)
	check(not recorder._replay_preparing and not recorder.playback.playing,"selection cancels pending replay")
	recorder.toggle_playback();recorder.request_close();await process_frame
	check(recorder._closing and not recorder._replay_preparing and not recorder.playback.playing,"close cancels preparation without deferred playback")
	check(FileAccess.get_sha256(path)==original_hash,"preparation never rewrites source recording")
	recorder.queue_free();await process_frame
	# The street's local sources own these events; force many scheduler ticks
	# to catch probabilistic duplicate voices, including while aiming a recorder.
	for location:String in ["post_office","community_center","bus_stop","lookout","chess_stall","residential"]:
		sound.set_location(location,720,false)
		for tick in 100:
			sound._detail_after=-1;sound._process(.016)
		check(sound._shots.is_empty(),location+": no duplicate non-spatial field voices")
	sound.positional_field=false;sound._rng.seed=123
	for tick in 100:sound._detail_after=-1;sound._process(.016)
	check(not sound._shots.is_empty(),"non-spatial host retains fallback ambience")
	sound.shutdown();sound.queue_free();await process_frame;await create_timer(.3).timeout
	var receipt:={"checks":checks,"failures":failures,"open_ms":open_ms,"preparation_ms":preparation_ms,"responsive_frames":frames}
	FileAccess.open(out.path_join("receipt.json"),FileAccess.WRITE).store_string(JSON.stringify(receipt,"\t"))
	print("REPLAY_RESPONSIVENESS ",JSON.stringify(receipt));quit(0 if failures.is_empty() else 1)
