extends "res://tests/five_day_playthrough.gd"
## Isolated checkpoint fixtures for close/resume, time-of-day, floor topology and chess.
func seed_until(event_id:String)->void:
    host._close()
    var journey=host.campaign.journey
    journey.new_journey();journey.state.intro_seen=true
    var guard:=0
    while journey.current_id()!=event_id and guard<150:
        guard+=1
        if journey.day_complete():
            for i in journey.catalog.nights[int(journey.state.day)-1].objects.size():journey.inspect_attic(i)
            journey.sleep();continue
        var current:Dictionary=journey.current_step()
        var error:String=journey.submit(journey.token(),Solutions.solve(current),current.place)
        if not verify(error.is_empty(),"fixture checkpoint "+journey.token()):break
    host.campaign.sync_time()
func run()->void:
    root.unfocusable=true;root.size=Vector2i(1600,900);root.content_scale_size=Vector2i(1600,900)
    root.title="Dear Somewhere experience fixture QA"
    DirAccess.make_dir_recursive_absolute(evidence)
    host=Host.new();root.add_child(host);host.size=Vector2(1600,900)
    var stamp:=str(Time.get_ticks_usec())
    host.core.save_path="user://qa/five-day-experience/"+stamp+"/legacy.json"
    host.campaign.journey.path="user://qa/five-day-experience/"+stamp+"/campaign.json"
    host.preferences.path="user://qa/five-day-experience/"+stamp+"/preferences.json"
    await settle()
    await click("NewShift");await wait_ready()
    verify(host.view=="post_office_room" and host.modal!=null and host.modal.name=="CampaignConversation","loading ends inside postal office with Mossner conversation")
    var token:String=host.campaign.journey.token()
    await key(KEY_ESCAPE)
    verify(host.campaign.journey.token()==token,"closing conversation does not deliver mail")
    await key(KEY_B);await click("CampaignNext")
    while host.campaign.journey.token()==token:await click("AdvanceDialogue");await settle(.3)
    await click("PageNext");await key(KEY_ESCAPE)
    host._save_to_title();await settle();await click("ContinueShift");await wait_ready()
    await key(KEY_B);await click("CampaignNext")
    verify(host.modal.answer.get("page")==1,"read page restores through title and Continue")
    await key(KEY_ESCAPE)
    seed_until("music_found")
    host.core.state.location="chess_stall";host._world("chess_stall");await settle(.5)
    verify(int(host.core.state.minute)>=1185,"first music investigation is at night")
    verify(absf(host._street_road.display_minute-float(host.core.state.minute))<1,"street uses narrative night clock")
    await shot("first_evening_street")
    var before:int=host.core.state.minute;await settle(.5)
    verify(host.core.state.minute==before,"idle exploration has no time pressure")
    seed_until("returned_mayor")
    host._post_office_room(1);await settle()
    verify(int(host.core.state.minute)==540,"next day starts in morning")
    await click("AtticEntry");await wait_ready()
    verify(host.view=="postal_loft","stairs lead to actual second-floor view")
    await click("CampaignSleep")
    verify(int(host.campaign.journey.state.day)==2,"cannot sleep past unfinished work")
    host._save_to_title();await settle();await click("ContinueShift");await wait_ready()
    verify(host.view=="postal_loft","Continue restores second floor")
    await click("LoftDownstairs");await wait_ready()
    verify(host.view=="post_office_room" and host.post_office_room_index==1,"stairs return to postal right room")
    host.core.state.location="chess_stall";host._world("chess_stall");await settle()
    await click("ArthurChess");await settle(1)
    await click("Chess_4_4");await settle(.7)
    verify(host.modal.moves.size()==2,"Arthur places a legal answering stone")
    await shot("arthur_chess")
    await key(KEY_ESCAPE);await click("ArthurChess");await settle(1)
    verify(host.modal.moves.size()==2,"unfinished chess game survives close")
    var board=host.modal
    board.grid={Vector2i(0,0):1,Vector2i(1,0):1,Vector2i(2,0):1,Vector2i(3,0):1}
    verify(board._score(Vector2i(4,0),1)==100000,"opponent detects immediate five-in-row threat")
    await key(KEY_ESCAPE)
    seed_until("somewhere")
    host._post_office_room(1);host.campaign.open_current();await settle()
    host.modal.editor.text="写到一半，明天再接着写。";host.modal.editor.text_changed.emit()
    await key(KEY_ESCAPE);host._save_to_title();await settle();await click("ContinueShift");await wait_ready()
    await key(KEY_B);await click("CampaignNext")
    verify(host.modal.editor.text=="写到一半，明天再接着写。","unsent letter draft survives Continue")
    verify(not host.campaign.journey.state.finished,"draft is not a posted letter")
    await key(KEY_ESCAPE)
    print("FIVE_DAY_EXPERIENCE checks=%d failures=%d"%[checks,errors.size()])
    host.queue_free();await process_frame;await process_frame
    quit(0 if errors.is_empty() else 1)
