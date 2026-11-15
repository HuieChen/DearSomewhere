extends SceneTree
const Walker=preload("res://scripts/rebuild/final_walker.gd")
var out:="user://qa/continuous-footplant"
var failures:Array[String]=[]
var measurements:Dictionary={}
var checks:=0
func _initialize():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):out=arg.trim_prefix("--out=")
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures.append(label);push_error(label)
func sole(frame:Image,light:bool)->Vector2:
	var bottom:=-1
	var pixels:Array[Vector2i]=[]
	for y in range(350,465):
		for x in range(70,570):
			var c:=frame.get_pixel(x,y)
			var pigment:=c.r>.27 and c.r<.40 and absf(c.r-c.g)<.04 if light else c.r<.22 and c.g<.22
			if c.a>.95 and c.b<c.g*.85 and pigment:
				pixels.append(Vector2i(x,y));bottom=maxi(bottom,y)
	var sum:=0.0;var count:=0
	for p in pixels:
		if p.y>=bottom-1:sum+=p.x;count+=1
	return Vector2(sum/maxi(count,1),bottom) if count>0 else Vector2(-1000,-1000)
func run():
	DirAccess.make_dir_recursive_absolute(out)
	root.unfocusable=true;root.size=Vector2i(640,480);root.content_scale_size=root.size;root.transparent_bg=true
	var w:=Walker.new();root.add_child(w);w.set_process(false)
	w.configure(null,Rect2(0,0,640,480),Vector2(240,455));w.set_process(false)
	w._turn_position=0.0;w._was_in_motion=true
	for height:float in [156.0,295.0]:
		for facing:float in [-1.0,1.0]:
			w.actor_height=height;w._facing=facing
			for stride in range(3):
				var contacts:Array[Vector2]=[]
				var light_contacts:Array[Vector2]=[]
				var origin:float=0.0 if stride==0 else w._frame_ends[stride*4-1]
				for pose in range(4):
					var index:=stride*4+pose
					var start:float=0.0 if index==0 else w._frame_ends[index-1]
					for subframe in range(8):
						var time:float=lerpf(start,w._frame_ends[index],float(subframe)/8.0)
						w._walk_time=time
						w.foot=Vector2(320+facing*(time-origin)/w._cycle_seconds*w._walk_cycle_distance(),455)
						w.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
						var frame:=root.get_texture().get_image()
						var point:=sole(frame,pose==3)
						if pose==3:light_contacts.append(point)
						else:contacts.append(point)
						if height==295 and facing==1 and stride==0:
							frame.save_png(out+"/step_%02d.png"%(pose*8+subframe))
				for group:Array in [contacts,light_contacts]:
					var xs:Array[float]=[];var ys:Array[float]=[]
					for point:Vector2 in group:xs.append(point.x);ys.append(point.y)
					var key:="%s_%s_stride%d_%s"%[height,facing,stride,"dark" if group.size()==24 else "light"]
					measurements[key]={"x_range":xs.max()-xs.min(),"y_range":ys.max()-ys.min(),"x":xs,"y":ys}
					check(xs.min()>0 and xs.max()-xs.min()<=4.0 and ys.max()-ys.min()<=2.0,"continuous world-space sole stays planted: "+key+" "+str(measurements[key]))
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"measurements":measurements}))
	print("WALK_FOOTPLANT ",checks," / ",failures.size())
	w.queue_free();await process_frame;quit(0 if failures.is_empty() else 1)
