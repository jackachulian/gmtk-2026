class_name UpgradeManager
extends Node

@export var icon_reg: Array[Texture2D]

## Key = upgrade id, Value = data defining this type of upgrade
static var upgrade_definitions: Dictionary[String, UpgradeDefinition] = {}

static var status_definitions: Dictionary[String, UpgradeDefinition] = {}

## Index = rarity (0=common, 1=uncommon, 2=rare), value = Array[UpgradeDefinition]
static var definitions_by_rarity: Array[Array] = []

## Key = modifier id: Value = data defining this modifier
## Modifiers are just upgrades that run their buy() effect when selected,
## and their tick() on every timer tick. They behave similarly to upgrades
## currently owned within the inventory.
static var modifier_definitions: Dictionary[String, UpgradeDefinition] = {}

# Purely negative effects that are coupled with modifiers when they are being
# selected. Debuffs don't have a corresponding mod and are coupled randomly
static var debuff_definitions: Dictionary[String, UpgradeDefinition] = {}


func _enter_tree() -> void:
	generate_upgrade_definitions(get_tree().root.get_child(0))
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
	
static func add_status_definition(def: UpgradeDefinition) -> void:
	status_definitions[def.id] = def
		
static func add_modifier_definition(def: UpgradeDefinition) -> void:
	modifier_definitions[def.id] = def
	
static func add_debuff_definition(def: UpgradeDefinition) -> void:
	debuff_definitions[def.id] = def
	
