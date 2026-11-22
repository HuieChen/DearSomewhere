extends SceneTree

var checks:=0
var failures:Array[String]=[]
var output:=""

func _initialize()->void:
    for arg:String in OS.get_cmdline_user_args():
        if arg.begins_with("--qa-out="):output=arg.trim_prefix("--qa-out=")
    run.call_deferred()

func check(value:bool,label:String)->void:
    checks+=1
    if not value:failures.append(label);push_error(label)

func run()->void:
    root.unfocusable=true;root.size=Vector2i(1600,900)
    var host=load("res://scripts/rebuild/final_playable.gd").new();host.allow_display_changes=false;root.add_child(host);host.size=Vector2(1600,900)
    # Keep this acceptance probe locale deterministic even when a prior playtest
    # left an English preference in the shared user profile.
    host.preferences.values.language="zh"
    host.preferences.values.text_speed="instant"
    host.campaign.journey.path="user://qa/indirect-clue-flow/five-days.json"
    check(host.campaign.journey.new_journey(),"journey created")
    var item:Dictionary=host.campaign.journey.event("grandmother")
    var step:Dictionary=host.campaign.journey.current_step("grandmother")
    var lead:String=host.campaign._lead_for(item,step)
    check(lead=="信封底下还压着一张旧便签。上面只写着：先看信，再问人。","event lead is concrete")
    check(not lead.contains("邮局"),"event lead avoids location answer")
    check(not lead.contains("答案"),"event lead avoids generated meta language")
    host.campaign.journey.state.intro_seen=true
    host._post_office_room()
    await create_timer(.1).timeout
    host.campaign.satchel()
    await process_frame
    var satchel:Control=host.get_node_or_null("CampaignSatchel")
    check(satchel!=null,"satchel opens")
    var joined:=""
    if satchel!=null:
        for label:Label in satchel.find_children("*","Label",true,false):joined+=label.text+"\n"
        for body:RichTextLabel in satchel.find_children("*","RichTextLabel",true,false):joined+=body.text+"\n"
    check(joined.contains("信封底下还压着一张旧便签"),"satchel shows a physical lead")
    check(not joined.contains("这不是答案"),"satchel avoids meta instruction")
    check(not joined.contains("外婆留给 Anne 的信"),"satchel hides event title")
    check(not joined.contains("信封正反面"),"satchel hides step title")
    check(not joined.contains("邮局工作桌"),"satchel hides target location")
    host._dismiss_modal(true)
    host.campaign.journal()
    await process_frame
    var journal:Control=host.get_node_or_null("CampaignJournal")
    check(journal!=null,"journal opens")
    if journal!=null:
        var journal_text:=""
        for label:Label in journal.find_children("*","Label",true,false):journal_text+=label.text+"\n"
        for body:RichTextLabel in journal.find_children("*","RichTextLabel",true,false):journal_text+=body.text+"\n"
        check(not journal_text.contains("邮局工作桌"),"journal does not leak destination")
    host.queue_free();await process_frame
    DirAccess.make_dir_recursive_absolute(output)
    var file:=FileAccess.open(output+"/receipt.json",FileAccess.WRITE)
    file.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"));file.close()
    quit(0 if failures.is_empty() else 1)

