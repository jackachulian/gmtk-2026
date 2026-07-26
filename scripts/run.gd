class_name Run
extends Resource

const SHOP_SIZE := 5
const INVENTORY_SIZE := 7
const ROUND_DURATION := 40.0
const MODIFIER_CHOICE_COUNT := 3
const ROUND_START_REROLL_PRICE := 3
const REROLL_PRICE_INCREASE := 1
const CASH_PER_ROUND := 10

## Represents a phase a run can be in
enum Phase {
	## Timer is counting down, player can buy upgrades from the shop / sell from inventory
	COUNTDOWN,
	## Player is choosing a modifier to apply to their run
	CHOOSE_MODIFIER,
	## Timer reached 0 and game over screen is showing
	GAME_LOST
}
## Current phase of the game
var phase: Phase
signal phase_changed()

## Current round number
var round_number: int = 1

## Amount of time remaining in the round
var round_timer: float

## Amount of time remaining in the countdown, in seconds
var time: int = 20

## Player's owned cash that can be used to buy upgrades from the shop
var cash: int = 30

## Multiplier for shop prices
var cost_mult: float = 1.0

# Fixed offset to durability of shop items
var durability_mod: int = 0

## Current price to refresh the shop
var reroll_price: int = 3

## Current amount of ticks per real-world second
## (Used by the RunManager for real-world timing)
var tick_rate: float = 1.0

## Current amount of seconds until the next tick
var tick_timer: float = 1.0

## Current timer second decrease of a single countdown tick
var tick_amount: int = 1

## Amount of ticks passed this game
var tick_count: int = 0

var countdown_mult: float = 1.0

## Exported in run manager
var tick_sfx: Array[AudioStream] = []

## Currently owned upgrades
var inventory: Array[Upgrade] = []
signal inventory_changed()

## Upgrades in the shop
var shop: Array[Upgrade] = []
signal shop_changed()

## List of modifiers that can be chosen to affect the run during CHOOSE_MODIFIER phase
var modifier_choices: Array[Upgrade] = []
signal modifier_choices_changed()

## List of modifiers that have been chosen and are affecting the run
var modifiers: Array[Upgrade] = []
signal modifiers_changed()

## Public wrapper for tick function used by some upgrades to "force" ticks
func runner_force_tick() -> void:
	_do_tick(true);
	
var sfx_player: AudioStreamPlayer = null;

var upgrade_inventory: UpgradePanelList = null;
var modifier_inventory: UpgradePanelList = null;
var tick_animator: AnimationPlayer = null;

func _init(node: Node, _upgrade_inventory: UpgradePanelList, _modifier_inventory: UpgradePanelList, _tick_animator: AnimationPlayer) -> void:
	tick_count = 0
	inventory.resize(INVENTORY_SIZE)
	shop.resize(INVENTORY_SIZE)
	reroll_price = ROUND_START_REROLL_PRICE
	round_number = 1
	cost_mult = 1.0
	sfx_player = node.get_node("TickAudioPlayer");
	tick_sfx = node.tick_sfx
	upgrade_inventory = _upgrade_inventory
	modifier_inventory = _modifier_inventory
	tick_animator = _tick_animator
	countdown_mult = 1.0
	durability_mod = 0
	start_countdown_phase()
	
func start_countdown_phase() -> void:
	phase = Phase.COUNTDOWN
	round_timer = ROUND_DURATION
	refresh_shop()
	phase_changed.emit()
	
