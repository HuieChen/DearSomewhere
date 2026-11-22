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
    "grandmother":{"zh":"信封底下还压着一张旧便签。上面只写着：先看信，再问人。","en":"An old note is tucked under the envelope. It says: read the letter before asking around."},
    "mayor":{"zh":"回执边上沾着一小撮狗毛，爪印落在名字下面。","en":"A little dog hair is stuck to the receipt. The paw print sits below the name."},
    "offer":{"zh":"外封的 Congratulations 很醒目。名字印得没错，内容却不是入职。","en":"The word Congratulations is loud on the envelope. The name is right, but it is not a job offer."},
    "portfolio":{"zh":"文件夹里还缺最后一页。简历的名字那一行，被人用手压平了。","en":"The folder is still missing its last page. Someone has pressed the name line flat."},
    "xanni":{"zh":"照片边角卷了。外婆站在最后一排，旁边的人笑得有点歪。","en":"The photo has a curled corner. Your grandmother is in the back row, next to someone with a crooked smile."},
    "music_found":{"zh":"长椅下面还留着一小段音乐。有人刚把贺卡落在这里。","en":"A short tune is still playing under the bench. Someone has just left the card behind."},
    "returned_mayor":{"zh":"退件上盖了三次章，最后一次压过了地址。","en":"The returned mail has three stamps. The last one covers part of the address."},
    "cat_letter":{"zh":"封口有两种爪印。信封没有署名，字却写得很整齐。","en":"There are two kinds of paw marks on the seal. The envelope is unsigned, but the writing is neat."},
    "food_application":{"zh":"信里列了小鱼干、薯条和面包边。收件人一栏只画了几只爪子。","en":"The list asks for fish treats, fries, and bread ends. The recipient line has only paw marks."},
    "theo":{"zh":"生日卡上的日期改过两次。字很小，笔压却很重。","en":"The date on the birthday card was changed twice. The writing is small and pressed hard."},
    "recipe":{"zh":"菜谱缺了一行。南星知道那道味道。","en":"One line is missing from the recipe. Nanxing knows that taste."},
    "tarot_damage":{"zh":"包裹从侧边裂开，里面的牌没有散出来。","en":"The parcel split along one side. The cards inside stayed put."},
    "war_letter":{"zh":"旧地址还在用。寄件人的称呼换过一遍。","en":"The old address is still being used. The sender changed the way they signed it."},
    "cici_forward":{"zh":"这封信又回来了。转寄栏里留着同一个人的笔迹。","en":"The letter has come back again. The forwarding line is in the same handwriting."},
    "future_self":{"zh":"外婆给未来写信，日期只写了“以后”。","en":"Your grandmother wrote to the future. The date only says “later.”"},
    "blank":{"zh":"空信封也占着格位。封口没有拆过。","en":"The empty envelope still has a slot. Its seal has not been opened."},
    "maya_fracture":{"zh":"两份记录都写着同一天，结论却不一样。","en":"Both records carry the same date. Their conclusions do not match."},
    "anonymous":{"zh":"三封无署名信的纸张不一样，折痕却很像。","en":"The three unsigned letters use different paper, but the folds are alike."},
    "maya_truth":{"zh":"标题已经印出来，正文被留在未刊的那一页。","en":"The headline was printed. The body was left on the page that never ran."},
    "old_quarrel":{"zh":"这场争吵隔了很久才寄出来。收件地址写得很慢。","en":"The argument was mailed long after it happened. The address was written slowly."},
    "maya_private":{"zh":"这封信没有走公开地址。信纸边上写着“请勿转交”。","en":"This letter did not use a public address. The edge says “do not forward.”"},
    "visible":{"zh":"申请表有两格没填。写满的经历反而被划掉了一行。","en":"Two boxes on the application are blank. One full line has been crossed out."},
    "solmere":{"zh":"信写给 Solmere，没有写要谁回信。","en":"The letter is addressed to Solmere. It does not say who should answer."},
    "rae":{"zh":"旧信夹着一段旋律，纸边有演出场地的折痕。","en":"A melody is tucked into the old letter. The paper is folded where the venue was written."},
    "radio":{"zh":"收音机缺一个小零件。桌上留着等它响的便签。","en":"The radio is missing a small part. A note on the desk says to wait for it."},
    "dog_gift":{"zh":"礼盒里只差一件。南星会认得那件东西。","en":"The gift box is missing one thing. Nanxing will know it."},
    "music_home":{"zh":"会响的卡片没人签名。第一句旋律却很熟。","en":"The musical card is unsigned. Its first few notes are familiar."},
    "cover_letter":{"zh":"求职信有几句太标准。删掉后，剩下的才像她自己。","en":"A few lines in the cover letter sound too standard. What remains sounds like her."},
    "last_letter":{"zh":"最后一封信只写了日期，没有催回信。","en":"The last letter has only a date. It does not ask for a reply."},
    "performance":{"zh":"录音停在掌声之前。有人把整晚保存下来了。","en":"The recording stops just before the applause. Someone kept the whole night."},
    "somewhere":{"zh":"信纸最下面空着一行。那一行留给你自己。","en":"There is one blank line at the bottom. It is yours."}
}
const KIND_LEADS={
    "talk":{"zh":"先听人把话说完。","en":"Let them finish."},
    "inspect":{"zh":"信封两面都有东西。","en":"There is something on both sides."},
    "read":{"zh":"读完再动手。","en":"Read it before touching anything."},
    "choice":{"zh":"两个办法都像办法。先看看手里那件东西。","en":"Both options look possible. Check what is in your hand."},
    "sort":{"zh":"先把这些放在一起，看日期。","en":"Put these together first. Check the dates."},
    "pack":{"zh":"别硬塞。先让大件进去。","en":"Do not force it. Put the larger piece in first."},
    "sequence":{"zh":"顺序会影响纸面留下什么。","en":"The order changes what stays on the paper."},
    "order":{"zh":"四步都在桌上，按你看到的顺序做。","en":"All four steps are on the desk. Follow what you see."},
    "cook":{"zh":"味道和记录要一起对。","en":"Check the taste against the note."},
    "listen":{"zh":"先听完整一遍。","en":"Listen all the way through once."},
    "strike":{"zh":"删掉一句，看看剩下的像不像她。","en":"Cross out one line. See if the rest sounds like her."},
    "write":{"zh":"先留空，想清楚再写。","en":"Leave it blank for now."}
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
    if journey.state.get("intro_seen",false):
        host._post_office_room(int(journey.state.get("room",0)))
        return
    # The first playable moment is the supplied post-office interior. Keep the
    # checkpoint fields for older saves, but do not route a new player through
    # a staged envelope animation before the authored first conversation.
    journey.state["intro_seen"]=true
    journey.state["intro_turn"]=2
    host.core.state.location="post_office"
    host._post_office_room()
    if not persist():
        journey.state["intro_seen"]=false
        host._show_save_problem(journey.last_error)
        return

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
        begin_arrival();open_current.call_deferred();return true
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
            turns.append({"speaker":str(current.speaker),"speaker_en":str(EN_SPEAKERS.get(str(current.speaker),current.speaker)),"zh":"","en":"No words have been written here yet."})
        else:
            for text:String in lines:turns.append({"speaker":str(current.speaker),"zh":text})
    var grouped:Array=[]
    for turn:Dictionary in turns:
        var language_is_english:bool=host.preferences.values.language=="en"
        var speaker_key:=str(turn.get("speaker_en",EN_SPEAKERS.get(str(turn.speaker),turn.speaker))) if language_is_english else str(turn.speaker)
        var source_text:=str(turn.get("en","")) if language_is_english else str(turn.get("zh",turn.get("text","")))
        if not grouped.is_empty() and str(grouped.back().speaker)==speaker_key:
            grouped.back().text+="\n"+source_text
        else:
            grouped.append({"speaker":speaker_key,"text":source_text})
    for turn:Dictionary in grouped:
        var english:bool=host.preferences.values.language=="en"
        var text:String=str(turn.text)
        var person:String=str(turn.speaker)
        if english and (_contains_cjk(text) or text.strip_edges().is_empty()):
            text="No words have been written here yet."
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
        host._sheet("Dear Somewhere","自己的信已经寄出。小镇还开着门，照片和本子都可以慢慢看。",[])
    elif journey.day_complete():host._say("桌面已经空出一块。楼上还留着一盏灯，去看看吧。")
    else:host._say(_ambient_arrival(next))
    return ""

func _ambient_arrival(next:Dictionary)->String:
    if next.is_empty():return "邮袋里还压着一页没有折好的纸。"
    var item:Dictionary=journey.event(journey.current_id())
    var lead:String=_lead_for(item,next)
    var language:String="en" if is_instance_valid(host) and is_instance_valid(host.preferences) and host.preferences.values.language=="en" else "zh"
    return lead+("\n\nOne small mark is still on the map." if language=="en" else "\n\n地图上还留着一个小标记。")

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
    var copy:="桌面已经空出一块。楼上那扇门还没有关上。" if not journey.state.finished else "这段记录已经写进本子。小镇还在原来的地方。"
    if not current.is_empty():
        var item:Dictionary=journey.event(journey.current_id())
        copy=_lead_for(item,current)
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
