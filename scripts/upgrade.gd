class_name Upgrade
extends Object

var _definition: UpgradeDefinition
var definition: UpgradeDefinition:
	get(): return _definition
var cost: int

func _init(definition: UpgradeDefinition) -> void:
	_definition = definition
	cost = _definition.base_cost

func can_buy(run: Run) -> bool:
	return _definition.can_buy.call(run, self)

func buy(run: Run) -> void:
	_definition.buy.call(run, self)
	
func sell(run: Run) -> void:
	_definition.sell.call(run, self)

func tick(run: Run) -> void:
	_definition.tick.call(run, self)
