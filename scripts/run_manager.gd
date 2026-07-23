class_name RunManager
extends Node



## The current run. The current run will be initialized here as soon as the RunManager enters the tree,
## so that other nodes are free to connect to its signals in their Ready / Tree Enter methods
static var run: Run

## True while the game is paused and the pause menu is open
static var paused: bool = false

@export var tick_sfx: Array[AudioStream] = []
@export var upgrade_inventory: UpgradePanelList = null
@export var modifier_inventory: UpgradePanelList = null
@export var tick_rate_animator: AnimationPlayer

func _enter_tree() -> void:
	run = Run.new(self, upgrade_inventory, modifier_inventory, tick_rate_animator)

func _physics_process(delta: float) -> void:
	if not paused:
		run.process(delta)
