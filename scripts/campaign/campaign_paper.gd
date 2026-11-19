extends Control
## A paper/object surface. Nothing completes on dismissal; unfinished work persists.
const UI=preload("res://scripts/ui/paper_ui.gd")
const Presentation=preload("res://scripts/ui/paper_presentation.gd")
const Art=preload("res://scripts/campaign/campaign_art.gd")
var controller:Node
var sound:Node
var step:Dictionary
var answer:Dictionary={}
var expected_token:String
var event_id:String
var surface:Control
var area:Control
var notice:Label
var finish_button:Button
var page:=0
var selected_item:=""
var drag_item:=""
var drag_origin:=Vector2.ZERO
var pieces:Dictionary={}
var grid_origin:=Vector2(380,95)
var cell_size:=70.0
var audio:AudioStreamPlayer
var elapsed:=0.0
var playing:=false
var editor:TextEdit
var recipient:OptionButton
var locked:=false

func configure(owner_node:Node,data:Dictionary)->void:
    controller=owner_node;sound=controller.host.sound;step=data
    event_id=controller.journey.current_id();expected_token=controller.journey.token()
    answer=controller.journey.work(event_id).get("answer",{}).duplicate(true)
    for key:String in ["seen","strikes"]:
        if answer.has(key):answer[key]=answer[key].map(func(value:Variant):return int(value))
    name="CampaignPaper"
    var shade:=ColorRect.new();shade.color=Color(0.08,0.13,0.16,0.28)
    UI.place(shade,self,Rect2(0,0,1600,900))
    surface=UI.panel(self,Rect2(230,90,1140,720),Color("faf3e5"))
    surface.add_theme_stylebox_override("panel",Presentation.backing(Color("faf3e5")))
    UI.label(surface,str(step.title),Rect2(52,27,920,54),30,Color("435b57"))
    var close:=UI.button(surface,"×",Rect2(1040,22,64,58),request_close);close.name="CampaignClose"
    area=Control.new();UI.place(area,surface,Rect2(52,106,1036,490))
    notice=UI.label(surface,"",Rect2(52,594,1000,44),20,Color("a34c48"));notice.name="CampaignNotice"
    finish_button=UI.button(surface,str(step.get("finish","收好")),Rect2(800,648,280,48),_submit)
    finish_button.name="CampaignFinish"
    _build()
    Presentation.enter(surface)

func _clear_area()->void:
    for child in area.get_children():area.remove_child(child);child.queue_free()

func _build()->void:
    _clear_area()
    match str(step.kind):
        "read","inspect":_pages()
        "choice","sort":_choices()
        "pack":_packing()
        "sequence":_sequence()
        "order":_ordering()
        "cook":_cooking()
        "strike":_strikes()
        "write":_writing()
        "sound":
            UI.body(area,"贺卡的声音就在这里。卡片没有署名，先带回邮局。",Rect2(30,85,950,200),27)
            answer.found=true;finish_button.text="拿起贺卡"
        "listen":_listening()

func _pages()->void:
    var pages:Array=step.pages
    page=clampi(int(answer.get("page",0)),0,pages.size()-1)
    var seen:Array=answer.get("seen",[])
    if page not in seen:seen.append(page)
    answer.seen=seen;answer.page=page
    var text_rect:=Rect2(36,22,964,360)
    if step.get("gives",{}).has("mayor_identity") and page==0:
        var portrait:=TextureRect.new();portrait.name="MayorPhotograph"
        portrait.texture=preload("res://scripts/rebuild/supplied_character_art.gd").texture("nanxing_smile")
        portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE
        UI.place(portrait,area,Rect2(45,0,330,395))
        text_rect=Rect2(420,95,570,260)
    UI.body(area,str(pages[page]),text_rect,28).name="CampaignDocument"
    var prev:=UI.button(area,"←",Rect2(294,411,100,50),func():_page(-1));prev.name="PagePrevious";prev.disabled=page==0
    UI.label(area,"%d / %d"%[page+1,pages.size()],Rect2(455,410,140,48),22)
    var next:=UI.button(area,"→",Rect2(640,411,100,50),func():_page(1));next.name="PageNext";next.disabled=page==pages.size()-1
    finish_button.disabled=seen.size()<pages.size()

func _page(direction:int)->void:
    answer.page=page+direction;sound.play("flip");_build()

func _choices()->void:
    finish_button.visible=false
    for i:int in step.options.size():
        var option:Dictionary=step.options[i]
        var button:=UI.button(area,str(option.label),Rect2(65,28+i*99,906,76),func():answer.choice=option.id;_submit())
        button.name="Choice_"+str(option.id)

