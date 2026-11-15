extends RefCounted
## One restrained material language for the existing paper surfaces.
const MOTION := &"paper_presentation_motion"

static func cancel(surface:Control)->void:
	if not is_instance_valid(surface) or not surface.has_meta(MOTION):return
	var previous:Tween=surface.get_meta(MOTION)
	if previous!=null and previous.is_valid():previous.kill()
	surface.remove_meta(MOTION)

static func fade_in(surface:Control)->void:
	if not is_instance_valid(surface) or not surface.is_inside_tree():return
	cancel(surface)
	surface.modulate.a=0.0
	var motion:=surface.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	surface.set_meta(MOTION,motion)
	motion.tween_property(surface,"modulate:a",1.0,.16)

static func leave(surface:Control,finished:Callable)->void:
	if not is_instance_valid(surface) or not surface.is_inside_tree():return
	cancel(surface)
	var motion:=surface.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	surface.set_meta(MOTION,motion)
	surface.pivot_offset=surface.size*.5
	motion.tween_property(surface,"modulate:a",0.0,.12)
	motion.tween_property(surface,"scale",Vector2.ONE*.994,.12)
	motion.chain().tween_callback(finished)

static func enter(surface:Control)->void:
	if not is_instance_valid(surface):return
	cancel(surface)
	surface.pivot_offset=surface.size*.5
	surface.scale=Vector2.ONE*.978
	surface.modulate.a=0.0
	var motion:=surface.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	surface.set_meta(MOTION,motion)
	motion.tween_property(surface,"scale",Vector2.ONE,.24)
	motion.tween_property(surface,"modulate:a",1.0,.18)

static func backing(color:Color)->StyleBoxFlat:
	var paper:=StyleBoxFlat.new()
	paper.bg_color=color
	paper.border_color=Color("dbcfb7")
	paper.set_border_width_all(1)
	paper.border_width_bottom=2
	paper.set_corner_radius_all(3)
	paper.shadow_color=Color(.12,.16,.15,.22)
	paper.shadow_size=18
	paper.shadow_offset=Vector2(0,9)
	return paper
