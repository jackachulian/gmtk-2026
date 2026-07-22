class_name UpgradeHoverUI
extends Control

static var instance: UpgradeHoverUI

@export var buy_button: Control
@export var buy_cost_label: Control
@export var sell_button: Control
@export var sell_cost_label: Control

## Current upgrade panel this is showing for
var upgrade_panel: UpgradePanel

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	hide()
	
@warning_ignore("shadowed_variable")
func show_on_upgrade_panel(upgrade_panel: UpgradePanel) -> void:
	self.upgrade_panel = upgrade_panel
	global_position = upgrade_panel.global_position
	size = upgrade_panel.size
	
	show()
	buy_button.hide()
	sell_button.hide()
	
	if upgrade_panel.mode == UpgradePanel.Mode.SHOP_ITEM:
		buy_button.show()
		buy_cost_label.text = "$%d" % upgrade_panel.upgrade.cost
	
	elif upgrade_panel.mode == UpgradePanel.Mode.INVENTORY_ITEM:
		sell_button.show()
		sell_cost_label.text = "$%d" % upgrade_panel.upgrade.cost

func _on_buy_button_pressed() -> void:
	if upgrade_panel.mode == UpgradePanel.Mode.SHOP_ITEM:
		RunManager.run.buy_shop_item(upgrade_panel.index)
		
func _on_sell_button_pressed() -> void:
	if upgrade_panel.mode == UpgradePanel.Mode.INVENTORY_ITEM:
		RunManager.run.sell_inventory_item(upgrade_panel.index)