func _sequence()->void:
    var actions:Array=answer.get("actions",[])
    var envelope:=UI.texture(area,"",Rect2(200,0,630,290));envelope.texture=Art.texture("envelope")
    envelope.rotation=-.02+float(actions.size())*.008
    envelope.pivot_offset=envelope.size*.5
    var description:String="" if actions.is_empty() else str(actions[-1])+" · 已完成"
    UI.label(area,description,Rect2(260,284,700,45),23,Color("52766b"))
    if actions.size()<step.actions.size():
        # Only the currently possible physical operation is offered.
        var next:String=str(step.actions[actions.size()])
        var button:=UI.button(area,next,Rect2(260,336,510,76),func():
            actions.append(next);answer.actions=actions;sound.play("stamp" if next.contains("邮票") or next.contains("签") else "flip");_persist();_build())
        button.name="SequenceAction"
    else:UI.label(area,"已整理好",Rect2(380,336,300,60),28,Color("52766b"))
    finish_button.disabled=actions.size()!=step.actions.size()

func _ordering()->void:
    var chosen:Array=answer.get("actions",[])
    var ordering:Array=[2,0,3,1]
    for slot:int in ordering.size():
        var index:int=ordering[slot]
        var text:String=step.actions[index]
        var button:=UI.button(area,text,Rect2(30+slot*250,25,230,105),func():chosen.append(text);answer.actions=chosen;_persist();_build())
        button.name="Order_"+str(index);button.disabled=text in chosen
    UI.label(area," → ".join(PackedStringArray(chosen)),Rect2(30,190,970,110),25)
    UI.button(area,"重新排列",Rect2(360,365,290,60),func():answer.actions=[];_persist();_build()).name="OrderReset"
    finish_button.text="按这个顺序贴好";finish_button.disabled=chosen.size()!=step.actions.size()

func _packing()->void:
    pieces.clear()
    if not answer.has("positions"):answer.positions={}
    UI.label(area,"把物件放进箱内；选中后可旋转。",Rect2(0,0,1000,42),21)
    var grid:=UI.panel(area,Rect2(grid_origin,Vector2(step.columns,step.rows)*cell_size),Color("dfd7bd"));grid.name="PackingBox"
    for y:int in step.rows:
        for x:int in step.columns:
            var tile:=UI.panel(grid,Rect2(Vector2(x,y)*cell_size,Vector2.ONE*cell_size),Color("efe5cb"));tile.mouse_filter=MOUSE_FILTER_IGNORE
    for i:int in step.items.size():
        var item:Dictionary=step.items[i]
        var pos:Array=answer.positions.get(item.id,[-1,-1,false])
        var dimensions:=Vector2(item.h,item.w) if bool(pos[2]) else Vector2(item.w,item.h)
        var tray:Array=[Vector2(0,70),Vector2(150,70),Vector2(0,315)] if str(step.items[0].id)=="cv" else [Vector2(0,70),Vector2(0,170),Vector2(150,170)]
        var at:Vector2=grid_origin+Vector2(pos[0],pos[1])*cell_size if int(pos[0])>=0 else tray[i]
        var piece:=UI.button(area,str(item.label),Rect2(at,dimensions*cell_size-Vector2.ONE*6),func():selected_item=item.id)
        piece.name="Pack_"+str(item.id);piece.z_index=2
        piece.add_theme_stylebox_override("normal",UI.style(Color("faf3e5"),Color("8e9f8b"),6))
        pieces[item.id]=piece
        piece.gui_input.connect(func(input:InputEvent):_piece_input(input,item.id))
    var rotate:=UI.button(area,"旋转 ↻",Rect2(380,412,180,54),_rotate);rotate.name="PackRotate"
    var reset:=UI.button(area,"取出重放",Rect2(620,412,210,54),func():answer.positions={};_persist();_build());reset.name="PackReset"
    finish_button.text="装好了"

func _piece_input(input:InputEvent,id:String)->void:
    if input is InputEventMouseButton and input.button_index==MOUSE_BUTTON_LEFT and input.pressed:
        drag_item=id;selected_item=id;drag_origin=input.position;pieces[id].z_index=4
        pieces[id].accept_event()

func _input(input:InputEvent)->void:
    if drag_item.is_empty():return
    var piece:Control=pieces[drag_item]
    if input is InputEventMouseMotion:
        piece.position=area.get_global_transform().affine_inverse()*input.position-drag_origin
        get_viewport().set_input_as_handled()
    elif input is InputEventMouseButton and input.button_index==MOUSE_BUTTON_LEFT and not input.pressed:
        var point:Vector2=(piece.position-grid_origin)/cell_size
        var old:Array=answer.positions.get(drag_item,[-1,-1,false])
        if point.x<-.5 or point.y<-.5 or point.x>float(step.columns) or point.y>float(step.rows):
            answer.positions[drag_item]=[-1,-1,bool(old[2])]
        else:answer.positions[drag_item]=[clampi(roundi(point.x),0,int(step.columns)-1),clampi(roundi(point.y),0,int(step.rows)-1),bool(old[2])]
        drag_item="";sound.play("snap");_persist();_build();get_viewport().set_input_as_handled()

