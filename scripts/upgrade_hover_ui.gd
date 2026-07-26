class_name UpgradeHoverUI
extends Control

static var instance: UpgradeHoverUI

@export var buy_button: Control
@export var buy_cost_label: Control
@export var sell_button: Control
@export var sell_cost_label: Control

@export var buy_sfx: AudioStreamPlayer
@export var sell_sfx: AudioStreamPlayer

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
	
	if upgrade_panel.mode == UpgradePanel.Mode.SHOP:
		buy_button.show()
		buy_cost_label.text = "$%d" % upgrade_panel.upgrade.cost
	
	elif upgrade_panel.mode == UpgradePanel.Mode.INVENTORY && upgrade_panel.upgrade.can_be_sold:
		sell_button.show()
		sell_cost_label.text = "$%d" % upgrade_panel.upgrade.cost

func _on_buy_button_pressed() -> void:
	if upgrade_panel.mode == UpgradePanel.Mode.SHOP:
		if RunManager.run.buy_shop_item(upgrade_panel.index):
			buy_sfx.pitch_scale = pow(1.059463, randi_range(0, 4))
			buy_sfx.play()
			
	else:
		push_error("This is not a shop item")
		
func _on_sell_button_pressed() -> void:
	if upgrade_panel.mode == UpgradePanel.Mode.INVENTORY:
		if RunManager.run.sell_inventory_item(upgrade_panel.index):
			sell_sfx.play()
	else:
		push_error("This is not an inventory item")