static func generate_upgrade_definitions(node: Node) -> void:
	upgrade_definitions.clear()
	definitions_by_rarity.resize(3)
	
	var u: UpgradeDefinition
	
	u = UpgradeDefinition.new()
	u.id = "sec30"
	u.display_name = "Borrowed Time"
	u.description = "+30 Seconds"
	u.base_cost = 5
	u.base_dur = -1
	u.rarity = 0
	u.buy = func(run: Run, _upgrade: Upgrade): run.time += 30
	u.sell = func(run: Run, _upgrade: Upgrade): run.time -= 30
	u.icon = preload("res://graphics/foe_bug.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "boosterI"
	u.display_name = "Booster I"
	u.description = "Each tick, [chance] chance of +3 seconds"
	u.base_chance = 25
	u.base_cost = 5
	u.base_dur = 6
	u.rarity = 0
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		run.time += 3
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool: 
		if randf() <= 0.25: 
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/icons/booster.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "boosterII"
	u.display_name = "Booster II"
	u.description = "Each tick, [chance] chance of +15 seconds"
	u.base_chance = 10
	u.base_dur = 6
	u.base_cost = 10
	u.rarity = 1
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool: 
		if randf() <= 0.1: 
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/icons/booster.png")
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		run.time += 15
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "moneyI"
	u.display_name = "Money I"
	u.description = "Each tick, [chance] chance of +$2"
	u.base_chance = 25
	u.base_cost = 5
	u.base_dur = 6
	u.rarity = 0
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool: 
		if randf() <= 0.25: 
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/icons/money.png")
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void: run.cash += 2
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "moneyII"
	u.display_name = "Money II"
	u.description = "Each tick, [chance] chance of +$5"
	u.base_chance = 15
	u.base_cost = 10
	u.base_dur = 6
	u.rarity = 1
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void: run.cash += 5
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool: 
		if randf() <= 0.15: 
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/icons/money.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "drainI"
	u.display_name = "Money Drain I"
	u.description = "Each tick, [chance] chance of -$5 and +20 seconds"
	u.base_chance = 10
	u.base_cost = 3
	u.base_dur = 10
	u.rarity = 1
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		run.cash -= 5;
		run.time += 20;
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool:
		if randf() <= 0.1 && run.cash >= 5:
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/foe_bug.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "drainII"
	u.display_name = "Money Drain II"
	u.description = "Each tick, [chance] chance of -$10 and +50 seconds"
	u.base_chance = 10
	u.base_dur = 12
	u.base_cost = 5
	u.rarity = 2
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		run.cash -= 10;
		run.time += 50;
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool: 
		if randf() <= 0.1 && run.cash >= 10:
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/foe_bug.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "doubleI"
	u.display_name = "Double Tick"
	u.description = "Each tick, [chance] chance of +1 second and force additional tick"
	u.base_chance = 10
	u.base_cost = 8
	u.base_dur = 8
	u.rarity = 1
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		await node.get_tree().create_timer(0.15).timeout
		run.runner_force_tick()
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool:
		if randf() <= 0.1 && !forced:
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/icons/double.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "doubleII"
	u.display_name = "Triple Tick"
	u.description = "Each tick, [chance] chance of +1 second and force 2 additional ticks"
	u.base_chance = 10
	u.base_cost = 16
	u.base_dur = 8
	u.rarity = 2
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		await node.get_tree().create_timer(0.15).timeout
		run.runner_force_tick()
		await node.get_tree().create_timer(0.15).timeout
		run.runner_force_tick()
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool: 
		if randf() <= 0.1 && !forced:  
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/icons/triple.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "loan"
	u.display_name = "Loan"
	u.description = "+40$, removes 80$ when sold. +20$ on force-trigger."
	u.base_cost = 0
	u.base_dur = 6
	u.rarity = 0
	
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void: run.cash += 20
	u.buy = func(run: Run, _upgrade: Upgrade): run.cash += 40
	u.sell = func(run: Run, _upgrade: Upgrade): run.cash -= 80
	u.icon = preload("res://graphics/icons/loan.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "battery"
	u.display_name = "Battery"
	u.description = "Each tick, 33% chance of force-triggering 2 random upgrades"
	u.base_chance = 33
	u.base_cost = 9
	u.base_dur = 8
	u.rarity = 1
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		var trigger_idxs = []
		# get n valid items to trigger
		var valid_idxs = run.get_non_battery_inventory_indexes()
		for i in range(2):
			var idx = valid_idxs.get(randi_range(0, valid_idxs.size()-1))
			
			print(idx)
			if idx == null: return
			var upg = run.inventory[idx]
			if upg == null: return
			
			upg.definition.trigger.call(run, _upgrade, true)
			run.do_upgrade_trigger_effect(idx, true)
			
		#upg.definition.trigger.call(run, upgrade, true)
		#run.do_upgrade_trigger_effect(idx, true)
	u.tick = func(run: Run, _upgrade: Upgrade, forced: bool) -> bool:
		if randf() <= 0.33 && (run.get_non_battery_inventory_indexes().size() >= 1):
			u.trigger.call(run, _upgrade, false)
			return true
		return false
	u.icon = preload("res://graphics/icons/double.png")
	add_upgrade_definition(u)
	
	# ===========
	# STATUSES
	# ===========
	
	u = UpgradeDefinition.new()
	u.id = "rock"
	u.display_name = "Rock"
	u.description = "Cannot be sold."
	u.base_cost = 0
	u.base_dur = 20
	u.rarity = 0
	u.can_be_sold = false
	u.icon = preload("res://graphics/foe_bug.png")
	add_status_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "debt"
	u.display_name = "Debt"
	u.description = "Cannot be sold. On force-trigger, lose 30$."
	u.base_cost = 0
	u.base_dur = 10
	u.rarity = 0
	u.can_be_sold = false
	u.icon = preload("res://graphics/foe_bug.png")
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		run.cash -= 30
	
	add_status_definition(u)


# TODO make this use the tick/trigger system instead of just tick
func generate_modifier_definitions() -> void:
	modifier_definitions.clear()
	
	var m: UpgradeDefinition
	
	m = UpgradeDefinition.new()
	m.id = "time_fluctuation"
	m.display_name = "Time Fluctuation"
	m.description = "Each tick, [chance] chance to double time, and [chance] chance to halve time"
	m.base_chance = 1
	m.base_dur = -1
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool: 
		if randi_range(1,100) <= upgrade.chance: 
			run.time *= 2
			return true
		if randi_range(1,100) <= upgrade.chance*2: 
			run.time /= 2
			return true
		return false
	add_modifier_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "trigger_wave"
	m.display_name = "Trigger Wave"
	m.description = "Each natural tick, [chance] chance trigger all items. +0.5 mult to shop prices."
	m.base_chance = 8
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.cost_mult += 0.5
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		if randi_range(1,100) <= upgrade.chance && !forced:
			for idx in run.inventory.size():
				var upg = run.inventory[idx]
				if upg:
					upg.definition.trigger.call(run, upgrade, true)
					run.do_upgrade_trigger_effect(idx, true)
			return true
		return false
	m.round_end = func(run: Run, upgrade: Upgrade):
		pass
	add_modifier_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "swapper"
	m.display_name = "Swapper"
	m.description = "Each tick, [chance] chance to swap minutes and seconds"
	m.base_chance = 1
	m.base_dur = -1
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		if randi_range(1,100) <= upgrade.chance:
			@warning_ignore("integer_division") var days := run.time / 86400
			@warning_ignore("integer_division") var hours := (run.time % 86400) / 3600
			@warning_ignore("integer_division") var minutes := (run.time % 3600) / 60
			var seconds := run.time % 60
			run.time = days*86400 + hours*3600 + seconds*60 + minutes
			return true
		return false
	add_modifier_definition(m)
			
	m = UpgradeDefinition.new()
	m.id = "minute_rounder"
	m.display_name = "Minute Rounder"
	m.description = "Each tick, [chance] chance to round to the nearest minute"
	m.base_chance = 1
	m.base_dur = -1
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		if randi_range(1,100) <= upgrade.chance:
			var seconds := run.time % 60
			if seconds >= 30:
				run.time += 60
			run.time -= seconds
			return true
		return false
		
	m = UpgradeDefinition.new()
	m.id = "passive_income"
	m.display_name = "Passive Income"
	m.description = "Each tick, +[chance]$. Sell all upgrades and gain one rock."
	m.base_chance = 3
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		for i in run.inventory.size():
			run.sell_inventory_item(i)
		run.set_inventory_slot(run.get_first_open_inventory_slot(), Upgrade.new(status_definitions.get("rock")))
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		run.cash += m.base_chance
		return true
	add_modifier_definition(m)
	
	# ===========
	# Debuffs
	# ===========
	m = UpgradeDefinition.new()
	m.id = "debt"
	m.display_name = ""
	m.description = "Replace your first 2 upgrades with Debt"
	m.base_chance = 1
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.set_inventory_slot(0, Upgrade.new(status_definitions.get("debt")))
		run.set_inventory_slot(1, Upgrade.new(status_definitions.get("debt")))
	add_debuff_definition(m)
	
	# above debuff not appearing for some reason? TODO get better fix
	m = UpgradeDefinition.new()
	m.id = "debt2"
	m.display_name = ""
	m.description = "Replace your first 2 upgrades with Debt"
	m.base_chance = 1
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.set_inventory_slot(0, Upgrade.new(status_definitions.get("debt")))
		run.set_inventory_slot(1, Upgrade.new(status_definitions.get("debt")))
	add_debuff_definition(m)
	
	m.id = "expensive"
	m.display_name = ""
	m.description = "Increase cost mult by 0.5"
	m.base_chance = 1
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.cost_mult += 0.5
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "lose_money"
	m.display_name = ""
	m.description = "-150$ at the end of each round"
	m.base_chance = 1
	m.base_dur = -1
	m.round_end = func(run: Run, _upgrade: Upgrade):
		run.cash -= 150
	add_debuff_definition(m)
	
