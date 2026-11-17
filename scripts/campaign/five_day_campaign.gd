extends Node
const State=preload("res://scripts/campaign/five_day_state.gd")
const Paper=preload("res://scripts/campaign/campaign_paper.gd")
const UI=preload("res://scripts/ui/paper_ui.gd")
const Dialogue=preload("res://scripts/rebuild/scene_dialogue.gd")
const Arrival=preload("res://scripts/rebuild/street_arrival.gd")
const NAMES={"post_office":"邮局工作桌","community_center":"社区中心","residential":"海阶居民楼","food_truck":"餐车","record_store":"唱片店","market":"菜摊","chess_stall":"树下棋摊","tarot_shop":"塔罗店","bookstore":"书店","lookout":"观景台"}
const FAMILIES={"community_center":"community","food_truck":"community","market":"community","residential":"residential","lookout":"residential","chess_stall":"postal","bookstore":"postal","tarot_shop":"coastal","record_store":"coastal"}
const ACTORS={"community":"cici","chef":"咸鱼","record_clerk":"Xanni","bookseller":"Maya","lookout":"Rae","FoodTruckGuest":"尘缘","TarotGuest":"夏透明","Siri":"Siri","Naonao":"闹闹"}
var host:Control
var journey:RefCounted=State.new()
var target:Button
var music:AudioStreamPlayer
var tune_clock:=0.0
var tune_note:=0
var opening:=false

func sync_time()->void:
    if not active():return
    var item:Dictionary=journey.event(journey.current_id())
    var desired:int=int(item.get("minute",1195))
    journey.state["minute"]=maxi(int(journey.state.get("minute",540)),desired)
    host.core.state.minute=int(journey.state.minute)

func begin_arrival()->void:
    if journey.state.get("intro_seen",false):open_current();return
    host.core.state.location="post_office";host._world("post_office")
    var intro:=preload("res://scripts/campaign/arrival_prologue.gd").new()
    host.modal=intro;UI.place(intro,host,Rect2(0,0,1600,900));intro.configure(host)
    intro.finished.connect(func():
        journey.state["intro_seen"]=true
        if not persist():host._show_save_problem(journey.last_error);return
        await host._change_scene(func():host._post_office_room())
        open_current())

func setup(value:Control)->void:
    host=value
    journey.path=host.core.save_path.get_basename()+"_five_days.json"
    music=AudioStreamPlayer.new();music.bus="SolmereAmbience";add_child(music)
    music.stream=load("res://assets/audio/foley/bell.wav")

func active()->bool:return journey.active()
func persist()->bool:
    if not active():return true
    journey.state.location=host._nearest_landmark() if host.view=="world" else "post_office"
    journey.state.room=host.post_office_room_index
    journey.state["view"]=host.view
    journey.state["exploration"]=host.core.state.duplicate(true)
    return journey.save()

func resume()->bool:
    if not journey.load_journey():host._show_save_problem(journey.last_error);return false
    host.core.new_game()
    if journey.state.get("exploration") is Dictionary:host.core.state=journey.state.exploration.duplicate(true)
    sync_time()
    if journey.state.get("view")=="postal_loft":_build_loft()
    elif journey.state.get("view","post_office_room")=="world":
        var destination:String=journey.state.location
        host.core.state.location=_district(destination);host._world(destination)
    else:host._post_office_room(int(journey.state.room))
    return true

func _district(destination:String)->String:
    if destination in ["post_office","bookstore"]:return "post_office"
    if destination in ["community_center","grocery","market","food_truck"]:return "community_center"
    if destination in ["residential","lookout","bus_stop","chess_stall"]:return destination
    return "tarot_shop"

func _anchor(place:String)->float:
    return 12100.0 if place=="food_truck" else float(Arrival.SOURCE_X.get(place,0))*1.5-180.0

