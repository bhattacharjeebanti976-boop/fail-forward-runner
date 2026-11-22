extends RefCounted
## Save data (user://save.cfg). Web builds keep it in the browser's storage.

const PATH := "user://save.cfg"

var n := 30
var reach := 0            # furthest level index the player has reached
var done: Array = []      # level cleared?
var best: Array = []      # best time in seconds (-1 = none)
var ldeaths: Array = []   # total oopsies on each level
var minis: Array = []     # secret pumpkin found?
var deaths := 0           # lifetime oopsies
var bounces := 0          # lifetime "bounce backs" (bounces on your own pads)
var hat := 0              # equipped hat id
var seen := 1             # bitmask of hats already announced


func _init(count: int = 30) -> void:
	n = count
	reset()


func reset() -> void:
	reach = 0
	deaths = 0
	bounces = 0
	hat = 0
	seen = 1
	done = []
	best = []
	ldeaths = []
	minis = []
	for i in n:
		done.append(false)
		best.append(-1.0)
		ldeaths.append(0)
		minis.append(false)


func has_progress() -> bool:
	return reach > 0 or deaths > 0 or bounces > 0


func count_done() -> int:
	var c := 0
	for d in done:
		if d:
			c += 1
	return c


func count_minis() -> int:
	var c := 0
	for m in minis:
		if m:
			c += 1
	return c


func load_file() -> void:
	var cf := ConfigFile.new()
	if cf.load(PATH) != OK:
		return
	reach = clampi(int(cf.get_value("p", "reach", 0)), 0, n - 1)
	deaths = int(cf.get_value("p", "deaths", 0))
	bounces = int(cf.get_value("p", "bounces", 0))
	hat = int(cf.get_value("p", "hat", 0))
	seen = int(cf.get_value("p", "seen", 1))
	var arrs := {"done": done, "best": best, "ldeaths": ldeaths, "minis": minis}
	for k in arrs:
		var v = cf.get_value("p", k, [])
		if v is Array:
			for i in mini(n, v.size()):
				arrs[k][i] = v[i]


func save_file() -> void:
	var cf := ConfigFile.new()
	cf.set_value("p", "reach", reach)
	cf.set_value("p", "deaths", deaths)
	cf.set_value("p", "bounces", bounces)
	cf.set_value("p", "hat", hat)
	cf.set_value("p", "seen", seen)
	cf.set_value("p", "done", done)
	cf.set_value("p", "best", best)
	cf.set_value("p", "ldeaths", ldeaths)
	cf.set_value("p", "minis", minis)
	cf.save(PATH)
