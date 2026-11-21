extends Node
const State=preload("res://scripts/campaign/five_day_state.gd")
const Paper=preload("res://scripts/campaign/campaign_paper.gd")
const UI=preload("res://scripts/ui/paper_ui.gd")
const Dialogue=preload("res://scripts/rebuild/scene_dialogue.gd")
const Arrival=preload("res://scripts/rebuild/street_arrival.gd")
const SuppliedCast=preload("res://scripts/rebuild/supplied_character_art.gd")
const NAMES={"post_office":"邮局工作桌","community_center":"社区中心","residential":"海阶居民楼","food_truck":"餐车","record_store":"唱片店","market":"菜摊","chess_stall":"树下棋摊","tarot_shop":"塔罗店","bookstore":"书店","lookout":"观景台"}
const FAMILIES={"community_center":"community","food_truck":"community","market":"community","residential":"residential","lookout":"residential","chess_stall":"postal","bookstore":"postal","tarot_shop":"coastal","record_store":"coastal"}
const ACTORS={"community":"cici","chef":"咸鱼","record_clerk":"Xanni","bookseller":"Maya","lookout":"Rae","FoodTruckGuest":"尘缘","TarotGuest":"夏透明","Siri":"Siri","Naonao":"闹闹"}
const EN_SPEAKERS={"周晓六":"Xiaoliu","咸鱼":"Xianyu","尘缘":"Chenyuan","夏透明":"Xia Touming","宇星晴":"Yu Xingqing","冥冥":"Mingming","闹闹":"Naonao","巫巫":"cici","邻居":"Neighbor","小孩":"Child","Arthur":"Arthur","Mossner":"Mossner","Maya":"Maya","Rae":"Rae","Xanni":"Xanni","Theo":"Theo","BEETMAN":"BEETMAN","Anne":"Anne","cici":"cici"}
const EVENT_LEADS={
    "grandmother":{"zh":"一封写着你名字的信，被压在桌面更深处。","en":"A letter with your name rests deeper in the tray."},
    "mayor":{"zh":"回执上的印记，比寄件人的称呼更像一个答案。","en":"The mark on the receipt says more than the sender's title."},
    "offer":{"zh":"有人把“祝贺”写得很大，真正想说的话却留在页边。","en":"Someone wrote congratulations in large letters and left the real question in the margin."},
    "portfolio":{"zh":"一份材料在等待被看见，也在等待有人先删掉一句话。","en":"A portfolio is waiting to be seen, and for one sentence to disappear first."},
    "xanni":{"zh":"照片里的空位没有说明是谁离开，只留下了一个熟悉的方向。","en":"The empty place in the photograph names no one, but it faces somewhere familiar."},
    "music_found":{"zh":"回家的路上有一段声音没有找到主人。","en":"A sound on the way home has lost its owner."},
    "returned_mayor":{"zh":"被退回的纸上，盖章的位置比退回的理由更沉。","en":"On the returned page, the stamp weighs more than the reason."},
    "cat_letter":{"zh":"封口留下了爪印，写信的人没有留下名字。","en":"The seal carries a paw print, while the writer kept their name away."},
    "food_application":{"zh":"申请里有一群收件人，它们不会自己来取信。","en":"The application has a group of recipients who will not come for their mail."},
    "theo":{"zh":"生日卡写得很轻，日期却被人反复确认。","en":"The birthday card is light in tone, but its date has been checked twice."},
    "recipe":{"zh":"这份配方缺的不是一种食材，而是一个共同记得的味道。","en":"The recipe is missing more than an ingredient. It is missing a shared taste."},
    "tarot_damage":{"zh":"包裹的裂口朝外，里面的东西却像在躲着谁。","en":"The parcel split outward, while its contents seem to be hiding from someone."},
    "war_letter":{"zh":"旧地址还在，写信的人已经换了称呼。","en":"The old address remains, but the writer has changed what they are called."},
    "cici_forward":{"zh":"同一封信回来的次数，足够让一张公开登记变得可疑。","en":"The number of returns makes even a public register feel uncertain."},
    "future_self":{"zh":"外婆把话寄给未来，却没有规定未来是哪一天。","en":"Your grandmother sent words to the future without naming the day."},
    "blank":{"zh":"空白也占着一个信封的位置。","en":"Blankness still takes up the space of an envelope."},
    "maya_fracture":{"zh":"一份记录被分成两种说法，缺口藏在相同的日期里。","en":"One record has split into two accounts, with the gap hidden in the same date."},
    "anonymous":{"zh":"三封没有署名的信，都把问题留给读到的人。","en":"Three unsigned letters leave their questions with whoever reads them."},
    "maya_truth":{"zh":"没有刊出的部分，比刊出的标题更像一封信。","en":"The part that was not printed reads more like a letter than the headline."},
    "old_quarrel":{"zh":"迟到的争吵还在找一个愿意听完的人。","en":"A late argument is still looking for someone willing to hear it through."},
    "maya_private":{"zh":"这封信没有寄往公共地址，纸边也不欢迎旁观者。","en":"This letter was not sent to a public address, and its edges do not invite spectators."},
    "visible":{"zh":"申请表上的空格，比填写好的经历更有分量。","en":"The blank spaces on the application weigh more than the finished history."},
    "solmere":{"zh":"一封写给小镇的信，没有写清小镇要回什么。","en":"A letter addressed to the town does not say what the town should return."},
    "rae":{"zh":"旧信把一段旋律留在了别人听得见的地方。","en":"An old letter left a melody somewhere another person could hear it."},
    "radio":{"zh":"收音机需要的不只是零件，还有一个愿意等它响起来的人。","en":"The radio needs more than a part. It needs someone willing to wait for it to speak."},
    "dog_gift":{"zh":"礼盒里要放的东西已经齐了，最重要的那件还没有选。","en":"The gift box has its objects, but the important one has not been chosen."},
    "music_home":{"zh":"一张会响的卡片终于遇到了可能听懂它的人。","en":"A card that can sing may have found someone who understands it."},
    "cover_letter":{"zh":"求职信里有几句话太像别人，剩下的才像她自己。","en":"Some lines in the cover letter sound like someone else. The rest sound like her."},
    "last_letter":{"zh":"最后一封信没有催你回答，只把时间交回手里。","en":"The last letter does not ask for an answer. It returns time to your hands."},
    "performance":{"zh":"有人把一晚上的声音留了下来，安静得像一张照片。","en":"Someone kept the sound of one night, quiet as a photograph."},
    "somewhere":{"zh":"写给某处的信，先要找到你愿意留下的那句话。","en":"A letter to somewhere begins with the sentence you are willing to leave behind."}
}
const KIND_LEADS={
    "talk":{"zh":"有人在等一句不会写在信封正面的问候。","en":"Someone is waiting for a greeting that will not fit on the envelope."},
    "inspect":{"zh":"纸面留下了可核对的痕迹，先看它没有说完的部分。","en":"The page leaves something to verify. Start with what it does not finish saying."},
    "read":{"zh":"字已经在这里，读完以后再决定哪些话值得带走。","en":"The words are here. Read them through before deciding what to carry away."},
    "choice":{"zh":"没有一个选项替你判断，手里的物件会记住你的偏向。","en":"No option can judge for you. The objects will remember which way you lean."},
    "sort":{"zh":"几份记录正在互相靠近，先让它们自己排出关系。","en":"Several records are drawing close. Let them show their relationship first."},
    "pack":{"zh":"箱子的空隙有自己的顺序，先听物件落下的声音。","en":"The empty spaces have their own order. Listen to the objects as they settle."},
    "sequence":{"zh":"下一步就在手边，但顺序会留下比结果更久的痕迹。","en":"The next action is close at hand, but the order will outlast the result."},
    "order":{"zh":"四个动作还没有成为一封完整的信。","en":"Four actions have not yet become one complete letter."},
    "cook":{"zh":"熟悉的味道不只来自配方，也来自谁记得它。","en":"A familiar taste comes from more than a recipe. It comes from who remembers it."},
    "listen":{"zh":"不要急着把声音变成答案，让它完整经过。","en":"Do not turn the sound into an answer too soon. Let it pass through."},
    "strike":{"zh":"有些句子要留下，有些句子只是占了位置。","en":"Some sentences should stay. Others are only taking up room."},
    "write":{"zh":"留下什么，是写下去之前的一次停顿。","en":"What to leave behind begins with a pause before writing."}
}
var host:Control
var journey:RefCounted=State.new()
var target:Button
var music:AudioStreamPlayer
var tune_clock:=0.0
var tune_note:=0
var opening:=false
var supplied_actor:TextureRect

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
    if not journey.state.get("intro_seen",false):
        begin_arrival();return true
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
    if is_instance_valid(supplied_actor):
        supplied_actor.get_parent().remove_child(supplied_actor);supplied_actor.queue_free()
    supplied_actor=null
    if host.view=="world":_mount_supplied_actor()
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
    if is_instance_valid(supplied_actor) and SuppliedCast.CHIBIS.has(str(current.get("speaker",""))):
        target.position=supplied_actor.position+Vector2(supplied_actor.size.x*.5-70,-65)

