extends RefCounted
## Versioned campaign beside the legacy exploration save. No global morality or
## irreversible failure: every document route remains completable.
const CATALOG = "res://data/campaign/five_days.json"
const FORMAT = "dear-somewhere-five-days"
var catalog:Dictionary = {}
var state:Dictionary = {}
var path := "user://final_v2/five_days.json"
var last_error := ""
var recovered_backup := false

func _init()->void:
    var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
    if parsed is Dictionary:catalog=parsed

func active()->bool:return not state.is_empty()
func new_journey()->bool:
    var previous:=state.duplicate(true)
    state={"format":FORMAT,"version":1,"day":1,"events":{},"flags":{},"evidence":{},"attic":{},"journal":[],"selected":"","finished":false,"location":"post_office","room":0}
    for event:Dictionary in catalog.events:
        state.events[event.id]={"step":0,"done":false,"work":{},"choices":{}}
    if save():return true
    state=previous
    return false

func event(id:String)->Dictionary:
    for entry:Dictionary in catalog.get("events",[]):
        if str(entry.id)==id:return entry
    return {}

func available(id:String)->bool:
    var item:=event(id)
    if not active() or item.is_empty() or int(item.day)>int(state.day):return false
    for dependency:String in item.get("after",[]):
        if not state.events.get(dependency,{}).get("done",false):return false
    return true

func current_id()->String:
    if not active():return ""
    var selected:=str(state.selected)
    if available(selected) and not state.events[selected].done:return selected
    for entry:Dictionary in catalog.events:
        if int(entry.day)==int(state.day) and not entry.get("optional",false) and available(entry.id) and not state.events[entry.id].done:return entry.id
    return ""

func current_step(id:String="")->Dictionary:
    if id.is_empty():id=current_id()
    if not available(id) or state.events[id].done:return {}
    var item:=event(id)
    var index:=int(state.events[id].step)
    if index>=item.steps.size():return {}
    return item.steps[index].duplicate(true)

func token(id:String="")->String:
    if id.is_empty():id=current_id()
    return id+":"+str(int(state.events.get(id,{}).get("step",-1)))

func select(id:String)->bool:
    if not available(id) or state.events[id].done:return false
    var previous:=str(state.selected);state.selected=id
    if save():return true
    state.selected=previous;return false

func work(id:String)->Dictionary:
    return state.events[id].work.get(str(int(state.events[id].step)),{}).duplicate(true)

func remember(id:String,key:String,value:Variant)->bool:
    if not available(id) or state.events[id].done:return false
    var before:=state.duplicate(true)
    var index:=str(int(state.events[id].step))
    if not state.events[id].work.has(index):state.events[id].work[index]={}
    state.events[id].work[index][key]=value
    if save():return true
    state=before;return false

func submit(expected_token:String,answer:Dictionary,place:String)->String:
    var id:=current_id()
    if id.is_empty() or token(id)!=expected_token:return "这一步已经变化，请重新查看。"
    var step:=current_step(id)
    if str(step.get("place","post_office"))!=place:return "先到信件所指的地点，再完成这一步。"
    for clue:String in step.get("requires",[]):
        if not state.evidence.has(clue):return "还有记录尚未核对，可以在本子里查看。"
    var error:=validate(step,answer)
    if not error.is_empty():return error
    var before:=state.duplicate(true)
    var progress:Dictionary=state.events[id]
    progress.choices[str(int(progress.step))]=answer.duplicate(true)
    for key:String in step.get("gives",{}):state.evidence[key]=step.gives[key]
    if step.has("flag"):state.flags[step.flag]=answer.get("choice",answer.get("strikes",true))
    progress.step=int(progress.step)+1
    var item:=event(id)
    while int(progress.step)<item.steps.size():
        var next:Dictionary=item.steps[int(progress.step)]
        if not next.has("when") or state.flags.get(str(next.when.key),null)==next.when.value:break
        progress.step=int(progress.step)+1
    if int(progress.step)>=item.steps.size():
        progress.done=true
        state.journal.append({"id":id,"day":state.day,"title":item.title,"text":item.get("memory",item.title)})
        state.selected=""
        if id=="somewhere":state.finished=true
    if save():return ""
    state=before
    return last_error

