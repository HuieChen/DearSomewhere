extends SceneTree

var checks:=0
var failures:Array[String]=[]
var cues:Array[String]=[]

func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures.append(label);push_error(label)

func _initialize()->void:
	_run.call_deferred()

func _run()->void:
	root.size=Vector2i(1600,900);root.unfocusable=true
	var game=load("res://scripts/rebuild/final_playable.gd").new();game.allow_display_changes=false;root.add_child(game);game.size=Vector2(1600,900)
	game.sound.cue_played.connect(func(kind:String,_sample:String):cues.append(kind))
	game.core.new_game();game._world("grocery");await create_timer(.35).timeout
	var paper_button:Button=load("res://scripts/ui/paper_ui.gd").button(game,"Audio test",Rect2(20,20,180,50),func():pass)
	paper_button.pressed.emit();await process_frame
	check(cues.has("paper"),"generic PaperUI buttons emit a paper cue")
	await create_timer(.2).timeout
	var before:=cues.size()
	var quickbar=game.stage.find_child("AuthoredQuickbar",true,false)
	check(quickbar!=null,"world HUD exposes the authored quickbar")
	if quickbar!=null:quickbar._activate("camera")
	await create_timer(.15).timeout
	check(cues.size()>before and cues.has("paper"),"quickbar actions emit a paper cue")
	game.sound.shutdown();game.queue_free();await process_frame;await process_frame
	FileAccess.open("user://audio-interaction-coverage-20261115.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"cues":cues}))
	print("AUDIO_INTERACTION_COVERAGE ",checks," / ",failures.size());quit(0 if failures.is_empty() else 1)
