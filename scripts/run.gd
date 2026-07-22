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
var inventory: Array[Upgrade] = []
signal inventory_changed()

## Upgrades in the shop
var shop: Array[Upgrade] = []
signal shop_changed()

func _init() -> void:
	inventory.resize(INVENTORY_SIZE)
	shop.resize(INVENTORY_SIZE)

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
	for upgrade in inventory:
		if upgrade:
			upgrade.tick(self)

func set_inventory_slot(slot: int, upgrade: Upgrade):
	inventory[slot] = upgrade
	inventory_changed.emit()
	
func set_shop_slot(slot: int, upgrade: Upgrade):
	shop[slot] = upgrade
	shop_changed.emit()
	
## Returns true if successfully purchased
func buy_shop_item(slot: int) -> bool:
	var upgrade := shop[slot]
	if not upgrade:
		push_error("No upgrade in shop slot ",slot)
		return false
	
	if cash < upgrade.cost: 
		push_error("Not enough cash")
		return false
	
	## Add to first open slot
	var inventory_slot := get_first_open_inventory_slot()
	if inventory_slot == -1:
		push_error("Inventory is full")
		return false
		
	shop[slot] = null
	inventory[inventory_slot] = upgrade
	cash -= upgrade.cost
	## Upon buying, halve the upgrade's cost (which is now sell price) and round up
	upgrade.cost = roundi(upgrade.cost / 2.0)
	
	upgrade.buy(self)
	
	shop_changed.emit()
	inventory_changed.emit()
	
	return true
	
func sell_inventory_item(slot: int) -> bool:
	var upgrade := inventory[slot]
	if not upgrade:
		push_error("No upgrade in inventory slot ",slot)
		return false
		
	inventory[slot] = null
	cash += upgrade.cost
	
	upgrade.sell(self)
	
	inventory_changed.emit()
		
	return true
	
## Return the first unoccupied inventory slot, or -1 if all are occupied.
func get_first_open_inventory_slot() -> int:
	for i in inventory.size():
		if inventory[i] == null:
			return i
	return -1