func _mount_supplied_actor()->void:
    var current:Dictionary=journey.current_step()
    if current.is_empty():return
    var speaker:String=str(current.get("speaker",""))
    var key:String=str(SuppliedCast.CHIBIS.get(speaker,""))
    var place:String=str(current.place)
    if host._street_road.family=="community":
        place="community_center"
        key="nanxing_happy" if journey.current_id()=="dog_gift" else ("nanxing_neutral" if journey.current_id()=="returned_mayor" else "nanxing_smile")
    if key.is_empty() or host._street_road.family!=FAMILIES.get(place,""):return
    if key.begins_with("nanxing"):
        var existing:=host._street_road.world.get_node_or_null("NanxingWorld") as TextureRect
        if is_instance_valid(existing):
            existing.texture=SuppliedCast.texture(key)
            supplied_actor=existing
            return
    supplied_actor=TextureRect.new();supplied_actor.name="SuppliedCampaignActor"
    supplied_actor.texture=SuppliedCast.texture(key)
    supplied_actor.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    supplied_actor.mouse_filter=Control.MOUSE_FILTER_IGNORE
    supplied_actor.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    var height:=240.0 if key.begins_with("nanxing") else 310.0
    var dims:Vector2=supplied_actor.texture.get_size()*height/supplied_actor.texture.get_height()
    var offset:=210.0 if key.begins_with("nanxing") else -240.0
    UI.place(supplied_actor,host._street_road.world,Rect2(Vector2(_anchor(place)+offset-dims.x*.5,850-height),dims))
    supplied_actor.modulate=host.walker.modulate
    supplied_actor.z_index=1
    host._street_road.ambient_figures.append(supplied_actor)

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
    var turns:Array=current.get("turns",[])
    if turns.is_empty():
        if host.preferences.values.language=="en":
            turns.append({"speaker":str(current.speaker),"speaker_en":str(EN_SPEAKERS.get(str(current.speaker),current.speaker)),"zh":"","en":"This part of the conversation is still being translated."})
        else:
            for text:String in lines:turns.append({"speaker":str(current.speaker),"zh":text})
    for turn:Dictionary in turns:
        var english:bool=host.preferences.values.language=="en"
        var text:String=str(turn.get("en","")) if english else str(turn.get("zh",turn.get("text","")))
        var person:String=str(turn.get("speaker_en",EN_SPEAKERS.get(str(turn.speaker),turn.speaker))) if english else str(turn.speaker)
        if english and (_contains_cjk(text) or text.strip_edges().is_empty()):
            text="This part of the conversation is still being translated."
        if english and _contains_cjk(person):person="Narrator"
        var divided:Array=preload("res://scripts/rebuild/supplied_dialogue.gd").paginate([{"speaker":person,"text":text}])
        pages.append_array(divided)
    var dialogue:=Dialogue.new();dialogue.name="CampaignConversation"
    dialogue.authored_text_enabled=true;dialogue.locale=host.preferences.values.language
    dialogue.light_source=host.walker;host.modal=dialogue
    UI.place(dialogue,host,Rect2(0,0,1600,900))
    var portraits:Dictionary=preload("res://scripts/campaign/campaign_art.gd").get_binding("portraits",{})
    var portrait:String=str(portraits.get(current.speaker,""))
    dialogue.configure(str(pages[0].speaker),str(pages[0].text),[],"courier_source.jpg",portrait)
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
        else:dialogue.set_meta("campaign_page",index);dialogue.set_line(str(pages[index].speaker),str(pages[index].text)))
    host.sound.play("paper")

