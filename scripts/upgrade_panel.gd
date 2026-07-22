class_name UpgradePanel
extends PanelContainer

@export var name_label: Label
@export var cost_label: Label

var upgrade: Upgrade

enum Mode {
	INVENTORY_ITEM,
	SHOP_ITEM
}
var mode: Mode

## Slot index in inventory or shop
var index: int

func _exit_tree() -> void:
	if (UpgradeHoverUI.instance.upgrade_panel == self):
		UpgradeHoverUI.instance.hide()

@warning_ignore("shadowed_variable")
func setup(upgrade: Upgrade, mode: Mode, index: int) -> void:
	self.upgrade = upgrade
	self.mode = mode
	self.index = index
	name_label.text = upgrade.definition.description
	cost_label.text = "$%d" % upgrade.cost
	
func _on_mouse_entered() -> void:
	UpgradeHoverUI.instance.show_on_upgrade_panel(self)
	
func _on_mouse_exited() -> void:
	pass
	#if (UpgradeHoverUI.instance.upgrade_panel == self):
		#UpgradeHoverUI.instance.hide()