func _rotate()->void:
    if selected_item.is_empty():notice.text="先选中一件物品。";return
    var pos:Array=answer.positions.get(selected_item,[-1,-1,false]);pos[2]=not bool(pos[2])
    answer.positions[selected_item]=pos;sound.play("tool");_persist();_build()

func _cooking()->void:
    var selected:Array=answer.get("ingredients",[])
    for i:int in step.ingredients.size():
        var ingredient:String=step.ingredients[i]
        var button:=UI.button(area,("✓ " if ingredient in selected else "")+ingredient,Rect2(20+i*202,20,184,65),func():
            if ingredient in selected:selected.erase(ingredient)
            else:selected.append(ingredient)
            answer.ingredients=selected;answer.actions=[];_persist();_build())
        button.name="Ingredient_"+str(i)
    var actions:Array=answer.get("actions",[])
    UI.label(area," → ".join(PackedStringArray(actions)),Rect2(80,140,920,70),27)
    if actions.size()<step.actions.size():
        var action:String=step.actions[actions.size()]
        var button:=UI.button(area,action,Rect2(300,270,420,74),func():actions.append(action);answer.actions=actions;sound.play("tool");_persist();_build())
        button.name="CookAction"
    UI.button(area,"重新试做",Rect2(380,400,260,54),func():answer.actions=[];_persist();_build()).name="CookReset"
    finish_button.text="尝一口";finish_button.disabled=actions.size()!=step.actions.size()

func _strikes()->void:
    var strikes:Array=answer.get("strikes",[])
    for i:int in step.sentences.size():
        var button:=UI.button(area,str(step.sentences[i]),Rect2(20,15+i*100,990,78),func():
            if i in strikes:strikes.erase(i)
            else:strikes.append(i)
            answer.strikes=strikes;_persist();_build())
        button.name="Sentence_"+str(i)
        if i in strikes:
            var line:=ColorRect.new();line.color=Color("685e57");line.mouse_filter=MOUSE_FILTER_IGNORE
            UI.place(line,button,Rect2(18,38,950,2))
    finish_button.text="保留现在的文字"

func _writing()->void:
    UI.label(area,"收件人",Rect2(20,0,140,50),24)
    recipient=OptionButton.new();UI.place(recipient,area,Rect2(160,0,360,52));UI.apply_button_style(recipient)
    for value:String in step.recipients:recipient.add_item(value)
    var previous:String=str(answer.get("recipient",step.recipients[0]))
    recipient.select(maxi(0,step.recipients.find(previous)));answer.recipient=recipient.get_item_text(recipient.selected)
    recipient.item_selected.connect(func(index:int):answer.recipient=recipient.get_item_text(index);sound.play("paper"))
    editor=TextEdit.new();editor.name="LetterText";editor.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
    editor.add_theme_font_size_override("font_size",27);editor.add_theme_color_override("font_color",Color("435b57"))
    editor.add_theme_stylebox_override("normal",UI.style(Color("fffaf0"),Color("d4cdbb"),3))
    editor.placeholder_text="Dear Somewhere,\n";editor.text=str(answer.get("text",""))
    UI.place(editor,area,Rect2(20,80,990,360))
    editor.text_changed.connect(func():answer.text=editor.text)
    finish_button.text="写好了"

func _listening()->void:
    elapsed=0.0
    audio=AudioStreamPlayer.new();audio.stream=load(str(Art.get_binding("performance_audio")));audio.bus="SolmereMusic";audio.volume_db=-7
    add_child(audio)
    sound.recorder_focus=true
    tree_exiting.connect(func():if is_instance_valid(sound):sound.recorder_focus=false)
    UI.label(area,"演出录音",Rect2(370,70,400,70),32)
    UI.body(area,"Rae 留存的那一晚。",Rect2(310,165,600,80),26)
    var play:=UI.button(area,"播放 / 暂停",Rect2(340,290,360,74),func():
        if not playing:
            if audio.get_playback_position()==0.0:audio.play()
            else:audio.stream_paused=false
        else:audio.stream_paused=true
        playing=not playing;sound.play("recorder_start" if playing else "recorder_stop"))
    play.name="ListenToggle";finish_button.disabled=true;finish_button.text="收下录音"

func _process(delta:float)->void:
    if str(step.get("kind",""))=="listen" and playing and is_instance_valid(audio):
        if not audio.playing:audio.play()
        elapsed+=delta;answer.elapsed=elapsed
        notice.text="%d:%02d"%[int(elapsed)/60,int(elapsed)%60]
        finish_button.disabled=elapsed<float(step.seconds)

func _persist()->bool:
    var success:bool=controller.journey.remember(event_id,"answer",answer)
    if not success:notice.text=controller.journey.last_error
    return success

func checkpoint_for_quit()->bool:return _persist()
func request_close()->void:
    if locked:return
    if checkpoint_for_quit():controller.host._close(true)

func _submit()->void:
    if locked:return
    locked=true
    var error:String=controller.complete(expected_token,answer,str(step.place))
    if not error.is_empty():notice.text=error;locked=false;return
