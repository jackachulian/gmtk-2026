class_name Run
extends Object

const SHOP_SIZE := 5
const INVENTORY_SIZE := 5

## Emitted whenever the timer ticks down
var time: int = 600

var cash: int = 20

## Current length of a single countdown tick, in seconds
## (Used by the RunManager for real-world timing)
var _tick_delay: float = 1.0

## Current amount of seconds until the next tick
var _tick_timer: float = 1.0

## Current timer second decrease of a single countdown tick
var _tick_amount: int = 1

## Currently owned upgrades
var _inventory: Array[Upgrade] = []
var inventory: Array[Upgrade]: 
	get(): return _inventory
signal inventory_changed()

## Upgrades in the shop
var _shop: Array[Upgrade] = []
var shop: Array[Upgrade]: 
	get(): return _shop
signal shop_changed()

func _init() -> void:
	_inventory.resize(INVENTORY_SIZE)
	_shop.resize(INVENTORY_SIZE)

## Perform rick timing calculations.
## RunManager will call this in its _process() loop
func process(delta: float) -> void:
	_tick_timer -= delta
	var iterations: int = 0
	while _tick_timer <= 0:
		_tick_timer += _tick_delay
		_do_tick()
		
		if iterations > 500:
			push_error("Very long loop detected; ending loop!")
			break
			
func _do_tick() -> void:
	time -= _tick_amount
	for upgrade in _inventory:
		if upgrade:
			upgrade.tick(self)

func set_inventory_slot(slot: int, upgrade: Upgrade):
	_inventory[slot] = upgrade
	inventory_changed.emit()
	
func set_shop_slot(slot: int, upgrade: Upgrade):
	_shop[slot] = upgrade
	shop_changed.emit()
