extends Control
## Functional second floor, deliberately separate from replacement illustration.
## Geometry and hit areas share these rectangles; later art may replace the backdrop.
const UI=preload("res://scripts/ui/paper_ui.gd")
const BED=Rect2(1050,470,420,235)
const DESK=Rect2(150,585,650,170)
var controller:Node
var sound:Node
func configure(value:Node)->void:
    controller=value;sound=controller.host.sound;name="PostalSecondFloor"
    mouse_filter=MOUSE_FILTER_STOP
    UI.label(self,"邮局 · 二楼",Rect2(80,50,500,60),30,Color("5d6355"))
    var down:=UI.button(self,"↓ 一楼",Rect2(80,780,220,60),func():controller.host._change_scene(func():controller.host._post_office_room(1);controller.persist()))
    down.name="LoftDownstairs"
    var bed:=UI.button(self,"",BED,func():
        if controller.journey.can_sleep():controller._sleep()
        else:controller.host._say("先把今天的信和桌上的东西收好。"))
    bed.name="CampaignSleep";bed.tooltip_text="睡觉 · 明天再继续";_invisible(bed)
    UI.label(self,"休息",Rect2(1195,725,180,50),25,Color("5d6355"))
    var day:int=controller.journey.state.day
    var tonight:bool=controller.journey.day_complete()
    var index:int=day-1 if tonight else maxi(0,day-2)
    var objects:Array=controller.journey.catalog.nights[index].objects
    for i:int in objects.size():
        var object:Dictionary=objects[i]
        var rect:=Rect2(210+i*290,580,235,145)
        var button:=UI.button(self,str(object.title),rect,func():
            controller.host._sheet(str(object.title),str(object.text),[["放回原处",func():
                if tonight and not controller.journey.inspect_attic(i):controller.host._show_save_problem(controller.journey.last_error);return
                controller.host._close();queue_redraw()]]))
        button.name="AtticObject_"+str(i)
        button.rotation=-.035 if i==0 else .025
    queue_redraw()
func _invisible(button:Button)->void:
    for state:String in ["normal","hover","pressed","hover_pressed","focus"]:button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
func _draw()->void:
    var replacement:Texture2D=preload("res://scripts/campaign/campaign_art.gd").texture("loft_background")
    if replacement!=null:draw_texture_rect(replacement,Rect2(0,0,1600,900),false);return
    draw_rect(Rect2(0,0,1600,900),Color("f0e7d2"))
    draw_colored_polygon(PackedVector2Array([Vector2(0,0),Vector2(800,0),Vector2(0,450)]),Color("d4c4aa"))
    draw_colored_polygon(PackedVector2Array([Vector2(800,0),Vector2(1600,0),Vector2(1600,450)]),Color("ded1b9"))
    draw_rect(Rect2(0,740,1600,160),Color("c6b298"))
    for y in range(770,900,50):draw_line(Vector2(0,y),Vector2(1600,y),Color("bba58b"),2)
    # A quiet night window makes upstairs spatially different from the shop.
    var night:bool=controller==null or int(controller.host.core.state.minute)>=1140
    draw_style_box(UI.style(Color("9ba6ba") if night else Color("acd6de"),Color("ac9d88"),70),Rect2(670,180,265,290))
    if night:draw_circle(Vector2(850,245),25,Color("f7edc7"))
    draw_line(Vector2(802,190),Vector2(802,455),Color("d8c9ad"),12)
    draw_line(Vector2(685,325),Vector2(920,325),Color("d8c9ad"),12)
    draw_style_box(UI.style(Color("bda58a"),Color.TRANSPARENT,18),BED.grow(12))
    draw_style_box(UI.style(Color("d8e2d3"),Color.TRANSPARENT,25),BED)
    draw_style_box(UI.style(Color("faf0d9"),Color.TRANSPARENT,24),Rect2(1080,490,120,175))
    draw_style_box(UI.style(Color("97b5ad"),Color.TRANSPARENT,20),Rect2(1220,470,250,235))
    draw_rect(Rect2(1100,705,25,60),Color("a38c71"));draw_rect(Rect2(1410,705,25,60),Color("a38c71"))
    draw_style_box(UI.style(Color("b39171"),Color.TRANSPARENT,12),DESK)
    draw_rect(Rect2(185,745,27,85),Color("a38c71"));draw_rect(Rect2(737,745,27,85),Color("a38c71"))
    draw_circle(Vector2(110,570),31,Color("efd9a4"))
    draw_line(Vector2(110,600),Vector2(110,715),Color("bca582"),7)
