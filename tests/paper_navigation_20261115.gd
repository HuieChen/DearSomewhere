extends SceneTree
## Engine keyboard routing on isolated saves; native review remains separate.
const Host=preload("res://scripts/rebuild/final_playable.gd")
var game:Control
var checks:=0
var failures:Array[String]=[]
var out:="user://qa/paper-navigation"

func _initialize()->void:
	var isolated:=false
	for arg:String in OS.get_cmdline_user_args():
		if arg.begins_with("--final-save=user://qa/"):isolated=true
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	if not isolated:push_error("Isolated save required");quit(1);return
	create_timer(55).timeout.connect(func():push_error("Paper navigation timeout");quit(1))
	run.call_deferred()

func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures.append(label);push_error(label)

func key(code:Key)->void:
	for down:bool in [true,false]:
		var event:=InputEventKey.new();event.keycode=code;event.pressed=down
		root.push_input(event,true)

func settle()->void:await create_timer(.3).timeout

func run()->void:
	DirAccess.make_dir_recursive_absolute(out)
	root.unfocusable=true
	root.content_scale_size=Vector2i(1600,900)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	game=Host.new();game.allow_display_changes=false;root.add_child(game);game.size=Vector2(1600,900)
	game.core.new_game();game._post_office_room();await settle()
	for locale:String in ["zh","en"]:
		game.preferences.set_value("language",locale)
		game._bag_photos_visible=false
		root.size=Vector2i(1280,720) if locale=="zh" else Vector2i(1920,1080)
		var opener:Control=game.stage.find_child("OpenBag",true,false)
		game.stage.find_child("OpenCamera",true,false).grab_focus()
		key(KEY_B)
		check(is_instance_valid(game.modal) and game.modal.name=="MailBag",locale+" shortcut opens bag")
		await settle()
		check(is_equal_approx(game.modal.modulate.a,1.0),locale+" paper fully visible after entry")
		key(KEY_B)
		var closing_id:int=game.modal.get_instance_id()
		check(game._modal_dismissing_id==closing_id,locale+" paper owns input during dismissal")
		key(KEY_ESCAPE);key(KEY_ENTER)
		await settle()
		check(not is_instance_valid(game.modal),locale+" repeated keys do not reopen pause or bag")
		check(root.gui_get_focus_owner()==opener,locale+" keyboard opening restores matching tool")
		check(game.get_node_or_null("PaperDismissInputShield")==null,locale+" dismissal releases input shield")
		key(KEY_B);await settle();key(KEY_M);await settle()
		check(game.modal.name=="MapInspection",locale+" bag switches directly to map")
		check(game.modal.is_ancestor_of(root.gui_get_focus_owner()),locale+" focus stays in replacement map")
		key(KEY_M);await settle()
		check(not is_instance_valid(game.modal) and root.gui_get_focus_owner()==game.stage.find_child("OpenMap",true,false),locale+" map toggle returns to map opener")
		key(KEY_B);await settle()
		game._switch_bag_tab(true)
		check(is_equal_approx(game.modal.modulate.a,1.0),locale+" tab replacement does not flash backdrop")
		await settle()
		check(root.gui_get_focus_owner().name=="BagPhotosTab",locale+" rebuilt tab retains focus")
		game._dismiss_modal();game._map();await settle()
		check(game.modal.name=="MapInspection" and game._modal_dismissing_id==0,locale+" superseded close cannot remove replacement")
		check(game.get_node_or_null("PaperDismissInputShield")==null,locale+" replacement clears old input shield")
		game._close();await settle()
		game._pause();await settle();key(KEY_ENTER);key(KEY_ENTER);await settle()
		check(not is_instance_valid(game.modal),locale+" resume action runs once under rapid Enter")
		game._bag();await settle()
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(out.path_join(locale+"_bag.png"))==OK,locale+" rendered paper evidence")
		game._close();await settle()
	game.sound.shutdown();game.queue_free();await process_frame;await process_frame
	var report:={"checks":checks,"failures":failures,"method":"Offscreen OpenGL keyboard routing, isolated saves, bilingual layouts"}
	FileAccess.open(out.path_join("receipt.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("PAPER_NAVIGATION ",checks," checks / ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
