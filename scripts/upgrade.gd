class_name Upgrade
extends Object

var _definition: UpgradeDefinition
var definition: UpgradeDefinition:
	get(): return _definition
	
var cost: int

## Chance out of 100 for this to occur in effects.
## Scales with level for modifiers
var chance: int

## Current effect value that can be used in effects for miscellaneous purposes
var value: float = 1.0

## The level of this upgrade. (Used on modifiers only)
## When buying a copy of a modifier, the original modifier's level is increased instead.
var level: int = 1

var icon: Texture2D

# When negative, inf durability (for modifiers)
var durability: int = -1

var can_be_sold: bool = true

# -1 when not in inventroy
var inventory_slot: int = -1

var attached_upgrade: Upgrade

func _init(definition: UpgradeDefinition) -> void:
	_definition = definition
	cost = _definition.base_cost
	chance = _definition.base_chance
	icon = _definition.icon
	durability = definition.base_dur
	can_be_sold = definition.can_be_sold
	inventory_slot = -1
	attached_upgrade = null
	
	

func can_buy(run: Run) -> bool:
	return _definition.can_buy.call(run, self)

func buy(run: Run) -> void:
	_definition.buy.call(run, self)
	
func sell(run: Run) -> void:
	_definition.sell.call(run, self)

func tick(run: Run, forced: bool) -> bool:
	return await _definition.tick.call(run, self, forced)
	
func round_start(run: Run) -> void:
	_definition.round_start.call(run, self)
	
func round_end(run: Run) -> void:
	_definition.round_end.call(run, self)
	
func get_parsed_description() -> String:
	return _definition.description.replace("[chance]", str(chance)+"%")
