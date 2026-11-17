extends SceneTree
const State=preload("res://scripts/campaign/five_day_state.gd")
var checks:=0
var failures:Array[String]=[]
func _initialize()->void:run.call_deferred()
func check(value:bool,label:String)->void:
    checks+=1
    if not value:failures.append(label);push_error(label)
static func solve(step:Dictionary,variant:int=0)->Dictionary:
    match str(step.kind):
        "talk":return {"heard":true}
        "read","inspect":return {"seen":range(step.pages.size())}
        "sort":return {"choice":step.correct}
        "choice":return {"choice":step.options[variant%step.options.size()].id}
        "sequence","order":return {"actions":step.actions.duplicate()}
        "strike":return {"strikes":[0] if variant%2 else []}
        "write":return {"recipient":"Somewhere","text":"我还没想好，但想先写一封信。"}
        "sound":return {"found":true}
        "listen":return {"elapsed":step.seconds}
        "cook":return {"ingredients":step.correct.duplicate(),"actions":step.actions.duplicate()}
        "pack":
            var positions:Dictionary={}
            var occupied:Array=[]
            for item:Dictionary in step.items:
                var placed:=false
                for y in int(step.rows):
                    if placed:break
                    for x in int(step.columns):
                        var cells:Array=[]
                        var valid:=x+int(item.w)<=int(step.columns) and y+int(item.h)<=int(step.rows)
                        for dy in int(item.h):
                            for dx in int(item.w):
                                var cell:=Vector2i(x+dx,y+dy)
                                if cell in occupied:valid=false
                                cells.append(cell)
                        if valid:
                            positions[item.id]=[x,y,false];occupied.append_array(cells);placed=true;break
            return {"positions":positions}
    return {}
func run()->void:
    var stamp:=str(Time.get_ticks_usec())
    for variant in 4:
        var state=State.new();state.path="user://qa/five-day-state/"+stamp+"-"+str(variant)+".json"
        check(state.new_journey(),"create isolated journey")
        check(not state.sleep(),"cannot sleep before finishing work")
        var loops:=0
        while not state.state.finished and loops<160:
            loops+=1
            if state.day_complete():
                for i in state.catalog.nights[int(state.state.day)-1].objects.size():check(state.inspect_attic(i),"record attic object")
                check(state.sleep(),"advance only from bed")
                continue
            var current:Dictionary=state.current_step()
            check(not current.is_empty(),"reachable next step")
            if current.is_empty():break
            var expected:String=state.token()
            var answer:=solve(current,variant)
            var before:Dictionary=state.state.duplicate(true)
            check(not state.submit(expected,answer,"wrong-place").is_empty(),"wrong place blocked")
            check(state.state==before,"wrong place retains progress")
            if current.kind=="pack":
                check(not state.validate(current,{"positions":{}}).is_empty(),"empty box rejected")
                var overlap:Dictionary={}
                for item:Dictionary in current.items:overlap[item.id]=[0,0,false]
                check(not state.validate(current,{"positions":overlap}).is_empty(),"overlapping contents rejected")
            if current.kind=="sort":
                for option:Dictionary in current.options:
                    if option.id!=current.correct:check(not state.validate(current,{"choice":option.id}).is_empty(),"wrong inference recoverable")
            check(state.remember(state.current_id(),"answer",answer),"partial work saved")
            var resumed=State.new();resumed.path=state.path
            check(resumed.load_journey(),"reload every step")
            check(resumed.token()==expected,"resume same step")
            # JSON restores number arrays as floats; validate resumed strike/pack data.
            answer=resumed.work(resumed.current_id()).answer
            var result:String=resumed.submit(expected,answer,current.place)
            check(result.is_empty(),"complete "+expected+": "+result)
            if not result.is_empty():break
            check(not resumed.submit(expected,answer,current.place).is_empty(),"double completion blocked")
            state=resumed
        check(state.state.finished and int(state.state.day)==5,"all five days reach ending")
        check(state.state.events.maya_private.done and state.state.events.rae.done,"private letters stay completable")
        check(not state.sleep(),"ending does not create sixth day")
        check(state.select("anonymous"),"optional delivery remains available after ending")
        for i in 4:
            var current:Dictionary=state.current_step()
            check(state.submit(state.token(),solve(current),current.place).is_empty(),"optional chain completes")
        check(state.state.events.anonymous.done,"optional chain complete")
        var good:String=FileAccess.get_file_as_string(state.path+".bak")
        var broken:=FileAccess.open(state.path,FileAccess.WRITE);broken.store_string("{broken");broken.close()
        var recovered=State.new();recovered.path=state.path
        check(recovered.load_journey(),"recover from interrupted/corrupt primary")
        check(recovered.save(),"recovered journey can save")
        check(FileAccess.get_file_as_string(state.path+".bak")==good,"recovery preserves last good backup")
        var previous:Dictionary=recovered.state.duplicate(true)
        recovered.path="res://project.godot/not-a-directory/save.json"
        check(not recovered.remember("anonymous","probe",1),"completed object cannot be mutated")
        check(recovered.state==previous,"failed write/mutation preserves memory")
    print("FIVE_DAY_STATE checks=%d failures=%d"%[checks,failures.size()])
    quit(0 if failures.is_empty() else 1)