func at(place:String)->bool:
    if place=="post_office":return host.view=="post_office_room"
    if host.view!="world" or not is_instance_valid(host._street_road) or not is_instance_valid(host.walker):return false
    return host._street_road.family==FAMILIES.get(place,"") and absf(host.walker.foot.x-_anchor(place))<420.0

func mount()->void:
    if not active():return
    if is_instance_valid(target):target.get_parent().remove_child(target);target.queue_free()
    target=null
    if host.view=="world" and host._street_road.family=="postal" and int(journey.state.day)>=2:
        if host._street_road.world.get_node_or_null("ArthurChess")==null:
            var board:=UI.button(host._street_road.world,"对弈",Rect2(570,598,140,55),func():
                if host.busy or is_instance_valid(host.modal):return
                host.walker.walk_to(Vector2(645,872),open_chess))
            board.name="ArthurChess";board.z_index=3
    if host.view=="post_office_room":
        var old:Node=host.stage.get_node_or_null("AtticEntry")
        if old!=null:old.queue_free()
        if journey.state.evidence.has("attic_key"):
            var attic:=UI.button(host.stage,"↑ 二楼",Rect2(1330,113,170,54),open_attic)
            attic.name="AtticEntry";attic.z_index=3
            attic.visible=host.post_office_room_index==1
            var room:Node=host.stage.get_node_or_null("PostOfficeInterior")
            if room!=null:room.room_changed.connect(func(index:int):attic.visible=index==1)
        return
    var current:Dictionary=journey.current_step()
    if current.is_empty() or host.view!="world":return
    var place:String=current.place
    if host._street_road.family!=FAMILIES.get(place,""):return
    var label:="交谈" if current.kind=="talk" else "查看"
    if current.kind=="sound":label="拾起贺卡"
    target=UI.button(host._street_road.world,label,Rect2(_anchor(place)-60,670,140,55),func():
        if host.busy or is_instance_valid(host.modal):return
        host.walker.walk_to(Vector2(_anchor(place),872),open_current))
    target.name="CampaignInteract";target.z_index=3

func _unhandled_key_input(event:InputEvent)->void:
    if not active() or host.busy or is_instance_valid(host.modal):return
    if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_E:
        var current:Dictionary=journey.current_step()
        if not current.is_empty() and at(current.place):
            get_viewport().set_input_as_handled();open_current()

func intercept_actor(id:String)->bool:
    if not active():return false
    var current:Dictionary=journey.current_step()
    if current.get("kind")=="talk" and str(current.speaker)==ACTORS.get(id,"") and at(current.place):
        open_current();return true
    var greetings:Dictionary={"chef":"今天的锅还热着。你先忙，想吃点东西时再过来。","community":"柜台还开着。要核对收件信息，可以把信封拿过来。","bookseller":"我在整理书。你想坐一会儿也可以。","lookout":"今天能看见很远的海面。","grocer":"菜还新鲜，晚点收摊。","TarotGuest":"卡片先放在这里。你慢慢走。","Siri":"Siri 看了看你，把尾巴收回菜筐旁。","Naonao":"棋摊那边还有空位。"}
    if greetings.has(id):
        _talk({"speaker":ACTORS[id],"lines":[greetings[id]],"place":host._nearest_landmark(),"ambient":true})
        return true
    return false

func open_current()->void:
    if host.busy or opening:return
    var current:Dictionary=journey.current_step()
    if current.is_empty():satchel();return
    if not at(str(current.place)):satchel();return
    host._close()
    if is_instance_valid(host.walker):host.walker.cancel();host.walker.manual_enabled=false
    if current.kind=="talk":_talk(current);return
    var paper:=Paper.new();host.modal=paper
    UI.place(paper,host,Rect2(0,0,1600,900));paper.configure(self,current)

