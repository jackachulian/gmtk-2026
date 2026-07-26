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
	generate_modifier_definitions(get_tree().root.get_child(0))
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
	u.icon = preload("res://graphics/icons/borrow.png")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "boosterI"
	u.display_name = "Booster I"
	u.description = "Each tick, [chance]% chance of +3 seconds"
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
	u.trigger_sfx = preload("res://audio/talk-aqua.wav")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "boosterII"
	u.display_name = "Booster II"
	u.description = "Each tick, [chance]% chance of +15 seconds"
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
	u.trigger_sfx = preload("res://audio/talk-aqua.wav")
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		run.time += 15
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "moneyI"
	u.display_name = "Money I"
	u.description = "Each tick, [chance]% chance of +$2"
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
	u.trigger_sfx = preload("res://audio/talk-generic.wav")
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void: run.cash += 2
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "moneyII"
	u.display_name = "Money II"
	u.description = "Each tick, [chance]% chance of +$5"
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
	u.trigger_sfx = preload("res://audio/talk-generic.wav")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "drainI"
	u.display_name = "Money Drain I"
	u.description = "Each tick, [chance]% chance of -$5 and +20 seconds"
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
	u.icon = preload("res://graphics/icons/drain.png")
	u.trigger_sfx = preload("res://audio/talk-aqua.wav")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "drainII"
	u.display_name = "Money Drain II"
	u.description = "Each tick, [chance]% chance of -$10 and +50 seconds"
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
	u.icon = preload("res://graphics/icons/drain.png")
	u.trigger_sfx = preload("res://audio/talk-aqua.wav")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "doubleI"
	u.display_name = "Double Tick"
	u.description = "Each tick, [chance]% chance of +1 second and force additional tick"
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
	u.description = "Each tick, [chance]% chance of +1 second and force 2 additional ticks"
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
	u.description = "+40$, removes 60$ when sold. +20$ on force-trigger."
	u.base_cost = 0
	u.base_dur = 6
	u.rarity = 0
	
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void: run.cash += 20
	u.buy = func(run: Run, _upgrade: Upgrade): run.cash += 40
	u.sell = func(run: Run, _upgrade: Upgrade): run.cash -= 60
	u.icon = preload("res://graphics/icons/loan.png")
	u.trigger_sfx = preload("res://audio/fall_new.mp3")
	add_upgrade_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "battery"
	u.display_name = "Battery"
	u.description = "Each tick, [chance]% chance of force-triggering 2 random upgrades"
	u.base_chance = 15
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
	u.icon = preload("res://graphics/icons/battery.png")
	u.trigger_sfx = preload("res://audio/select.wav")
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
	u.rarity = -1
	u.can_be_sold = false
	u.icon = preload("res://graphics/icons/rock.png")
	u.trigger_sfx = preload("res://audio/57_drop.wav")
	add_status_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "debt"
	u.display_name = "Debt"
	u.description = "Cannot be sold. On force-trigger, lose 20$."
	u.base_cost = 0
	u.base_dur = 10
	u.rarity = -1
	u.can_be_sold = false
	u.icon = preload("res://graphics/icons/debt.png")
	u.trigger_sfx = preload("res://audio/57_drop.wav")
	u.trigger = func(run: Run, _upgrade: Upgrade, forced: bool) -> void:
		if run.cash >= 0: 
			run.cash = max(run.cash - 20, 0)
	
	add_status_definition(u)


