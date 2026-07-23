class_name UpgradePanelList
extends Control

@export var upgrade_panel_scene: PackedScene

enum UpgradeSource {
	SHOP,
	INVENTORY,
	MODIFIER_CHOICES,
	MODIFIERS
}
@export var upgrade_source: UpgradeSource

func _ready() -> void:
	var run := RunManager.run
	if upgrade_source == UpgradeSource.SHOP:
		remake_panels(run.shop, UpgradePanel.Mode.SHOP)
		run.shop_changed.connect(remake_panels.bind(run.shop, UpgradePanel.Mode.SHOP))
	elif upgrade_source == UpgradeSource.INVENTORY:
		remake_panels(run.inventory, UpgradePanel.Mode.INVENTORY)
		run.inventory_changed.connect(remake_panels.bind(run.inventory, UpgradePanel.Mode.INVENTORY))
	elif upgrade_source == UpgradeSource.MODIFIER_CHOICES:
		remake_panels(run.modifier_choices, UpgradePanel.Mode.MODIFIER_CHOICE)
		run.modifier_choices_changed.connect(remake_panels.bind(run.modifier_choices, UpgradePanel.Mode.MODIFIER_CHOICE))
	elif upgrade_source == UpgradeSource.MODIFIERS:
		remake_panels(run.modifiers, UpgradePanel.Mode.MODIFIER)
		run.modifiers_changed.connect(remake_panels.bind(run.modifiers, UpgradePanel.Mode.MODIFIER))
	
func remake_panels(upgrades: Array[Upgrade], mode: UpgradePanel.Mode) -> void:
	for child in get_children():
		child.queue_free()
	for i in upgrades.size():
		var upgrade: Upgrade = upgrades[i]
		if not upgrade: continue # empty slots
		var upgrade_panel = upgrade_panel_scene.instantiate() as UpgradePanel
		upgrade_panel.setup(upgrade, mode, i)
		add_child(upgrade_panel)
