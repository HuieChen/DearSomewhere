extends SceneTree
var checks:=0
var failures:Array[String]=[]
var output:=""
func _initialize():
    for arg:String in OS.get_cmdline_user_args():
        if arg.begins_with("--qa-out="):output=arg.trim_prefix("--qa-out=")
    if output.is_empty() or not str(OS.get_cmdline_user_args()).contains("--final-save=user://qa/"):quit(1);return
    run.call_deferred()
func check(value:bool,label:String):
    checks+=1
    if not value:failures.append(label);push_error(label)
func run():
    root.unfocusable=true;Engine.max_fps=60;root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1600,900);root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    DirAccess.make_dir_recursive_absolute(output)
    var host=load("res://scripts/rebuild/final_playable.gd").new();host.allow_display_changes=false;root.add_child(host);host.size=Vector2(1600,900);host.core.new_game();host.preferences.values.text_speed="instant"
    host.campaign.journey.path="user://qa/authored-turns/five-days.json"
    check(host.campaign.journey.new_journey(),"isolated journey created")
    host.core.state.location="post_office";host._post_office_room();await create_timer(.4).timeout
    var step:Dictionary=host.campaign.journey.current_step()
    check(step.turns.size()==4,"opening source turns connected")
    for lang:String in ["zh","en"]:
        host.preferences.values.language=lang;host.campaign._talk(step);await create_timer(.5).timeout
        var dialogue=host.modal;dialogue.set_text_rate(0)
        var pages:Array=[]
        for turn:Dictionary in step.turns:
            pages.append_array(preload("res://scripts/rebuild/supplied_dialogue.gd").paginate([{"speaker":turn.speaker,"text":turn[lang]}]))
        for i:int in pages.size():
            check(dialogue.get_node("Speaker").text==pages[i].speaker,"speaker "+lang+str(i))
            check(dialogue.get_node("SpokenLine").get_parsed_text()==pages[i].text,"line "+lang+str(i))
            check(dialogue.get_node("SpokenLine").get_content_height()<=dialogue.get_node("SpokenLine").size.y,"fit "+lang+str(i))
            if i<pages.size()-1:dialogue._advance();await create_timer(.23).timeout
        host._close();await create_timer(.15).timeout
        check(host.campaign.journey.token()=="grandmother:0","interruption does not advance "+lang)
    var offer:Dictionary=host.campaign.journey.event("offer").steps[1]
    check(offer.turns.size()==14,"offer manuscript turns connected")
    check(offer.turns[0].speaker=="周晓六" and offer.turns[6].speaker=="Anne","distinct speakers retained")
    check(not offer.turns[0].en.is_empty(),"offer English available")
    for lang:String in ["zh","en"]:
        host.preferences.values.language=lang;host.campaign._talk(offer);await create_timer(.5).timeout
        var dialogue=host.modal;dialogue.set_text_rate(0)
        var pages:Array=[]
        for turn:Dictionary in offer.turns:
            pages.append_array(preload("res://scripts/rebuild/supplied_dialogue.gd").paginate([{"speaker":turn.get("speaker_en",turn.speaker) if lang=="en" else turn.speaker,"text":turn[lang]}]))
        for i:int in pages.size():
            check(dialogue.get_node("Speaker").text==pages[i].speaker,"offer speaker "+lang+str(i))
            check(dialogue.get_node("SpokenLine").get_parsed_text()==pages[i].text,"offer line "+lang+str(i))
            check(dialogue.get_node("SpokenLine").get_content_height()<=dialogue.get_node("SpokenLine").size.y,"offer page fits "+lang+str(i))
            if i<pages.size()-1:dialogue._advance();await create_timer(.23).timeout
        host._close();await create_timer(.1).timeout
    host.sound.shutdown();host.queue_free();await process_frame
    FileAccess.open(output+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));quit(0 if failures.is_empty() else 1)