# TODO make this use the tick/trigger system instead of just tick
func generate_modifier_definitions(node: Node) -> void:
	modifier_definitions.clear()
	
	var m: UpgradeDefinition
	
	m = UpgradeDefinition.new()
	m.id = "trigger_wave"
	m.display_name = "Trigger Wave"
	m.description = "Each natural tick, [chance]% chance to trigger all upgrades."
	m.base_chance = 8
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		pass
		#run.cost_mult += 0.5
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
	m.id = "melter"
	m.display_name = "Melter"
	m.description = "Each tick, [chance]% chance trigger your first upgrade 4 times."
	m.base_chance = 6
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		pass
		#run.cost_mult += 0.5
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		if randi_range(1,100) <= upgrade.chance:
			var idx: int = -1
			for _idx in run.inventory.size():
				idx = _idx
				if run.inventory[idx]: break
			for i in range(4):
				if  run.inventory[idx]:
					run.inventory[idx].definition.trigger.call(run, upgrade, true)
					run.do_upgrade_trigger_effect(idx, true)
					await node.get_tree().create_timer(0.075).timeout
			return true
		return false
	m.round_end = func(run: Run, upgrade: Upgrade):
		pass
	add_modifier_definition(m)
	
	#m = UpgradeDefinition.new()
	#m.id = "swapper"
	#m.display_name = "Swapper"
	#m.description = "Each tick, [chance]% chance to swap minutes and seconds"
	#m.base_chance = 1
	#m.base_dur = -1
	#m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		#if randi_range(1,100) <= upgrade.chance:
			#@warning_ignore("integer_division") var days := run.time / 86400
			#@warning_ignore("integer_division") var hours := (run.time % 86400) / 3600
			#@warning_ignore("integer_division") var minutes := (run.time % 3600) / 60
			#var seconds := run.time % 60
			#run.time = days*86400 + hours*3600 + seconds*60 + minutes
			#return true
		#return false
	#add_modifier_definition(m)
		
	m = UpgradeDefinition.new()
	m.id = "passive_income"
	m.display_name = "Passive Income"
	m.description = "Each tick, +[chance]$."
	m.base_chance = 3
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		pass
		#for i in run.inventory.size():
			#run.sell_inventory_item(i)
		#run.set_inventory_slot(run.get_first_open_inventory_slot(), Upgrade.new(status_definitions.get("rock")))
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		run.cash += m.base_chance
		return true
	add_modifier_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "sturdy"
	m.display_name = "Sturdy"
	m.description = "+2 to durability bonus."
	m.base_chance = 2
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.durability_mod += 2
	add_modifier_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "charged"
	m.display_name = "Supercharged"
	m.description = "+[chance] to base durability of Battery."
	m.base_chance = 3
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		print(UpgradeManager.upgrade_definitions["battery"].base_dur)
		run.battery_dur_mod = _upgrade.chance
		print(UpgradeManager.upgrade_definitions["battery"].base_dur)
	add_modifier_definition(m)
	
	
	
	# ===========
	# Debuffs
	# ===========
	#m = UpgradeDefinition.new()
	#m.id = "debt"
	#m.display_name = ""
	#m.description = "Replace your first upgrade with Debt"
	#m.base_chance = 1
	#m.base_dur = -1
	#m.buy = func(run: Run, _upgrade: Upgrade):
		#run.set_inventory_slot(0, Upgrade.new(status_definitions.get("debt")))
	#add_debuff_definition(m)
	
	# above debuff not appearing for some reason? TODO get better fix
	m = UpgradeDefinition.new()
	m.id = "debt2"
	m.display_name = ""
	m.description = "Replace your first upgrade with Debt"
	m.base_chance = 0
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.set_inventory_slot(0, Upgrade.new(status_definitions.get("debt")))
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "rock_debuff"
	m.display_name = ""
	m.description = "Replace your first two upgrades with Rocks"
	m.base_chance = 0
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.set_inventory_slot(0, Upgrade.new(status_definitions.get("rock")))
		run.set_inventory_slot(1, Upgrade.new(status_definitions.get("rock")))
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "expensive"
	m.display_name = ""
	m.description = "Increase cost mult by 0.5"
	m.base_chance = 0
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.cost_mult += 0.5
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "expensive2"
	m.display_name = ""
	m.description = "Increase cost mult by 1.0"
	m.base_chance = 0
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.cost_mult += 1.0
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "lose_money"
	m.display_name = ""
	m.description = "-150$ at the end of each round"
	m.base_chance = 1
	m.base_dur = -1
	m.round_end = func(run: Run, _upgrade: Upgrade):
		run.cash = max(run.cash - 150, 0)
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "half_time"
	m.display_name = ""
	m.description = "Halves time at the end of each round"
	m.base_chance = 1
	m.base_dur = -1
	m.round_end = func(run: Run, _upgrade: Upgrade):
		run.time = round(run.time * 0.5)
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "deduct_time"
	m.display_name = ""
	m.description = "-2 minutes at the end of each round"
	m.base_chance = 1
	m.base_dur = -1
	m.round_end = func(run: Run, _upgrade: Upgrade):
		run.time -= 120
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "deduct_time_tick"
	m.display_name = ""
	m.description = "Each tick, 1% chance to lose 30 seconds"
	m.base_chance = 1
	m.base_dur = -1
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		if randi_range(1,100) == 1:
			run.time -= 30
			return true
		return false
	add_debuff_definition(m)
	m.trigger_sfx = preload("res://audio/57_drop.wav")
	
	m = UpgradeDefinition.new()
	m.id = "half_time_tick"
	m.display_name = ""
	m.description = "Each tick, 0.5% chance to cut time in half"
	m.base_chance = 1
	m.base_dur = -1
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		if randi_range(1,200) == 1:
			run.time = round(run.time * 0.5)
			return true
		return false
	m.trigger_sfx = preload("res://audio/57_drop.wav")
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "lose_money_tick"
	m.display_name = ""
	m.description = "Each tick, 1% chance to lose 100$"
	m.base_chance = 1
	m.base_dur = -1
	m.tick = func(run: Run, upgrade: Upgrade, forced: bool) -> bool:
		if randi_range(1,100) == 1:
			run.cash = max(run.cash - 100, 0)
			return true
		return false
	m.trigger_sfx = preload("res://audio/57_drop.wav")
	add_debuff_definition(m)
	
	m = UpgradeDefinition.new()
	m.id = "dur_debuff"
	m.display_name = ""
	m.description = "-1 to durability bonus."
	m.base_chance = 0
	m.base_dur = -1
	m.buy = func(run: Run, _upgrade: Upgrade):
		run.durability_mod -= 1
	add_debuff_definition(m)
	
