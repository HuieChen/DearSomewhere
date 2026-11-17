extends Control
## Optional untimed five-in-a-row. Opponent prioritizes wins, then blocks threats.
const UI=preload("res://scripts/ui/paper_ui.gd")
const AXES=[Vector2i(1,0),Vector2i(0,1),Vector2i(1,1),Vector2i(1,-1)]
const ORIGIN=Vector2(500,210)
const CELL=58.0
var controller:Node
var sound:Node
var moves:Array=[]
var grid:Dictionary={}
var result:=0
var thinking:=false
var caption:Label
func configure(value:Node)->void:
    controller=value;sound=controller.host.sound;name="ArthurBoard"
    var shade:=ColorRect.new();shade.color=Color(0.1,0.16,0.17,.25);UI.place(shade,self,Rect2(0,0,1600,900))
    UI.panel(self,Rect2(370,80,850,740),Color("f2e8cf"))
    UI.label(self,"树下 · 五子棋",Rect2(430,105,600,65),30)
    UI.button(self,"×",Rect2(1130,100,60,60),request_close)
    caption=UI.label(self,"",Rect2(440,732,610,55),23)
    UI.button(self,"再下一盘",Rect2(1030,730,160,55),_reset).name="ChessReset"
    moves=controller.journey.state.get("chess",[]).duplicate(true)
    _restore()
    for y in 9:
        for x in 9:
            var hit:=UI.button(self,"",Rect2(ORIGIN+Vector2(x,y)*CELL-Vector2.ONE*26,Vector2.ONE*52),_player.bind(Vector2i(x,y)))
            hit.name="Chess_%d_%d"%[x,y]
            for style:String in ["normal","hover","pressed","focus"]:hit.add_theme_stylebox_override(style,StyleBoxEmpty.new())
    if moves.size()%2==1 and result==0:_opponent.call_deferred()
    _refresh()
func _restore()->void:
    grid.clear();result=0
    for move:Array in moves:
        var point:=Vector2i(int(move[0]),int(move[1]));grid[point]=int(move[2])
        if _line(point,int(move[2]))>=5:result=int(move[2])
    if result==0 and grid.size()==81:result=3
func _line(point:Vector2i,side:int)->int:
    var best:=1
    for axis:Vector2i in AXES:
        var length:=1
        for direction in [-1,1]:
            for offset in range(1,5):
                if grid.get(point+axis*offset*direction,0)!=side:break
                length+=1
        best=maxi(best,length)
    return best
func _score(point:Vector2i,side:int)->int:
    grid[point]=side;var length:=_line(point,side);grid.erase(point)
    return [0,1,8,70,600,100000,100000,100000,100000,100000][mini(9,length)]
func _commit(point:Vector2i,side:int)->bool:
    moves.append([point.x,point.y,side]);controller.journey.state.chess=moves.duplicate(true)
    if not controller.persist():
        moves.pop_back();controller.journey.state.chess=moves.duplicate(true);caption.text=controller.journey.last_error;return false
    _restore();sound.play("wood");_refresh();return true
func _player(point:Vector2i)->void:
    if thinking or result!=0 or grid.has(point) or moves.size()%2!=0:return
    if _commit(point,1) and result==0:_opponent()
func _opponent()->void:
    thinking=true;_refresh()
    await get_tree().create_timer(.45).timeout
    if not is_inside_tree():return
    var best:=Vector2i(-1,-1);var best_score:=-1
    for y in 9:
        for x in 9:
            var point:=Vector2i(x,y)
            if grid.has(point):continue
            var value:=_score(point,2)*2+_score(point,1)+8-absi(x-4)-absi(y-4)
            if value>best_score:best_score=value;best=point
    if best.x>=0:_commit(best,2)
    thinking=false;_refresh()
func _refresh()->void:
    if is_instance_valid(caption):caption.text="Arthur 在想下一步。" if thinking else "轮到你 · 黑子先行，连成五子"
    if result==1:caption.text="你连成了五子。Arthur 点点头。"
    elif result==2:caption.text="Arthur 连成了五子。再下一盘也不迟。"
    elif result==3:caption.text="棋盘满了，这盘算和棋。"
    queue_redraw()
func _reset()->void:
    if thinking:return
    var previous:=moves.duplicate(true);moves=[];controller.journey.state.chess=[]
    if not controller.persist():moves=previous;controller.journey.state.chess=previous;return
    _restore();_refresh()
func request_close()->void:controller.host._close(true)
func _draw()->void:
    # Draw above the paper child using a separate top-level drawing item below.
    pass
func _ready()->void:
    var ink:=Node2D.new();ink.z_index=5;add_child(ink)
    ink.draw.connect(func():
        for i in 9:
            ink.draw_line(ORIGIN+Vector2(i*CELL,0),ORIGIN+Vector2(i*CELL,8*CELL),Color("ab9470"),1.5)
            ink.draw_line(ORIGIN+Vector2(0,i*CELL),ORIGIN+Vector2(8*CELL,i*CELL),Color("ab9470"),1.5)
        for point:Vector2i in grid:
            ink.draw_circle(ORIGIN+Vector2(point)*CELL+Vector2(2,3),22,Color(0,0,0,.12))
            ink.draw_circle(ORIGIN+Vector2(point)*CELL,21,Color("46524d") if grid[point]==1 else Color("fff9e9")))
    draw.connect(ink.queue_redraw)
