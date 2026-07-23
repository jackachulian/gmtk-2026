class_name UpgradeDefinition
extends Object

var id : String
var display_name : String
var description : String
var base_cost: int

## 0=common, 1=uncommon, 2=rare
var rarity: int = 0
var icon : Texture2D

## can_buy(run: Run, upgrade: Upgrade) -> bool:
## Takes current Run and the Upgrade instance this is being called on, 
## outputs if this upgrade can currently be purchased
@warning_ignore("unused_parameter")
var can_buy: Callable = func(run: Run, upgrade: Upgrade) -> bool: return true

## buy(run: Run, upgrade: Upgrade) -> void:
## Takes current Run and the Upgrade instance this is being called on, 
## and applies the buy effects of this upgrade to the run
@warning_ignore("unused_parameter")
var buy: Callable = func(run: Run, upgrade: Upgrade) -> void: return

## sell(run: Run, upgrade: Upgrade) -> void:
## Takes current Run and the Upgrade instance this is being called on, 
## and applies the sell effects of this upgrade to the run
@warning_ignore("unused_parameter")
var sell: Callable = func(run: Run, upgrade: Upgrade) -> void: return

## tick(run: Run, upgrade: Upgrade) -> void:
## Takes current Run and the Upgrade instance this is being called on, 
## and applies the tick effects of this upgrade to the run
@warning_ignore("unused_parameter")
var tick: Callable = func(run: Run, upgrade: Upgrade) -> void: return

### Make a duplicate instance of this UpgradeDefinition
#func duplicate() -> Upgrade:
	#var copy := Upgrade.new()
	#copy.id = id
	#copy.display_name = display_name
	#copy.description = description
	#copy.base_cost = base_cost
	#copy.rarity = rarity
	#copy.icon = icon
	#return copy
