class_name TutorialCard
extends Control

const UI=preload("res://scripts/ui/paper_ui.gd")

var _step:Label
var _title:Label
var _body:Label
var _hint:Label
var _pulse:float=0.0

func _ready()->void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	var paper:=UI.panel(self,Rect2(0,0,560,166),Color("fff4df"))
	paper.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var rule:=ColorRect.new();rule.color=Color("bc8166");rule.mouse_filter=Control.MOUSE_FILTER_IGNORE;UI.place(rule,self,Rect2(0,0,7,166))
	_step=UI.label(self,"邮差手册",Rect2(28,16,120,25),15,Color("8b716a"))
	_title=UI.label(self,"",Rect2(28,40,500,34),24,UI.INK)
	_body=UI.label(self,"",Rect2(28,76,500,52),18,UI.INK)
	_hint=UI.label(self,"",Rect2(28,137,500,21),15,Color("6f8580"))
	process_mode=Node.PROCESS_MODE_ALWAYS
	set_process(true)

func configure(step:String,title:String,body:String,hint:String)->void:
	if _step==null:return
	_step.text=step
	_title.text=title
	_body.text=body
	_hint.text=hint
	queue_redraw()

func _process(delta:float)->void:
	_pulse+=delta
	queue_redraw()

func _draw()->void:
	var alpha:=0.28+0.18*(0.5+0.5*sin(_pulse*2.4))
	draw_circle(Vector2(538,24),4.5,Color(0.74,0.51,0.40,alpha))
	draw_line(Vector2(526,24),Vector2(532,24),Color(0.74,0.51,0.40,alpha),2.0,true)