func _talk(current:Dictionary)->void:
    host._close()
    if is_instance_valid(host.walker):host.walker.cancel();host.walker.manual_enabled=false
    var lines:Array=current.lines.duplicate()
    var variant:Dictionary=current.get("variants",{})
    if not variant.is_empty() and journey.state.flags.get(variant.flag)==variant.value:lines=variant.lines.duplicate()
    # Use the retained authored notebook renderer and the correct available portrait.
    var pages:Array=[]
    for text:String in lines:
        for offset:int in range(0,text.length(),48):pages.append(text.substr(offset,48))
    var dialogue:=Dialogue.new();dialogue.name="CampaignConversation"
    dialogue.authored_text_enabled=true;dialogue.locale=host.preferences.values.language
    dialogue.light_source=host.walker;host.modal=dialogue
    UI.place(dialogue,host,Rect2(0,0,1600,900))
    var portraits:Dictionary=preload("res://scripts/campaign/campaign_art.gd").get_binding("portraits",{})
    var portrait:String=str(portraits.get(current.speaker,""))
    dialogue.configure(str(current.speaker),pages[0],[],"courier_source.jpg",portrait)
    dialogue.set_text_rate(host.preferences.text_rate());dialogue.cue.connect(host.sound.play)
    dialogue.set_meta("campaign_page",0)
    var expected:String=journey.token()
    dialogue.closed.connect(host._close)
    dialogue.advanced.connect(func():
        var index:int=int(dialogue.get_meta("campaign_page"))+1
        if index>=pages.size():
            if current.get("ambient",false):host._close(true);return
            var error:String=complete(expected,{"heard":true},str(current.place))
            if not error.is_empty():host._show_save_problem(error)
        else:dialogue.set_meta("campaign_page",index);dialogue.set_line(str(current.speaker),str(pages[index])))
    host.sound.play("paper")

func complete(expected:String,answer:Dictionary,place:String)->String:
    if not at(place):return "请回到这封信所对应的地点。"
    var error:String=journey.submit(expected,answer,place)
    if not error.is_empty():return error
    host.sound.play("deliver")
    host._close();mount()
    sync_time()
    host._save()
    var next:Dictionary=journey.current_step()
    if not next.is_empty() and at(next.place):
        open_current.call_deferred()
    elif journey.state.finished:
        host._sheet("Dear Somewhere","自己的信已经寄出。可以继续在小镇散步、拍照，或回看本子里的记录。",[])
    elif journey.day_complete():host._say("今天的信都收好了。回邮局右侧，上二楼休息。")
    else:host._say(str(NAMES.get(next.get("place",""),"")))
    return ""

func satchel()->void:
    if not active():return
    var current:Dictionary=journey.current_step()
    var root:Control=host._overlay();root.name="CampaignSatchel"
    var paper:=UI.panel(root,Rect2(350,185,900,530),Color("faf3e5"))
    paper.add_theme_stylebox_override("panel",preload("res://scripts/ui/paper_presentation.gd").backing(Color("faf3e5")))
    UI.label(paper,"第 %d 日 · 邮袋"%int(journey.state.day),Rect2(45,30,700,54),30)
    UI.button(paper,"×",Rect2(800,20,60,58),host._dismiss_modal.bind(true))
    var copy:="今天的信都已收好。可以自由走走，或从邮局右侧上二楼休息。" if not journey.state.finished else "这段旅程已经写进本子。小镇仍然可以探索。"
    if not current.is_empty():copy=str(journey.event(journey.current_id()).title)+"\n\n"+str(current.title)+"\n"+str(NAMES.get(current.place,current.place))
    UI.body(paper,copy,Rect2(45,115,800,240),28)
    if not current.is_empty():
        var action:=UI.button(paper,"拿出来" if at(current.place) else "展开地图",Rect2(45,389,350,62),open_current if at(current.place) else host._map)
        action.name="CampaignNext"
    elif not journey.state.finished and host.view=="post_office_room":UI.button(paper,"上二楼",Rect2(45,389,350,62),open_attic).name="CampaignNext"
    UI.button(paper,"照片",Rect2(455,389,170,62),func():host._bag_photos_visible=true;host._bag())
    UI.button(paper,"录音",Rect2(660,389,180,62),host._bag_recordings)

