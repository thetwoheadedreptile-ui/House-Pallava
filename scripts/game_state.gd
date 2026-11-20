extends Node
## Global game state: resources, calendar, and households in Thondaimandalam.

signal resource_changed(resource: String, value: int)
signal date_changed()

const MONTHS := [
	"Chithirai", "Vaikasi", "Aani", "Aadi", "Aavani", "Purattasi",
	"Aippasi", "Karthigai", "Margazhi", "Thai", "Masi", "Panguni",
]

const SEASONS := {
	"spring": "Ilavenil", "summer": "Mudhuvenil",
	"monsoon": "Kaar", "winter": "Kulir",
}
const SEASON_BY_MONTH := [
	"spring", "summer", "summer", "monsoon", "monsoon", "monsoon",
	"winter", "winter", "winter", "spring", "spring", "summer",
]

const SECONDS_PER_MONTH := 8.0

var resources := {
	"grain": 120,
	"fodder": 80,
	"wood": 40,
	"coin": 60,
	"hounds": 12,
}

var month_index := 0
var year := 1
var time_scale := 1.0
var _month_timer := 0.0


func add(resource: String, amount: int) -> void:
	resources[resource] = int(resources.get(resource, 0)) + amount
	resource_changed.emit(resource, resources[resource])


func spend(resource: String, amount: int) -> bool:
	if int(resources.get(resource, 0)) < amount:
		return false
	resources[resource] = int(resources[resource]) - amount
	resource_changed.emit(resource, resources[resource])
	return true


func season() -> String:
	return SEASONS[SEASON_BY_MONTH[month_index]]


func month_name() -> String:
	return MONTHS[month_index]


func date_label() -> String:
	return "%s, Year %d — %s" % [month_name(), year, season()]


func _process(delta: float) -> void:
	_month_timer += delta * time_scale
	if _month_timer >= SECONDS_PER_MONTH:
		_month_timer -= SECONDS_PER_MONTH
		_advance_month()


func _advance_month() -> void:
	month_index += 1
	if month_index >= MONTHS.size():
		month_index = 0
		year += 1
	date_changed.emit()
