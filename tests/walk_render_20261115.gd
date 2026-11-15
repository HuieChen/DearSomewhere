extends SceneTree
const Walker=preload("res://scripts/rebuild/final_walker.gd")
var failures:Array[String]=[]
var checks:=0
var contacts:Dictionary={}
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
func planted_boot_x(picture:Image,w:Control)->float:
	var points:Array[Vector2i]=[]
	var bottom:=0
	for y in range(int(w.foot.y-w.actor_height*.3),mini(picture.get_height(),int(w.foot.y)+1)):
		for x in range(100,460):
			var p:=picture.get_pixel(x,y)
			if p.a>.95 and p.r<.23 and p.g<.23 and p.b<.16:
				points.append(Vector2i(x,y));bottom=maxi(bottom,y)
	var sum:=0.0;var count:=0
	for p in points:
		if p.y>=bottom-maxi(1,roundi(16.0*w.actor_height/1830.0)):sum+=p.x;count+=1
	return sum/maxi(count,1) if count>0 else -1000.0
func run():
	root.unfocusable=true;root.size=Vector2i(640,480);root.content_scale_size=Vector2i(640,480)
	root.transparent_bg=true
	var w:=Walker.new();root.add_child(w);w.set_process(false)
	w.configure(null,Rect2(0,0,640,480),Vector2(360,455));w.actor_height=350
	w.set_process(false)
	w._turn_position=0.0;w._was_in_motion=true
	var first:Image=await shot(w,0.0)
	var mid:Image=await shot(w,1.0/12.0)
	var last:Image=await shot(w,1.0/6.0)
	check(w.material==w._walk_material,"normal walk route uses the new material")
	check(difference(first,mid)>2,"upper body moves between source poses instead of holding then jumping")
	check(difference(mid,last)>2,"next source phase displays a new original pose")
	var overlap:=0;var opaque_mid:=0;var feet_changed:=0
	for y in range(90,460,2):
		for x in range(100,460,2):
			if first.get_pixel(x,y).a>.98:overlap+=1
			if mid.get_pixel(x,y).a>.98:opaque_mid+=1
			if y>395 and first.get_pixel(x,y)!=mid.get_pixel(x,y):feet_changed+=1
	check(overlap>500 and absf(float(opaque_mid-overlap))/overlap<.03,"moving upper body retains its solid area rather than crossfade transparency")
	check(feet_changed==0,"upper-body smoothing leaves the planted boot pixels unchanged")
	var registration:Dictionary=Walker._runtime_registration()
	var cleared:=0;var residue:=0
	for index in range(12):
		var record:Dictionary=registration.get("walk_%02d.png"%index,{})
		var prepared:Image=w._poses["supplied_walk_%02d"%index].get_image()
		for span:Array in record.get("clear_spans",[]):
			for x in range(int(span[0]),int(span[0])+int(span[2])):
				cleared+=1
				if prepared.get_pixel(x,int(span[1])).a>0.0:residue+=1
	check(registration.size()==12 and cleared>500 and residue==0,"all measured detached matte remnants are transparent in runtime textures")
	w._turn_position=1.0;w.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
	check(w.material==w._portrait_material,"standing returns to preserved portrait material")
	if DirAccess.make_dir_recursive_absolute(out)!=OK:
		failures.append("Cannot create rendering evidence directory")
	for entry:Array in [["first",first],["mid",mid],["last",last]]:
		if entry[1].save_png(out+"/"+entry[0]+".png")!=OK:failures.append("Cannot save "+entry[0])
	# Measure the actual rendered supporting boot against a fixed world point,
	# across the source's three dark-boot stance poses and both game sizes.
	w._turn_position=0.0
	for height:float in [156.0,295.0]:
		w.actor_height=height;w.foot=Vector2(280,455);w._walk_time=0.0
		var planted:Array[float]=[]
		for index in range(3):
			var pose:Image=await shot(w,w._walk_time)
			planted.append(planted_boot_x(pose,w))
			var travel:float=w._walk_cycle_distance()/12.0
			w.foot.x+=travel;w._advance_phase(travel)
		# A two-pixel antialiased sole changes its measured centroid as its
		# footprint narrows. Budget four screen pixels at either display scale.
		check(planted.min()>0 and planted.max()-planted.min()<4.0,"rendered supporting boot drifts less than 4px across stance poses at height "+str(height)+": "+str(planted))
		contacts[str(height)]=planted
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"opaque_overlap_pixels":overlap,"rendered_contact_x":contacts}))
	print("WALK_RENDER ",checks," / ",failures.size()," overlap=",overlap)
	w.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
