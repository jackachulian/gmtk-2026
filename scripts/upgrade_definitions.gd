# autoload name: Upgrades
extends Node

var _upgrades: Array[Upgrade] = []

func _enter_tree() -> void:
	generate_upgrades()

func generate_upgrades() -> void:
	_upgrades.clear()
	
	var u: Upgrade
	
	u = Upgrade.new()
	u.display_name = "+30 Seconds"
	u.description = "Buy: +30 seconds\nSell: -30 seconds"
	u.base_cost = 5
	u.rarity = 0
	u.buy = func(run: Run): run.time += 20
	u.sell = func(run: Run): run.time -= 20
	_upgrades.append(u)
	
	u = Upgrade.new()
	u.display_name = "Booster I"
	u.description = "Per second, 20% chance of +10 seconds"
	u.base_cost = 5
	u.rarity = 0
	u.tick = func(run: Run): if randf() <= 0.2: run.time += 10
	_upgrades.append(u)
	
	u = Upgrade.new()
	u.display_name = "Booster II"
	u.description = "Per second, 5% chance of +40 seconds"
	u.base_cost = 5
	u.rarity = 0
	u.tick = func(run: Run): if randf() <= 0.05: run.time += 40
	_upgrades.append(u)
