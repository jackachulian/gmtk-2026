class_name RunManager
extends Node



## The current run. The current run will be initialized here as soon as the RunManager enters the tree,
## so that other nodes are free to connect to its signals in their Ready / Tree Enter methods
static var run: Run

func _enter_tree() -> void:
	run = Run.new()
	
	## TEMP: add a testing upgarde to inventory
	var sec30 := UpgradeManager.instantiate_upgrade("boosterI")
	run.set_inventory_slot(0, sec30)

func _physics_process(delta: float) -> void:
	run.process(delta)
