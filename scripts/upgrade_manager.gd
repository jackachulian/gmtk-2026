class_name UpgradeManager
extends Node

## Key = upgrade id, Value = data defining this type of upgrade
static var upgrade_definitions: Dictionary[String, UpgradeDefinition] = {}

## Index = rarity (0=common, 1=uncommon, 2=rare), value = Array[UpgradeDefinition]
static var definitions_by_rarity: Array[Array] = []

## Key = modifier id: Value = data defining this modifier
## Modifiers are just upgrades that run their buy() effect when selected,
## and their tick() on every timer tick. They behave similarly to upgrades
## currently owned within the inventory.
static var modifier_definitions: Dictionary[String, UpgradeDefinition] = {}

func _enter_tree() -> void:
	generate_upgrade_definitions()
	generate_modifier_definitions()
#
#static func instantiate_upgrade(definition_id: String) -> Upgrade:
	#var definition: UpgradeDefinition = upgrade_definitions.get(definition_id)
	#if not definition:
		#push_error("Missing upgrade definition ID: ", definition_id)
		#return null
	#return Upgrade.new(definition)
	#
#static func instantiate_modifier(definition_id: String) -> Upgrade:
	#var definition: UpgradeDefinition = modifier_definitions.get(definition_id)
	#if not definition:
		#push_error("Missing modifier definition ID: ", definition_id)
		#return null
	#return Upgrade.new(definition)

static func add_upgrade_definition(def: UpgradeDefinition) -> void:
	upgrade_definitions[def.id] = def
	definitions_by_rarity[def.rarity].append(def)
	
static func add_modifier_definition(def: UpgradeDefinition) -> void:
	modifier_definitions[def.id] = def
	
static func generate_upgrade_definitions() -> void:
	upgrade_definitions.clear()
	definitions_by_rarity.resize(3)
	
	var u: UpgradeDefinition
	
	u = UpgradeDefinition.new()
	u.id = "sec30"
	u.display_name = "Borrowed Time"
	u.description = "+30 Seconds"
	u.base_cost = 5
	u.rarity = 0
	u.buy = func(run: Run, _upgrade: Upgrade): run.time += 30
	u.sell = func(run: Run, _upgrade: Upgrade): run.time -= 30
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "boosterI"
	u.display_name = "Booster I"
	u.description = "Each tick, [chance] chance of +5 seconds"
	u.base_chance = 25
	u.base_cost = 5
	u.rarity = 0
	u.tick = func(run: Run, _upgrade: Upgrade): if randf() <= 0.25: run.time += 5
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "boosterII"
	u.display_name = "Booster II"
	u.description = "Each tick, [chance] chance of +20 seconds"
	u.base_chance = 10
	u.base_cost = 10
	u.rarity = 1
	u.tick = func(run: Run, _upgrade: Upgrade): if randf() <= 0.1: run.time += 20
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "moneyI"
	u.display_name = "Money I"
	u.description = "Each tick, [chance] chance of +$1"
	u.base_chance = 25
	u.base_cost = 10
	u.rarity = 0
	u.tick = func(run: Run, _upgrade: Upgrade): if randf() <= 0.25: run.cash += 1
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "moneyII"
	u.display_name = "Money II"
	u.description = "Each tick, [chance] chance of +$4"
	u.base_chance = 10
	u.base_cost = 10
	u.rarity = 1
	u.tick = func(run: Run, _upgrade: Upgrade): if randf() <= 0.1: run.cash += 4
	add_upgrade_definition(u)


func generate_modifier_definitions() -> void:
	modifier_definitions.clear()
	
	var m: UpgradeDefinition
	
	m = UpgradeDefinition.new()
	m.id = "time_fluctuation"
	m.display_name = "Time Fluctuation"
	m.description = "Each tick, [chance] chance to double time, and [chance] chance to halve time"
	m.base_chance = 1
	m.tick = func(run: Run, upgrade: Upgrade): 
		if randi_range(1,100) <= upgrade.chance: run.time *= 2
		if randi_range(1,100) <= upgrade.chance*2: run.time /= 2
	add_modifier_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "tick_speed_fluctuation"
	m.display_name = "Tick Speed Fluctuation"
	m.description = "Each tick, [chance] chance to double speed, and [chance] chance to halve speed (Resets each round)"
	m.base_chance = 1
	m.tick = func(run: Run, upgrade: Upgrade): 
		if randi_range(1,100) <= upgrade.chance: 
			upgrade.value *= 2
			run.tick_rate *= 2
		elif randi_range(1,100) <= upgrade.chance*2: 
			upgrade.value /= 2
			run.tick_rate /= 2
	m.round_end = func(run: Run, upgrade: Upgrade):
		run.tick_rate /= upgrade.value
		upgrade.value = 1.0
	add_modifier_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "swapper"
	m.display_name = "Swapper"
	m.description = "Each tick, [chance] chance to swap minutes and seconds"
	m.base_chance = 1
	m.tick = func(run: Run, upgrade: Upgrade): 
		if randi_range(1,100) <= upgrade.chance:
			@warning_ignore("integer_division") var days := run.time / 86400
			@warning_ignore("integer_division") var hours := (run.time % 86400) / 3600
			@warning_ignore("integer_division") var minutes := (run.time % 3600) / 60
			var seconds := run.time % 60
			run.time = days*86400 + hours*3600 + seconds*60 + minutes
			
	m = UpgradeDefinition.new()
	m.id = "minute_rounder"
	m.display_name = "Minute Rounder"
	m.description = "Each tick, [chance] chance to round to the nearest minute"
	m.base_chance = 1
	m.tick = func(run: Run, upgrade: Upgrade): 
		if randi_range(1,100) <= upgrade.chance:
			var seconds := run.time % 60
			if seconds >= 30:
				run.time += 60
			run.time -= seconds
			
	add_modifier_definition(m)