func journal()->void:
    var root:Control=host._overlay();root.name="CampaignJournal"
    var paper:=UI.panel(root,Rect2(300,100,1000,700),Color("faf3e5"))
    UI.label(paper,"小镇手记",Rect2(45,25,850,60),31)
    UI.button(paper,"×",Rect2(905,20,60,58),host._dismiss_modal.bind(true))
    var text:=""
    for entry:Dictionary in journey.state.journal:text+="第 %d 日 · %s\n%s\n\n"%[int(entry.day),entry.title,entry.text]
    for key:String in journey.state.evidence:text+=str(journey.state.evidence[key])+"\n\n"
    if text.is_empty():text="还没有记下新的事情。"
    UI.body(paper,text,Rect2(45,105,905,450),25)
    if int(journey.state.day)>=3 and journey.available("anonymous") and not journey.state.events.anonymous.done:
        UI.button(paper,"匿名信 · 支线",Rect2(45,594,280,60),func():
            if journey.select("anonymous"):mount();satchel())
    if journey.state.evidence.has("performance"):
        UI.button(paper,"演出录音",Rect2(340,594,230,60),replay_recording)
    UI.button(paper,"回到今日的信",Rect2(620,594,330,60),func():journey.state.selected="";journey.save();mount();satchel())

func open_attic()->void:
    if host.busy:return
    if host.view!="post_office_room" or not journey.state.evidence.has("attic_key"):return
    host._change_scene(_build_loft)

func _build_loft()->void:
    host._new_stage("postal_loft")
    var loft:=preload("res://scripts/campaign/postal_loft.gd").new()
    UI.place(loft,host.stage,Rect2(0,0,1600,900));loft.configure(self)
    host.sound.set_location("post_office",int(host.core.state.minute),true)
    persist()

func _sleep()->void:
    if not journey.sleep():host._show_save_problem(journey.last_error);return
    journey.state.minute=540
    host.core.state.minute=540
    host._change_scene(func():host._post_office_room();persist())

func open_chess()->void:
    host._close()
    if is_instance_valid(host.walker):host.walker.cancel();host.walker.manual_enabled=false
    var board:=preload("res://scripts/campaign/arthur_board.gd").new()
    host.modal=board;UI.place(board,host,Rect2(0,0,1600,900));board.configure(self)

func replay_recording()->void:
    var page:Control=host._sheet("演出录音","Rae 留存的那一晚。",[])
    var player:=AudioStreamPlayer.new();player.stream=load(str(preload("res://scripts/campaign/campaign_art.gd").get_binding("performance_audio")))
    player.bus="SolmereMusic";player.volume_db=-7;page.add_child(player);player.play()
    host.sound.recorder_focus=true
    page.tree_exiting.connect(func():host.sound.recorder_focus=false)
    player.finished.connect(player.play)

func _process(delta:float)->void:
    if not active() or host.view!="world" or not is_instance_valid(host.walker):return
    var current:Dictionary=journey.current_step()
    var place:=""
    if current.get("kind")=="sound":place=str(current.place)
    elif journey.state.evidence.has("music_delivered"):place="tarot_shop"
    if place.is_empty() or host._street_road.family!=FAMILIES.get(place,""):return
    var distance:float=absf(host.walker.foot.x-_anchor(place))
    if distance>1300 or is_instance_valid(host.modal):return
    tune_clock-=delta
    if tune_clock<=0:
        tune_clock=.6 if tune_note%4!=3 else 1.2
        music.pitch_scale=[1.0,1.25,1.5,1.125][tune_note%4]
        music.volume_db=linear_to_db(clampf(1.0-distance/1300.0,.01,1.0)*.22)
        music.play();tune_note+=1
