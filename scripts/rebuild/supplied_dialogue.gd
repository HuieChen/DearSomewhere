extends RefCounted
## Source-authored text only. No postal actions, evidence or campaign writes.
const PATH := "res://data/dialogue/supplied_20261116.json"
const MAX_PAGE_CHARACTERS := 52
static var _data: Dictionary = {}

static func catalog() -> Dictionary:
	if _data.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary and parsed.get("version") == 1: _data = parsed
	return _data.duplicate(true)

static func ambient_lines(actor: String) -> Array:
	var data := catalog()
	return paginate(data.get("ambient", {}).get(actor, {}).get("lines", []))

static func chapter_records(actor: String, chapter: int) -> Array:
	# Staging API for future chapter event handlers, never the default NPC greeting.
	var result: Array = []
	for row: Dictionary in catalog().get("records", []):
		if row.get("actor") == actor and int(row.get("chapter", 0)) == chapter:
			result.append(row.duplicate(true))
	return result

static func paginate(lines: Array) -> Array:
	var result: Array = []
	for line: Dictionary in lines:
		var remaining := str(line.text)
		# Two handwritten lines fit the authored notebook at every supported
		# window scale; long source passages continue on the next paper page.
		while remaining.length() > MAX_PAGE_CHARACTERS:
			var cut := MAX_PAGE_CHARACTERS
			for i in range(MAX_PAGE_CHARACTERS-1, 23, -1):
				if remaining[i] in ["。", "！", "？", "，", "；", "\n"]:
					cut = i + 1
					break
			var page := line.duplicate(true)
			page.text = remaining.left(cut)
			result.append(page)
			remaining = remaining.substr(cut)
		if not remaining.is_empty():
			var page := line.duplicate(true)
			page.text = remaining
			result.append(page)
	return result
