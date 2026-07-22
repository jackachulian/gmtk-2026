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
		remake_panels(run.shop, UpgradePanel.Mode.SHOP_ITEM)
		run.shop_changed.connect(remake_panels.bind(run.shop, UpgradePanel.Mode.SHOP_ITEM))
	elif upgrade_source == UpgradeSource.Inventory:
		remake_panels(run.inventory, UpgradePanel.Mode.INVENTORY_ITEM)
		run.inventory_changed.connect(remake_panels.bind(run.inventory, UpgradePanel.Mode.INVENTORY_ITEM))
	
func remake_panels(upgrades: Array[Upgrade], mode: UpgradePanel.Mode) -> void:
	for child in get_children():
		child.queue_free()
	for i in upgrades.size():
		var upgrade: Upgrade = upgrades[i]
		if not upgrade: continue # empty slots
		var upgrade_panel = upgrade_panel_scene.instantiate() as UpgradePanel
		upgrade_panel.setup(upgrade, mode, i)
		add_child(upgrade_panel)