func start_choose_modifier_phase() -> void:
	phase = Phase.CHOOSE_MODIFIER
	
	# Round end logic
	for index in inventory.size():
		var upgrade = inventory[index]
		if upgrade: upgrade.round_end(self)
		
	for index in modifiers.size():
		print("round end")
		var upgrade = modifiers[index]
		if upgrade: upgrade.round_end(self)
	
	#if (round_number % 2 == 0):
		#tick_amount += 1
	#else:
		#tick_rate += 0.25
	round_number += 1
	cash += 5 * round_number
	countdown_mult += 1.0
	tick_rate += 0.25
	
	shop.clear()
	shop_changed.emit()
	
	reroll_price = ROUND_START_REROLL_PRICE
	
	var definitions := UpgradeManager.modifier_definitions
	var pool := definitions.values().duplicate()
	
	var mod_debuffs = []
	var debuff_pool := UpgradeManager.debuff_definitions.values().duplicate()
	for i in MODIFIER_CHOICE_COUNT:
		var pool_idx := randi_range(0, debuff_pool.size()-1)
		mod_debuffs.push_front(
			Upgrade.new(debuff_pool[pool_idx]
		))
		print(pool_idx)
	modifier_choices.clear()
	for i in mini(MODIFIER_CHOICE_COUNT, pool.size()):
		var pool_index := randi_range(0, pool.size()-1)
		var def: UpgradeDefinition = pool[pool_index]
		
		var matching_upgrade: Upgrade = null
		for upgrade in modifiers:
			if upgrade.definition.id == def.id:
				matching_upgrade = upgrade
				break
		
		var upgrade := Upgrade.new(def)
		if matching_upgrade:
			upgrade.level = matching_upgrade.level + 1
			upgrade.chance = matching_upgrade.chance + upgrade.chance
		
		print("arg" + str(i))
		upgrade.attached_upgrade = mod_debuffs[i]
		modifier_choices.append(upgrade)
		pool.remove_at(pool_index)
	
	modifier_choices_changed.emit()
	phase_changed.emit()

func game_over() -> void:
	phase = Phase.GAME_LOST

## Perform rick timing calculations.
## RunManager will call this in its _process() loop
func process(delta: float) -> void:
	## Only tick down the timer when in countdown phase
	if phase == Phase.COUNTDOWN:
		tick_timer -= delta
		var iterations: int = 0
		while tick_timer <= 0:
			tick_timer += (1.0/tick_rate)
			_do_tick(false)
			
			iterations += 1
			if iterations > 500:
				push_error("Very long loop detected; ending loop!")
				break
				
		round_timer -= delta
		
		if round_timer <= 0.0 :
			start_choose_modifier_phase()


func do_upgrade_trigger_effect(index: int, forced: bool) -> void:
	var upgrade = inventory[index]
	upgrade_inventory.play_upgrade_anim(index, "trigger")
	if upgrade.definition.base_dur > -1:
		upgrade.durability -= 1;
		upgrade_inventory.update_dur_label(index, upgrade.durability)
		
		# break item
		# TODO animation for this
		if upgrade.durability <= 0:
			inventory[index] = null
			upgrade.sell(self)
			inventory_changed.emit()

func _do_tick(forced: bool) -> void:
	if (!forced): tick_count += 1
	#if (!forced): cash += 1
	
	sfx_player.stream = tick_sfx[tick_count % len(tick_sfx)]
	sfx_player.play();
	tick_animator.play("tick")
	time -= 1 + (max(round_number - 2, 0))
	
	for index in inventory.size():
		var upgrade = inventory[index]
		if upgrade:
			# This block only runs if item was triggered
			if await upgrade.tick(self, forced):
				do_upgrade_trigger_effect(index, false)
						
	for index in modifiers.size():
		var upgrade = modifiers[index]
		if upgrade:
			if await upgrade.tick(self, forced):
				modifier_inventory.play_upgrade_anim(index, "trigger")
			
	if time <= 0:
		game_over()
		

func set_inventory_slot(slot: int, upgrade: Upgrade):
	inventory[slot] = upgrade
	inventory_changed.emit()

	
func set_shop_slot(slot: int, upgrade: Upgrade):
	shop[slot] = upgrade
	shop[slot].cost *= cost_mult
	upgrade.durability += durability_mod
	shop_changed.emit()
	
func get_non_battery_inventory_indexes() -> Array[int]:
	var arr: Array[int] = []
	for i: int in inventory.size():
		var upg = inventory[i]
		if upg != null && upg.definition.id != "battery":
			arr.push_front(i)
	print(arr)
	return arr
	
