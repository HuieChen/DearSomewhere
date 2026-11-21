extends SceneTree
## Production host, routed mouse/key events, isolated saves. Not OS/human acceptance.
const Host=preload("res://scripts/rebuild/final_playable.gd")
const Solutions=preload("res://tests/five_day_state_smoke.gd")
var host:Control
var checks:=0
var errors:Array[String]=[]
var evidence:="D:/Codex-build-cache/dear-flow-20261117/evidence/"
var helper:SceneTree
var screenshot_events:Dictionary={}
func _initialize()->void:run.call_deferred()
func verify(value:bool,label:String)->bool:
    checks+=1
    if not value:errors.append(label);push_error(label)
    return value
func node(id:String)->Control:return root.find_child(id,true,false) as Control
func settle(seconds:float=.25)->void:await create_timer(seconds).timeout
func click_at(point:Vector2)->void:
    var move:=InputEventMouseMotion.new();move.position=point;move.global_position=point;Input.parse_input_event(move)
    var down:=InputEventMouseButton.new();down.position=point;down.global_position=point;down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;Input.parse_input_event(down)
    await process_frame
    var up:=InputEventMouseButton.new();up.position=point;up.global_position=point;up.button_index=MOUSE_BUTTON_LEFT;up.pressed=false;Input.parse_input_event(up)
    await settle()
func click(id:String)->bool:
    var button:=node(id)
    if not verify(is_instance_valid(button) and button.is_visible_in_tree(),"visible control "+id):return false
    await click_at(button.get_global_rect().get_center());return true
func key(code:Key)->void:
    var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=true;Input.parse_input_event(event)
    await process_frame
    event=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=false;Input.parse_input_event(event)
    await settle()
func wait_ready()->void:
    var limit:=Time.get_ticks_msec()+9000
    while (host.busy or host.campaign.opening) and Time.get_ticks_msec()<limit:await process_frame
    await settle(.4)
func shot(label:String)->void:
    if DisplayServer.get_name()=="headless":return
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(evidence+label+".png")
func travel(place:String)->bool:
    if host.campaign.at(place):return true
    if is_instance_valid(host.modal):await key(KEY_ESCAPE)
    await key(KEY_M)
    if not await click("Map_"+place):return false
    await wait_ready()
    if place=="post_office":await key(KEY_E);await wait_ready()
    return verify(host.campaign.at(place),"map arrives at "+place)
func open_current()->bool:
    var current:Dictionary=host.campaign.journey.current_step()
    if not await travel(str(current.place)):return false
    if not is_instance_valid(host.modal):
        await key(KEY_B)
        if not await click("CampaignNext"):return false
    await settle(.4)
    return true
func drag_piece(id:String,destination:Vector2)->void:
    var source:Vector2=node("Pack_"+id).get_global_rect().get_center()
    var down:=InputEventMouseButton.new();down.position=source;down.global_position=source;down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;Input.parse_input_event(down)
    await process_frame
    var move:=InputEventMouseMotion.new();move.position=destination;move.global_position=destination;move.button_mask=MOUSE_BUTTON_MASK_LEFT;Input.parse_input_event(move)
    await process_frame
    var up:=InputEventMouseButton.new();up.position=destination;up.global_position=destination;up.button_index=MOUSE_BUTTON_LEFT;up.pressed=false;Input.parse_input_event(up)
    await settle()
