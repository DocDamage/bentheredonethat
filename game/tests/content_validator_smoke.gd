extends Node

const ContentValidatorScript := preload("res://ben_rpg/core/content_validator.gd")


func _ready() -> void:
	var errors := ContentValidatorScript.validate_all()
	for error in errors:
		push_error(error)
	assert(errors.is_empty(), "Content validation failed with %d error(s)." % errors.size())
	print("CONTENT VALIDATOR SMOKE PASSED")
	get_tree().quit()
