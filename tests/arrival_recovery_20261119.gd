extends "res://tests/five_day_playthrough.gd"
## New journeys enter the authored postal interior without a staged opening.
func run()->void:
    root.unfocusable=true;root.size=Vector2i(1600,900);root.content_scale_size=Vector2i(1600,900)
    host=Host.new();root.add_child(host);host.size=Vector2(1600,900)
    var base:="user://qa/arrival-recovery/"+str(Time.get_ticks_usec())+"/"
    host.core.save_path=base+"legacy.json"
    host.campaign.journey.path=base+"campaign.json"
    host.preferences.path=base+"preferences.json"
    await settle()
    await click("NewShift");await wait_ready()
    verify(host.view=="post_office_room","new journey opens the supplied postal interior")
    verify(host.campaign.journey.state.intro_seen,"direct arrival checkpoints before play")
    verify(host.modal==null or host.modal.name!="ArrivalPrologue","new journey does not mount the opening animation")
    verify(host.campaign.journey.token()=="grandmother:0","direct arrival leaves the first authored task pending")
    await settle(.4)
    verify(host.modal!=null and host.modal.name=="CampaignConversation","Mossner conversation opens after the postal scene loads")
    host._close();host._save_to_title();await settle()
    await click("ContinueShift");await wait_ready()
    verify(host.view=="post_office_room","continue restores the postal interior")
    verify(host.campaign.journey.state.intro_seen,"continue keeps the direct-arrival checkpoint")
    verify(not is_instance_valid(host.modal),"continue never restores an opening overlay")
    print("ARRIVAL_RECOVERY checks=%d failures=%d"%[checks,errors.size()])
    host.sound.shutdown();host.queue_free();await process_frame;await process_frame
    quit(0 if errors.is_empty() else 1)
