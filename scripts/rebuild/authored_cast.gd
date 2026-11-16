extends RefCounted
const PLAYER_NAME:="Anne"
const NAMES:={"TarotGuest":"夏透明","record_clerk":"Xanni","bookseller":"Maya","Naonao":"闹闹","lookout":"Rae","chef":"咸鱼","FoodTruckGuest":"尘缘","grocer":"冥冥","community":"cici"}
static func speaker_name(value:String)->String:
	if value in ["你","You","主角","Anne"]:return PLAYER_NAME
	if value in ["餐车老板","Chef"]:return NAMES.chef
	return value
## The user's location assignments. Positions are in the current street's world space.
const RESIDENTS = {
	"chef":{"family":"community","foot":Vector2(12260,840),"height":350.0,"zh":"咸鱼","en":"咸鱼"},
	"community":{"family":"community","foot":Vector2(3450,850),"height":290.0,"zh":"cici","en":"cici"},
	"grocer":{"family":"community","foot":Vector2(6660,850),"height":300.0,"zh":"冥冥","en":"冥冥"},
	"resident":{"family":"residential","foot":Vector2(3450,850),"height":310.0,"zh":"居民","en":"Resident"},
	"lookout":{"family":"residential","foot":Vector2(6750,850),"height":310.0,"zh":"Rae","en":"Rae"},
	"bookseller":{"family":"postal","foot":Vector2(5890,850),"height":310.0,"zh":"Maya","en":"Maya"},
	"guitarist":{"family":"coastal","foot":Vector2(3370,850),"height":310.0,"zh":"吉他手","en":"Guitarist"},
	"record_clerk":{"family":"coastal","foot":Vector2(3730,850),"height":310.0,"zh":"Xanni","en":"Xanni"}
}
