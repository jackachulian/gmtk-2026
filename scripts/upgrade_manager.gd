class_name UpgradeManager
extends Node

static var definitions: Dictionary[String, UpgradeDefinition] = {}

func _enter_tree() -> void:
	generate_definitions()

static func instantiate_upgrade(definition_id: String) -> Upgrade:
	var definition: UpgradeDefinition = definitions.get(definition_id)
	if not definition:
		push_error("Missing upgrade definition ID: ", definition_id)
		return null
	return Upgrade.new(definition)

static func add_definition(def: UpgradeDefinition) -> void:
	definitions[def.id] = def
	
static func generate_definitions() -> void:
	definitions.clear()
	
	var u: UpgradeDefinition
	
	u = UpgradeDefinition.new()
	u.id = "sec30"
	u.display_name = "+30 Seconds"
	u.description = "Buy: +30 seconds\nSell: -30 seconds"
	u.base_cost = 5
	u.rarity = 0
	u.buy = func(run: Run, _upgrade: Upgrade): run.time += 30
	u.sell = func(run: Run, _upgrade: Upgrade): run.time -= 30
	add_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "boosterI"
	u.display_name = "Booster I"
	u.description = "Per second, 25% chance of +5 seconds"
	u.base_cost = 5
	u.rarity = 0
	u.tick = func(run: Run, _upgrade: Upgrade): if randf() <= 0.25: run.time += 5
	add_definition(u)
	
	u = UpgradeDefinition.new()
	u.id = "boosterII"
	u.display_name = "Booster II"
	u.description = "Per second, 10% chance of +20 seconds"
	u.base_cost = 10
	u.rarity = 0
	u.tick = func(run: Run, _upgrade: Upgrade): if randf() <= 0.1: run.time += 20
	add_definition(u)
