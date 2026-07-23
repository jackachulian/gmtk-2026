class_name UpgradePanel
extends Control

@export var name_label: Label
@export var description_label: Label
@export var cost_label: Label

var upgrade: Upgrade

enum Mode {
	INVENTORY,
	SHOP,
	MODIFIER_CHOICE,
	MODIFIER
}
var mode: Mode

## Slot index in inventory or shop
var index: int

func _exit_tree() -> void:
	if (UpgradeHoverUI.instance and UpgradeHoverUI.instance.upgrade_panel == self):
		UpgradeHoverUI.instance.hide()

@warning_ignore("shadowed_variable")
func setup(upgrade: Upgrade, mode: Mode, index: int) -> void:
	self.upgrade = upgrade
	self.mode = mode
	self.index = index
	if name_label: name_label.text = upgrade.definition.display_name
	if description_label: description_label.text = upgrade.get_parsed_description()
	if cost_label: cost_label.text = "$%d" % upgrade.cost
	
func _on_mouse_entered() -> void:
	UpgradeHoverUI.instance.show_on_upgrade_panel(self)
	
func _on_mouse_exited() -> void:
	pass
	#if (UpgradeHoverUI.instance.upgrade_panel == self):
		#UpgradeHoverUI.instance.hide()

## Used in the modifier panel list only
func _on_select_button_pressed() -> void:
	RunManager.run.choose_modifier(index)
