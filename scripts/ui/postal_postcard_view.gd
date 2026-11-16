extends Control
## Lift the original card into view and return it to the same shelf position.
signal closed
signal cue(kind:String)
const UI=preload("res://scripts/ui/paper_ui.gd")
const Rack=preload("res://scripts/rebuild/postal_postcard_rack.gd")
var card:Dictionary={}
var origin:=Rect2()
var locale:="zh"
var leaving:=false
var opening:=true
var face:Texture2D
var put_back:Button
var close_button:Button
var _motion:Tween
var _shade:=0.0:
	set(value):_shade=value;queue_redraw()
var presented_rect:=Rect2():
	set(value):presented_rect=value;queue_redraw()

func _ready():
	name="PostcardInspection";z_index=120;mouse_filter=Control.MOUSE_FILTER_STOP
	size=Vector2(1600,900)
	face=Rack.texture(str(card.face))
	var dimensions:=face.get_size()
	dimensions*=minf(620.0/dimensions.x,560.0/dimensions.y)
	var destination:=Rect2(Vector2(800,415)-dimensions*.5,dimensions)
	presented_rect=origin
	put_back=UI.button(self,"放回" if locale=="zh" else "Put back",Rect2(728,destination.end.y+30,144,52),func():request_close(false))
	put_back.name="PutPostcardBack"
	close_button=UI.button(self,"×",Rect2(destination.end.x+24,destination.position.y,54,54),func():request_close(false))
	close_button.name="ClosePostcard"
	put_back.modulate.a=0;close_button.modulate.a=0
	_motion=create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_motion.tween_property(self,"presented_rect",destination,.28)
	_motion.tween_property(self,"_shade",1.0,.2)
	_motion.tween_property(put_back,"modulate:a",1.0,.18)
	_motion.tween_property(close_button,"modulate:a",1.0,.18)
	_motion.chain().tween_callback(func():opening=false)
	put_back.grab_focus.call_deferred()

func _draw():
	draw_rect(Rect2(Vector2.ZERO,size),Color(.12,.15,.14,.38*_shade))
	if face!=null:
		draw_texture_rect(face,Rect2(presented_rect.position+Vector2(6,12)*_shade,presented_rect.size),false,Color(0,0,0,.22*_shade))
		draw_texture_rect(face,presented_rect,false)

func request_close(feedback:bool=true):
	if leaving:return
	leaving=true
	if _motion!=null and _motion.is_valid():_motion.kill()
	put_back.disabled=true;close_button.disabled=true
	if feedback:cue.emit("paper")
	_motion=create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_motion.tween_property(self,"presented_rect",origin,.23)
	_motion.tween_property(self,"_shade",0.0,.23)
	_motion.tween_property(put_back,"modulate:a",0.0,.1)
	_motion.tween_property(close_button,"modulate:a",0.0,.1)
	_motion.chain().tween_callback(func():closed.emit())

func _gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed and not opening:
		if not presented_rect.has_point(event.position):request_close()
		accept_event()

func _exit_tree():
	if _motion!=null and _motion.is_valid():_motion.kill()
