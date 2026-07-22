class_name RunManager
extends Node

## The current run. The current run will be initialized here as soon as the RunManager enters the tree,
## so that other nodes are free to connect to its signals in their Ready / Tree Enter methods
var run: Run

func _enter_tree() -> void:
	run = Run.new()
