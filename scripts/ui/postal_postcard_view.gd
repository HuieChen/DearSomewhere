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
var card_image:TextureRect
var put_back:Button
var close_button:Button
var _motion:Tween
var _shade:=0.0:
	set(value):_shade=value;queue_redraw()
var presented_rect:=Rect2():
	set(value):
		presented_rect=value;queue_redraw()
		if is_instance_valid(card_image):card_image.position=value.position;card_image.size=value.size

func _ready():
	name="PostcardInspection";z_index=120;mouse_filter=Control.MOUSE_FILTER_STOP
	size=Vector2(1600,900)
	face=Rack.inspection_texture(str(card.face))
	card_image=TextureRect.new();card_image.name="OriginalCardFace";card_image.texture=face
	card_image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;card_image.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var clarity:=ShaderMaterial.new();clarity.shader=preload("res://scripts/ui/postcard_clarity.gdshader");clarity.set_shader_parameter("card_source",face)
	card_image.material=clarity;add_child(card_image)
	var dimensions:=face.get_size()
	# The supplied layers are 123–203 px wide. Avoid presenting them as huge
	# high-resolution artwork; the close-up still exceeds the shelf scale.
	dimensions*=minf(2.8,minf(500.0/dimensions.x,460.0/dimensions.y))
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
