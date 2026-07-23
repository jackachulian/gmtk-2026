class_name Upgrade
extends Object

var _definition: UpgradeDefinition
var definition: UpgradeDefinition:
	get(): return _definition
	
var cost: int

## Chance out of 100 for this to occur in effects
var chance: int

## Current effect value that can be used in effects for miscellaneous purposes
var value: float = 1.0

func _init(definition: UpgradeDefinition) -> void:
	_definition = definition
	cost = _definition.base_cost
	chance = _definition.base_chance

func can_buy(run: Run) -> bool:
	return _definition.can_buy.call(run, self)

func buy(run: Run) -> void:
	_definition.buy.call(run, self)
	
func sell(run: Run) -> void:
	_definition.sell.call(run, self)

func tick(run: Run) -> void:
	_definition.tick.call(run, self)
	
func round_start(run: Run) -> void:
	_definition.round_start.call(run, self)
	
func round_end(run: Run) -> void:
	_definition.round_end.call(run, self)
	
func get_parsed_description() -> String:
	return _definition.description.replace("[chance]", str(chance)+"%")
