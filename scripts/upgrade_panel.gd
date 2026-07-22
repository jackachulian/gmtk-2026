class_name UpgradePanel
extends PanelContainer

@export var name_label: Label
@export var cost_label: Label

func setup(upgrade: Upgrade) -> void:
	name_label.text = upgrade.definition.description
	cost_label.text = "$%d" % upgrade.cost
