extends Control
## A short, skippable arrival using the existing town, courier and authored envelope.
signal finished
const UI=preload("res://scripts/ui/paper_ui.gd")
var host:Control
var caption:Label
var turn:=0
var next:Button
var letter:TextureRect
var motion:Tween
var closing:=false
var seconds:=0.0
func configure(value:Control)->void:
    host=value;name="ArrivalPrologue";z_index=30
    var top:=ColorRect.new();top.color=Color(.12,.17,.19,.08);top.mouse_filter=MOUSE_FILTER_IGNORE;UI.place(top,self,Rect2(0,0,1600,100))
    var paper:=UI.panel(self,Rect2(300,710,1000,120),Color("faf3e5"));paper.modulate.a=.94
    caption=UI.label(paper,"外婆去世后，Anne 回到了 Solmere。",Rect2(40,20,910,72),29,Color("435b57"))
    var skip:=UI.button(self,"跳过",Rect2(1390,45,130,50),finish);skip.name="PrologueSkip"
    next=UI.button(self,"继续 →",Rect2(1305,765,220,62),advance);next.name="PrologueNext"
    letter=UI.texture(self,"",Rect2(560,310,480,300));letter.texture=preload("res://scripts/campaign/campaign_art.gd").texture("envelope")
    letter.modulate.a=0.0;letter.pivot_offset=letter.size*.5
    host.sound.set_location("post_office",540,false)
    if is_instance_valid(host.walker):host.walker.manual_enabled=false
    _fade_caption()
func _fade_caption()->void:
    caption.modulate.a=0.0
    motion=create_tween();motion.tween_property(caption,"modulate:a",1.0,.7)
    next.disabled=true;seconds=0.0
func _process(delta:float)->void:
    seconds+=delta
    if is_instance_valid(next):next.disabled=seconds<.8
func advance()->void:
    if closing:return
    turn+=1;host.sound.play("flip")
    match turn:
        1:
            caption.text="她留下的邮局，还在每天开门。"
            var reveal:=create_tween().set_parallel(true)
            reveal.tween_property(letter,"modulate:a",1.0,1.0)
            letter.position.y=330;reveal.tween_property(letter,"position:y",310.0,1.0)
            _fade_caption()
        2:
            caption.text="Anne 还不知道会在这里待多久。"
            next.text="走进邮局 →";_fade_caption()
        _:finish()
func request_close()->void:finish()
func checkpoint_for_quit()->bool:return host.campaign.persist()
func finish()->void:
    if closing:return
    closing=true;finished.emit()