func validate(step:Dictionary,answer:Dictionary)->String:
    match str(step.kind):
        "read","inspect":
            var seen:Array=answer.get("seen",[]).map(func(value:Variant):return int(value))
            for i in step.get("pages",[]).size():
                if i not in seen:return "还有一页没有看过。"
        "talk":
            if not answer.get("heard",false):return "先听完这段交谈。"
        "choice","sort":
            var found:=false
            for option:Dictionary in step.options:
                if str(option.id)==str(answer.get("choice","")):found=true
            if not found:return "请选择一个处理方向。"
            if step.has("correct") and str(answer.choice)!=str(step.correct):return str(step.get("retry","记录还对不上，再看看信封上的信息。"))
        "pack":
            var positions:Dictionary=answer.get("positions",{})
            var occupied:Array=[]
            for item:Dictionary in step.items:
                if not positions.has(item.id):return "还有物件没有装好。"
                var pos:Array=positions[item.id]
                if pos.size()!=3:return "摆放位置无效。"
                var width:=int(item.h) if bool(pos[2]) else int(item.w)
                var height:=int(item.w) if bool(pos[2]) else int(item.h)
                if int(pos[0])<0 or int(pos[1])<0 or int(pos[0])+width>int(step.get("columns",6)) or int(pos[1])+height>int(step.get("rows",4)):return "物件要完整放进箱内。"
                for y in range(int(pos[1]),int(pos[1])+height):
                    for x in range(int(pos[0]),int(pos[0])+width):
                        var cell:=Vector2i(x,y)
                        if cell in occupied:return "物件重叠了，挪开一点再封装。"
                        occupied.append(cell)
        "sequence","order":
            if answer.get("actions",[])!=step.actions:return "按物件当前状态继续操作。"
        "cook":
            var selected:Array=answer.get("ingredients",[]).duplicate()
            var expected:Array=step.correct.duplicate()
            selected.sort();expected.sort()
            if selected!=expected:return "味道还没对上，再看看菜摊记录，可以重新试做。"
            if answer.get("actions",[])!=step.actions:return "这一份还没有完成。"
        "listen":
            if float(answer.get("elapsed",0))<float(step.seconds):return "录音还在播放。"
        "strike":
            for index:Variant in answer.get("strikes",[]):
                if not (index is int or index is float) or float(index)!=float(int(index)) or int(index)<0 or int(index)>=step.sentences.size():return "划改位置无效。"
        "write":
            if str(answer.get("text","")).strip_edges().is_empty():return "写下一句话就好。"
            if str(answer.text).length()>2000:return "这张纸最多容纳两千字。"
            if str(answer.get("recipient","")).strip_edges().is_empty():return "先写上收件人。"
        "sound":
            if not answer.get("found",false):return "走近声音的来源，再拿起贺卡。"
        _:
            return "未知的物件操作，进度没有改变。"
    return ""

func day_complete()->bool:
    if not active():return false
    for item:Dictionary in catalog.events:
        if int(item.day)==int(state.day) and not item.get("optional",false) and not state.events[item.id].done:return false
    return true

func inspect_attic(index:int)->bool:
    if not day_complete() or index<0 or index>=catalog.nights[int(state.day)-1].objects.size():return false
    var before:=state.duplicate(true);var day_key:=str(state.day)
    if not state.attic.has(day_key):state.attic[day_key]=[]
    if index not in state.attic[day_key]:state.attic[day_key].append(index)
    if save():return true
    state=before;return false

func can_sleep()->bool:
    return active() and int(state.day)<5 and day_complete() and state.attic.get(str(state.day),[]).size()==catalog.nights[int(state.day)-1].objects.size()

func sleep()->bool:
    if not can_sleep():return false
    var before:=state.duplicate(true)
    state.day=int(state.day)+1;state.selected="";state.location="post_office";state.room=0;state["minute"]=540
    if save():return true
    state=before;return false

func has_save()->bool:return FileAccess.file_exists(path) or FileAccess.file_exists(path+".bak")

func load_journey()->bool:
    last_error=""
    for candidate:String in [path,path+".bak"]:
        if not FileAccess.file_exists(candidate):continue
        var reader:=JSON.new()
        if reader.parse(FileAccess.get_file_as_string(candidate))!=OK:continue
        var parsed:Variant=reader.data
        if not parsed is Dictionary or parsed.get("format")!=FORMAT or int(parsed.get("version",0))!=1:continue
        if int(parsed.get("day",0))<1 or int(parsed.get("day",0))>5:continue
        if not parsed.get("events") is Dictionary or not parsed.get("flags") is Dictionary or not parsed.get("evidence") is Dictionary:continue
        var valid:=true
        for item:Dictionary in catalog.events:
            var progress:Variant=parsed.events.get(item.id)
            if not progress is Dictionary or not progress.get("work") is Dictionary or not progress.get("choices") is Dictionary or int(progress.get("step",-1))<0 or int(progress.step)>item.steps.size():valid=false;break
            if bool(progress.get("done",false))!=(int(progress.step)==item.steps.size()):valid=false;break
        if not valid:continue
        if not parsed.get("attic") is Dictionary or not parsed.get("journal") is Array:continue
        state=parsed;state["selected"]=str(state.get("selected",""));state["finished"]=bool(state.get("finished",false))
        state.day=int(state.day)
        for id:String in state.events:state.events[id].step=int(state.events[id].step)
        for day:String in state.attic:state.attic[day]=state.attic[day].map(func(value:Variant):return int(value))
        state["location"]=str(state.get("location","post_office"));state["room"]=clampi(int(state.get("room",0)),0,1)
        recovered_backup=candidate.ends_with(".bak")
        return true
    last_error="旅程记录暂时无法读取，原文件已保留。"
    return false

func save()->bool:
    if not active():return true
    last_error=""
    var directory:=ProjectSettings.globalize_path(path.get_base_dir())
    if DirAccess.make_dir_recursive_absolute(directory)!=OK:last_error="无法创建旅程记录目录。";return false
    var temporary:=path+".tmp"
    var file:=FileAccess.open(temporary,FileAccess.WRITE)
    if file==null:last_error="暂时无法写入旅程记录。";return false
    file.store_string(JSON.stringify(state,"\t"));file.flush()
    var write_error:=file.get_error();file.close()
    if write_error!=OK or JSON.parse_string(FileAccess.get_file_as_string(temporary))!=JSON.parse_string(JSON.stringify(state)):
        last_error="旅程记录未能完整写入，原文件已保留。";return false
    var destination:=ProjectSettings.globalize_path(path)
    var backup:=ProjectSettings.globalize_path(path+".bak")
    if FileAccess.file_exists(path) and not recovered_backup:
        if DirAccess.copy_absolute(destination,backup)!=OK:last_error="无法备份上一份旅程。";return false
    if DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary),destination)!=OK:
        last_error="无法替换旅程记录，上一份记录已保留。";return false
    recovered_backup=false
    return true
