class_name Upgrade
extends Object

var display_name : String
var description : String
var base_cost: int
var rarity: int = 0
var icon : Texture2D

## can_buy(run: Run) -> bool:
## Takes a Run param, outputs if this item can currently be purchased
@warning_ignore("unused_parameter")
var can_buy: Callable = func(run: Run) -> bool: return true

## buy(run: Run) -> void:
## Takes a Run param, and applies the buy effects of this upgrade to the run
@warning_ignore("unused_parameter")
var buy: Callable = func(run: Run) -> void: return

## sell(run: Run) -> void:
## Takes a Run param, and applies the sell effects of this upgrade to the run
@warning_ignore("unused_parameter")
var sell: Callable = func(run: Run) -> void: return


## tick(run: Run) -> void:
## Takes a Run param, and applies the tick effects of this upgrade to the run
@warning_ignore("unused_parameter")
var tick: Callable = func(run: Run) -> void: return