func run()->void:
    root.unfocusable=true;root.size=Vector2i(1600,900);root.content_scale_size=Vector2i(1600,900)
    root.title="Dear Somewhere five-day route QA"
    DirAccess.make_dir_recursive_absolute(evidence)
    host=Host.new();root.add_child(host);host.size=Vector2(1600,900)
    var stamp:=str(Time.get_ticks_usec())
    host.core.save_path="user://qa/five-day-input/"+stamp+"/legacy.json"
    host.campaign.journey.path="user://qa/five-day-input/"+stamp+"/campaign.json"
    host.preferences.path="user://qa/five-day-input/"+stamp+"/preferences.json"
    host.preferences.values.text_speed="instant"
    await settle(.3)
    await click("NewShift");await wait_ready()
    await shot("arrival")
    # New journeys open directly in the supplied postal interior. Keep the
    # legacy branch so archived fixtures with the old prologue remain readable.
    if node("PrologueSkip")!=null:
        await click("PrologueSkip");await wait_ready()
    var rounds:=0
    while not host.campaign.journey.state.finished and rounds<155 and errors.is_empty():
        rounds+=1
        var journey=host.campaign.journey
        if journey.day_complete():
            if not await travel("post_office"):break
            # The second floor is reached through the postal interior's right room.
            if host.post_office_room_index==0:
                var room:Node=host.stage.get_node("PostOfficeInterior")
                await click_at(room.next_arrow.get_global_rect().get_center());await settle(.6)
            await click("AtticEntry");await wait_ready()
            for i in journey.catalog.nights[int(journey.state.day)-1].objects.size():
                if not await click("AtticObject_"+str(i)):break
                await click("SheetAction_0");await settle()
            await shot("night_"+str(journey.state.day))
            var day:int=journey.state.day
            await click("CampaignSleep");await wait_ready()
            if not verify(int(journey.state.day)==day+1,"bed moves to next day"):break
            continue
        var token:String=journey.token()
        var current:Dictionary=journey.current_step()
        print("ROUTE "+token+" "+str(current.kind)+" "+str(current.place))
        if not await open_current():break
        var kind:String=current.kind
        if not screenshot_events.has(kind):await shot("mode_"+kind);screenshot_events[kind]=true
        match kind:
            "talk":
                var attempts:=0
                while journey.token()==token and attempts<80:
                    attempts+=1;await click("AdvanceDialogue");await settle(.3)
            "read","inspect":
                for page in current.pages.size()-1:await click("PageNext")
                await click("CampaignFinish")
            "choice","sort":
                var chosen:String=current.get("correct",current.options[0].id)
                if token.begins_with("cat_letter:"):chosen="open"
                if token=="old_quarrel:2":chosen="edit"
                await click("Choice_"+chosen)
            "sequence":
                for action in current.actions:await click("SequenceAction")
                await click("CampaignFinish")
            "order":
                for i in current.actions.size():await click("Order_"+str(i))
                await click("CampaignFinish")
            "cook":
                for i in 3:await click("Ingredient_"+str(i))
                for action in current.actions:await click("CookAction")
                await click("CampaignFinish")
            "pack":
                var positions:Dictionary={"cv":[0,0],"portfolio":[2,0],"attachments":[5,0],"bone":[0,0],"toy":[3,0],"frame":[0,1]}
                for item:Dictionary in current.items:
                    var piece:=node("Pack_"+str(item.id))
                    # Select via press near the uncovered top edge, never through overlapping tray pieces.
                    var start:Vector2=piece.global_position+Vector2(20,15)
                    var down:=InputEventMouseButton.new();down.position=start;down.global_position=start;down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;Input.parse_input_event(down)
                    await process_frame
                    var destination:Vector2=node("PackingBox").global_position+Vector2(positions[item.id][0],positions[item.id][1])*70+Vector2(20,15)
                    var move:=InputEventMouseMotion.new();move.position=destination;move.global_position=destination;move.button_mask=MOUSE_BUTTON_MASK_LEFT;Input.parse_input_event(move)
                    await process_frame
                    var up:=InputEventMouseButton.new();up.position=destination;up.global_position=destination;up.button_index=MOUSE_BUTTON_LEFT;Input.parse_input_event(up)
                    await settle()
                await shot("packed_"+journey.current_id())
                await click("CampaignFinish")
            "strike":await click("Sentence_0");await click("CampaignFinish")
            "sound":await click("CampaignFinish")
            "listen":await click("ListenToggle");await settle(float(current.seconds)+.4);await click("CampaignFinish")
            "write":
                await click_at(node("LetterText").get_global_rect().get_center())
                for character:String in "Dear Somewhere, I will keep walking.":
                    var event:=InputEventKey.new();event.pressed=true;event.unicode=character.unicode_at(0);Input.parse_input_event(event)
                    await process_frame
                await click("CampaignFinish")
        await settle(.4)
        if not verify(journey.token()!=token,"input completes "+token):
            await shot("failure_"+token.replace(":","_"));break
        # Inspect the stored step after every interaction, without changing live state.
        var resumed=load("res://scripts/campaign/five_day_state.gd").new();resumed.path=journey.path
        verify(resumed.load_journey() and resumed.token()==journey.token(),"stored continuation "+token)
    verify(host.campaign.journey.state.finished,"full input route reaches Dear Somewhere")
    await shot("ending")
    verify(not FileAccess.file_exists(host.core.save_path),"campaign did not overwrite legacy exploration save")
    print("FIVE_DAY_INPUT checks=%d failures=%d"%[checks,errors.size()])
    host.queue_free();await process_frame;await process_frame
    quit(0 if errors.is_empty() else 1)
