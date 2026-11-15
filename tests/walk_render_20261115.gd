extends SceneTree
const Walker=preload("res://scripts/rebuild/final_walker.gd")
var failures:Array[String]=[]
var checks:=0
var out:="user://qa/walk-render-20261115"
func _initialize():
	for argument:String in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):out=argument.trim_prefix("--out=")
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures.append(label);push_error(label)
func shot(w:Control,seconds:float)->Image:
	w._walk_time=seconds;w.queue_redraw()
	await process_frame;await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func difference(a:Image,b:Image)->float:
	var total:=0.0
	for y in range(90,460,2):
		for x in range(100,460,2):
			var p:=a.get_pixel(x,y);var q:=b.get_pixel(x,y)
			total+=absf(p.r-q.r)+absf(p.g-q.g)+absf(p.b-q.b)
	return total
func run():
	root.unfocusable=true;root.size=Vector2i(640,480);root.content_scale_size=Vector2i(640,480)
	root.transparent_bg=true
	var w:=Walker.new();root.add_child(w);w.set_process(false)
	w.configure(null,Rect2(0,0,640,480),Vector2(360,455));w.actor_height=350
	w.set_process(false)
	w._turn_position=0.0;w._was_in_motion=true
	var first:Image=await shot(w,0.0)
	var mid:Image=await shot(w,1.0/24.0)
	var last:Image=await shot(w,1.0/12.0)
	check(w.material==w._walk_material,"normal walk route uses the new material")
	check(difference(first,mid)<0.01,"mid-frame retains one crisp painted silhouette without ghost outlines")
	check(difference(mid,last)>2,"a new source pose is visible after 1/12 second")
	var overlap:=0;var translucent:=0
	for y in range(90,460,2):
		for x in range(100,460,2):
			if first.get_pixel(x,y).a>.99 and last.get_pixel(x,y).a>.99:
				overlap+=1
				if mid.get_pixel(x,y).a<.98:translucent+=1
	check(overlap>500 and translucent==0,"body stays opaque between pose changes")
	w._turn_position=1.0;w.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
	check(w.material==w._portrait_material,"standing returns to preserved portrait material")
	if DirAccess.make_dir_recursive_absolute(out)!=OK:
		failures.append("Cannot create rendering evidence directory")
	for entry:Array in [["first",first],["mid",mid],["last",last]]:
		if entry[1].save_png(out+"/"+entry[0]+".png")!=OK:failures.append("Cannot save "+entry[0])
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"opaque_overlap_pixels":overlap}))
	print("WALK_RENDER ",checks," / ",failures.size()," overlap=",overlap)
	w.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
