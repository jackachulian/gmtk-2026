class_name UpgradePanel
extends Control

@export var name_label: Label
@export var level_label: Label
@export var description_label: Label
@export var cost_label: Label
@export var icon: Sprite2D

@export var card_panel_container: PanelContainer
@export var common_stylebox: StyleBox
@export var uncommon_stylebox: StyleBox
@export var rare_stylebox: StyleBox
@export var animation_player: AnimationPlayer

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
	if level_label: level_label.text = "Lv. %d" % upgrade.level
	if description_label: description_label.text = upgrade.get_parsed_description()
	if cost_label: cost_label.text = "$%d" % upgrade.cost
	if icon: icon.texture = upgrade.icon
	
	if card_panel_container:
		if upgrade.definition.rarity == 0:
			card_panel_container.add_theme_stylebox_override("panel", common_stylebox)
		elif upgrade.definition.rarity == 1:
			card_panel_container.add_theme_stylebox_override("panel", uncommon_stylebox)
		elif upgrade.definition.rarity == 2:
			card_panel_container.add_theme_stylebox_override("panel", rare_stylebox)
	
func _on_mouse_entered() -> void:
	UpgradeHoverUI.instance.show_on_upgrade_panel(self)
	description_label.show()
	if name_label: name_label.hide()
	if icon: icon.hide()
	
func _on_mouse_exited() -> void:
	description_label.hide()
	if name_label: name_label.show()
	if icon: icon.show()
	#if (UpgradeHoverUI.instance.upgrade_panel == self):
		#UpgradeHoverUI.instance.hide()

## Used in the modifier panel list only
func _on_select_button_pressed() -> void:
	RunManager.run.choose_modifier(index)