func _contains_cjk(value:String)->bool:
    for character:String in value:
        var code:=character.unicode_at(0)
        if code>=0x3400 and code<=0x9fff:return true
    return false

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
    elif journey.day_complete():host._say("桌面已经空出一块。楼上还留着一盏灯，去看看吧。")
    else:host._say(_ambient_arrival(next))
    return ""

func _ambient_arrival(next:Dictionary)->String:
    if next.is_empty():return "邮袋里还压着一页没有折好的纸。"
    var item:Dictionary=journey.event(journey.current_id())
    var lead:String=_lead_for(item,next)
    return lead+"\n\n如果想确认，再把地图摊开。"

func _lead_for(item:Dictionary,step:Dictionary)->String:
    var language:String="en" if is_instance_valid(host) and is_instance_valid(host.preferences) and host.preferences.values.language=="en" else "zh"
    var id:String=str(item.get("id",journey.current_id()))
    var event_lead:Dictionary=EVENT_LEADS.get(id,{})
    if event_lead.has(language):return str(event_lead[language])
    var kind:String=str(step.get("kind","inspect"))
    var kind_lead:Dictionary=KIND_LEADS.get(kind,{})
    if kind_lead.has(language):return str(kind_lead[language])
    return "有一处细节还没有和手里的纸对上。" if language=="zh" else "One detail still does not match the paper in your hand."

