extends HBoxContainer

@export var upgrade_panel_scene: PackedScene

enum UpgradeSource {
	Shop,
	Inventory
}
@export var upgrade_source: UpgradeSource

func _ready() -> void:
	var run := RunManager.run
	if upgrade_source == UpgradeSource.Shop:
		remake_panels(run.shop)
		run.shop_changed.connect(remake_panels.bind(run.shop))
	elif upgrade_source == UpgradeSource.Inventory:
		remake_panels(run.inventory)
		run.inventory_changed.connect(remake_panels.bind(run.inventory))
	
func remake_panels(upgrades: Array[Upgrade]) -> void:
	for child in get_children():
		child.queue_free()
	for upgrade in upgrades:
		if not upgrade: continue # empty slots
		var upgrade_panel = upgrade_panel_scene.instantiate() as UpgradePanel
		upgrade_panel.setup(upgrade)
		add_child(upgrade_panel)