## Returns true if successfully purchased
func buy_shop_item(slot: int) -> bool:
	var upgrade := shop[slot]
	if not upgrade:
		push_error("No upgrade in shop slot ",slot)
		return false
	
	if cash < upgrade.cost: 
		push_error("Not enough cash")
		return false
	
	## Add to first open slot
	var inventory_slot := get_first_open_inventory_slot()
	if inventory_slot == -1:
		push_error("Inventory is full")
		return false
		
	shop[slot] = null
	inventory[inventory_slot] = upgrade
	upgrade.inventory_slot = inventory_slot
	cash -= upgrade.cost
	## Upon buying, halve the upgrade's cost (which is now sell price) and round up
	upgrade.cost = roundi(upgrade.cost / 2.0)
	
	upgrade.buy(self)
	
	shop_changed.emit()
	inventory_changed.emit()
	upgrade_inventory.play_upgrade_anim(inventory_slot, "add_to_inv")
	
	return true
	
func sell_inventory_item(slot: int) -> bool:
	var upgrade := inventory[slot]

	if not upgrade:
		push_error("No upgrade in inventory slot ",slot)
		return false
		
	if !upgrade.can_be_sold: return false
		
	inventory[slot] = null
	cash += upgrade.cost
	
	upgrade.sell(self)
	
	inventory_changed.emit()
		
	return true
	
## Return the first unoccupied inventory slot, or -1 if all are occupied.
func get_first_open_inventory_slot() -> int:
	for i in inventory.size():
		if inventory[i] == null:
			return i
	return -1
	
func get_owned_upgrade_count() -> int:
	var c = get_first_open_inventory_slot()
	return c if c != -1 else INVENTORY_SIZE 
	
func refresh_shop() -> void:
	## TODO: maybe make this vary?
	var current_shop_size := 3
	
	shop.clear()
	shop.resize(current_shop_size)
	
	var commons: Array = UpgradeManager.definitions_by_rarity[0].duplicate()
	var uncommons: Array = UpgradeManager.definitions_by_rarity[1].duplicate()
	var rares: Array = UpgradeManager.definitions_by_rarity[2].duplicate()
	
	for i in current_shop_size:
		var pool: Array = []
		var rand := randf()
		
		# If the last pool reached was empty, or there is no pool reached yet,
		# use the next rarity level lower than current 
		if rand <= 0.1:
			pool = rares
		if pool.is_empty() and rand <= 0.4:
			pool = uncommons
		if pool.is_empty():
			pool = commons
			
		if pool.is_empty(): # If there are no commons, try going back up to uncommons
			pool = uncommons
		if pool.is_empty(): # If there are no uncommons, try going back up to rares
			pool = rares
		if pool.is_empty(): # If there are no rares, there are no more cards
			break
	
		var pool_index := randi_range(0, pool.size()-1)
		var def: UpgradeDefinition = pool[pool_index]
		var upgrade := Upgrade.new(def)
		shop[i] = upgrade
		shop[i].cost *= clampf(cost_mult, 0.20, 5)
		shop[i].durability += durability_mod
		#pool.remove_at(pool_index)
		
	shop_changed.emit()
	
func pay_to_reroll_shop() -> bool:
	if cash < reroll_price:
		push_error("Not enough cash to reroll")
		return false
		
	cash -= reroll_price
	refresh_shop()
	reroll_price += REROLL_PRICE_INCREASE
	return true
	
## Use during CHOOSE_MODIFIER phase to choose a modifier to permanently add to the run.
## Countdown phase is started right after the choice is made
func choose_modifier(slot: int) -> bool:
	var modifier_choice := modifier_choices[slot]

	for i in modifiers.size():
		var modifier := modifiers[i]
		if modifier.definition.id == modifier_choice.definition.id:
			modifier.sell(self) # "Sell" event is used as an on remove for modifiers
			modifiers.remove_at(i)
			break
	
	modifiers.append(modifier_choice)
	modifiers.append(modifier_choice.attached_upgrade)
	modifier_choice.buy(self) # "Buy" event is used as an on add for modifiers
	modifier_choice.attached_upgrade.buy.call(self)
	
	modifiers_changed.emit()
	
	start_countdown_phase()
	return true