func satchel()->void:
    if not active():return
    var current:Dictionary=journey.current_step()
    var root:Control=host._overlay();root.name="CampaignSatchel"
    var paper:=UI.panel(root,Rect2(350,185,900,530),Color("faf3e5"))
    paper.add_theme_stylebox_override("panel",preload("res://scripts/ui/paper_presentation.gd").backing(Color("faf3e5")))
    UI.label(paper,"第 %d 日 · 邮袋"%int(journey.state.day),Rect2(45,30,700,54),30)
    UI.button(paper,"×",Rect2(800,20,60,58),host._dismiss_modal.bind(true))
    var copy:="桌面已经空出一块。楼上那扇门还没有关上。" if not journey.state.finished else "这段旅程已经写进本子。小镇仍然可以探索。"
    if not current.is_empty():
        var item:Dictionary=journey.event(journey.current_id())
        copy="留在纸角上的一句话\n\n"+_lead_for(item,current)+"\n\n这不是答案。把它带在身上，遇见合适的人或物件时再回来看。"
    UI.body(paper,copy,Rect2(45,115,800,240),27)
    if not current.is_empty():
        var action:=UI.button(paper,"展开这页" if at(current.place) else "摊开地图",Rect2(45,389,350,62),open_current if at(current.place) else host._map)
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
    for entry:Dictionary in journey.state.journal:
        text+="第 %d 日 · %s\n%s\n\n"%[int(entry.day),entry.title,entry.text]
    var full_records:=""
    for key:String in journey.state.evidence:
        var record:String=str(journey.state.evidence[key])
        full_records+=key+"\n"+record+"\n\n"
        text+="· "+_journal_excerpt(record)+"\n"
    if text.is_empty():text="还没有记下新的事情。"
    UI.body(paper,text,Rect2(45,105,905,450),25)
    if not full_records.is_empty():
        UI.button(paper,"摊开原始记录",Rect2(730,594,220,60),func():host._sheet("原始记录",full_records,[]))
    if int(journey.state.day)>=3 and journey.available("anonymous") and not journey.state.events.anonymous.done:
        UI.button(paper,"匿名信 · 支线",Rect2(45,594,280,60),func():
            if journey.select("anonymous"):mount();satchel())
    if journey.state.evidence.has("performance"):
        UI.button(paper,"演出录音",Rect2(340,594,230,60),replay_recording)
    UI.button(paper,"回到今日的信",Rect2(45,650,905,48),func():journey.state.selected="";journey.save();mount();satchel())

func _journal_excerpt(value:String)->String:
    var one_line:String=value.replace("\n"," ").strip_edges()
    var stop:int=one_line.find("。")
    if stop>=0:one_line=one_line.left(stop+1)
    if one_line.length()>54:one_line=one_line.left(53)+"…"
    return one_line

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
