class_name VisualCaptureGuard
extends RefCounted

## Native visual review needs an actual rendered frame. Godot's headless dummy
## renderer can return a viewport texture whose image is null, so capture scenes
## must treat either condition as a hard failure instead of writing an empty
## baseline and continuing to their success message.

static func save_viewport_png(viewport: Viewport, path: String, label: String) -> bool:
	var viewport_texture := viewport.get_texture()
	if not viewport_texture:
		push_error("%s requires a rendered viewport; rerun with -Windowed." % label)
		return false
	var image := viewport_texture.get_image()
	if not image:
		push_error("%s could not read the rendered viewport image; rerun with -Windowed." % label)
		return false
	var error := image.save_png(path)
	if error != OK:
		push_error("%s could not save %s: %s" % [label, path, error_string(error)])
		return false
	return true
