extends "res://tests/five_day_playthrough.gd"
## Interrupted arrival and failed writes use isolated user data only.
func run()->void:
    root.unfocusable=true;root.size=Vector2i(1600,900);root.content_scale_size=Vector2i(1600,900)
    host=Host.new();root.add_child(host);host.size=Vector2(1600,900)
    var base:="user://qa/arrival-recovery/"+str(Time.get_ticks_usec())+"/"
    host.core.save_path=base+"legacy.json"
    host.campaign.journey.path=base+"campaign.json"
    host.preferences.path=base+"preferences.json"
    await settle()
    await click("NewShift");await wait_ready()
    var token:String=host.campaign.journey.token()
    for page in range(3):
        verify(host.modal.turn==page,"arrival page before checkpoint "+str(page))
        host._save_to_title();await settle()
        await click("ContinueShift");await wait_ready()
        verify(host.modal.name=="ArrivalPrologue","Continue restores arrival "+str(page))
        verify(host.modal.turn==page,"Continue retains exact beat "+str(page))
        verify(host.campaign.journey.token()==token,"arrival never advances letter task")
        if page>0:verify(host.modal.letter.modulate.a==1.0,"restored envelope is visible")
        await settle(1)
        if page<2:
            await click("PrologueNext")
            var before:int=host.modal.turn
            host.modal.advance()
            verify(host.modal.turn==before,"rapid repeat cannot skip a beat")
            await settle(1)
    var good_path:String=host.campaign.journey.path
    var blocked:=base+"blocked"
    FileAccess.open(blocked,FileAccess.WRITE).store_string("failure fixture")
    host.campaign.journey.path=blocked+"/campaign.json"
    await click("PrologueNext")
    verify(host.modal.name=="ArrivalPrologue" and not host.modal.closing,"failed save retains retryable opening")
    verify(not host.campaign.journey.state.intro_seen,"failed save does not mark opening complete")
    verify(not host.modal.save_notice.text.is_empty(),"failure gives an inline explanation")
    host.campaign.journey.path=good_path
    await click("PrologueNext");await wait_ready()
    verify(host.view=="post_office_room","retry enters real postal interior")
    verify(host.campaign.journey.state.intro_seen,"successful retry marks opening complete")
    verify(host.campaign.journey.token()==token,"retry leaves first conversation pending")
    host._close();host._save_to_title();await settle()
    await click("ContinueShift");await wait_ready()
    verify(host.modal==null or host.modal.name!="ArrivalPrologue","completed opening does not replay")
    print("ARRIVAL_RECOVERY checks=%d failures=%d"%[checks,errors.size()])
    host.sound.shutdown();host.queue_free();await process_frame;await process_frame
    quit(0 if errors.is_empty() else 1)
