extends RefCounted
## Shared sidecar recovery for photos and recordings. Media bytes stay untouched.
static func _read(path:String)->Dictionary:
	if not FileAccess.file_exists(path):return {"valid":false}
	var decoder:=JSON.new()
	if decoder.parse(FileAccess.get_file_as_string(path))!=OK or not decoder.data is Dictionary:return {"valid":false}
	return {"valid":true,"data":decoder.data}

static func read(path:String)->Dictionary:
	for candidate:String in [path,path+".bak"]:
		var record:=_read(candidate)
		if record.valid:return record.data
	return {}

static func write(path:String,data:Dictionary)->bool:
	var target:=ProjectSettings.globalize_path(path)
	if DirAccess.dir_exists_absolute(target):return false
	var temporary:=target+".tmp"
	var backup:=target+".bak"
	var file:=FileAccess.open(temporary,FileAccess.WRITE)
	if file==null:return false
	var encoded:=JSON.stringify(data,"\t")
	file.store_string(encoded);file.flush()
	var error:=file.get_error();file.close()
	var verified:=_read(temporary)
	if error!=OK or not verified.valid or FileAccess.get_file_as_string(temporary)!=encoded:return false
	var retired:=""
	if FileAccess.file_exists(target):
		if _read(target).valid:
			if FileAccess.file_exists(backup) and DirAccess.remove_absolute(backup)!=OK:return false
			retired=backup
		else:
			# Never rotate corrupt bytes over a usable recovery record.
			retired=target+".corrupt-"+str(Time.get_ticks_usec())
		if DirAccess.rename_absolute(target,retired)!=OK:return false
	if DirAccess.rename_absolute(temporary,target)==OK:return true
	if not retired.is_empty():DirAccess.rename_absolute(retired,target)
	return false
