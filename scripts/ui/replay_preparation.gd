extends Node
## A root-owned reaper survives recorder closure until its private worker joins.
## Only the main thread touches nodes; the worker owns its fresh WAV resource.
signal completed(result:Dictionary)
class Work extends RefCounted:
	var mutex:=Mutex.new()
	var cancelled:=false
	func cancel()->void:
		mutex.lock();cancelled=true;mutex.unlock()
	func is_cancelled()->bool:
		mutex.lock();var value:=cancelled;mutex.unlock();return value
	func run(path:String)->Dictionary:
		if is_cancelled():return {}
		var stream:=AudioStreamWAV.load_from_file(path)
		if stream==null or is_cancelled():return {}
		var gain:=0.0
		if stream.format==AudioStreamWAV.FORMAT_16_BITS:
			var bytes:=stream.data
			var peak:=0
			for chunk in range(0,bytes.size()-1,8192):
				if is_cancelled():return {}
				for i in range(chunk,mini(chunk+8192,bytes.size()-1),2):peak=maxi(peak,absi(bytes.decode_s16(i)))
			gain=clampf(-6.0-linear_to_db(maxf(float(peak)/32768.0,.00001)),0.0,12.0)
		return {"stream":stream,"gain":gain}
var work:=Work.new()
var thread:=Thread.new()
func start(path:String)->Error:
	return thread.start(work.run.bind(path),Thread.PRIORITY_LOW)
func cancel()->void:work.cancel()
func _process(_delta:float)->void:
	if not thread.is_started():queue_free();return
	if thread.is_alive():return
	var result:Dictionary=thread.wait_to_finish()
	if not work.is_cancelled():completed.emit(result)
	queue_free()
func _exit_tree()->void:
	work.cancel()
	if thread.is_started():thread.wait_to_finish()
