class_name Run
extends Object

## Emitted whenever the timer ticks down
var _time: int = 600
var time: int: 
	get(): return _time

var _cash: int = 20
var cash: int: 
	get(): return _cash

## Current length of a single countdown tick, in seconds
## (Used by the RunManager for real-world timing)
var _tick_delay: float = 1.0

## Current amount of seconds until the next tick
var _tick_timer: float = 1.0

## Current timer second decrease of a single countdown tick
var _tick_amount: int = 1

## Currently owned upgrades
var _upgrades: Array[Upgrade]
signal upgrades_changed()

## Upgrades in the shop
var _shop: Array[Upgrade]
signal shop_changed()

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
	_time -= _tick_amount
	for upgrade in _upgrades:
		upgrade.tick.call(self)
