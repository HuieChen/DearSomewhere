extends SceneTree
const Walker=preload("res://scripts/rebuild/final_walker.gd")
var out:="user://qa/walk-native-alpha"
var failures:Array[String]=[]
func _initialize():
	for arg:String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):out=arg.trim_prefix("--out=")
	run.call_deferred()
func run():
	root.unfocusable=true;root.size=Vector2i(1200,1200)
	root.content_scale_size=root.size
	DirAccess.make_dir_recursive_absolute(out)
	var bg:=ColorRect.new();bg.size=Vector2(1200,1200);root.add_child(bg)
	var actors:Array[Control]=[]
	var checked:=0
	for i in range(12):
		var w:=Walker.new();root.add_child(w);w.set_process(false)
		w.configure(null,Rect2(0,0,1200,1200),Vector2(150+(i%4)*300,390+(i/4)*400))
		w.set_process(false);w.actor_height=340;w._turn_position=0.0
		w._walk_time=float(i)/6.0;w._was_in_motion=true
		actors.append(w)
		var path:="res://assets/authoring/courier_walk_20261110/walk_%02d.png"%i
		var original:=Image.load_from_file(path)
		var prepared:Image=w._poses["supplied_walk_%02d"%i].get_image()
		var edges:=0;var darkened:=0
		for y in range(0,1100,3):
			for x in range(0,1200,3):
				var p:=original.get_pixel(x,y);var q:=prepared.get_pixel(x,y)
				if p.a>.1 and p.a<.9 and q.a>0:
					edges+=1
					if absf(p.r-q.r)>.008 or absf(p.g-q.g)>.008 or absf(p.b-q.b)>.008:darkened+=1
		if edges<100 or darkened>0:failures.append("native edge colour changed: "+str(i))
		checked+=edges
	for facing:float in [-1.0,1.0]:
		for colour:Color in [Color("f7f0df"),Color("c5b49a")]:
			bg.color=colour
			for w:Control in actors:w._facing=facing;w.queue_redraw()
			await process_frame;await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out+"/poses_"+str(int(facing))+"_"+colour.to_html(false)+".png")
	print("NATIVE_ALPHA 12 frames, ",checked," edge samples, ",failures.size()," failures")
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"frames":12,"edge_samples":checked,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
