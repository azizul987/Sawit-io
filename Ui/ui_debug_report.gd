class_name UIDebugReport
extends Node

## ".." berarti memeriksa parent UIDebugReport.
## Ubah menjadi "." jika script dipasang langsung pada SkillTreeUI.
@export var target_path: NodePath = NodePath("..")

## Jalankan laporan otomatis ketika scene dimulai.
@export var print_on_ready: bool = true


func _ready() -> void:
	if not print_on_ready:
		return

	# Tunggu layout Control dan Container selesai dihitung.
	await get_tree().process_frame
	await get_tree().process_frame

	print_ui_report()


func print_ui_report() -> void:
	var target: Node = get_node_or_null(target_path)

	if target == null:
		push_error(
			"UIDebugReport: target tidak ditemukan pada path: %s"
			% target_path
		)
		return

	print("")
	print("======================================================")
	print("               UI QUALITY DEBUG REPORT")
	print("======================================================")

	_print_engine_information()
	_print_project_settings()
	_print_main_viewport()
	_scan_node(target, 0)

	print("======================================================")
	print("                 END OF REPORT")
	print("======================================================")
	print("")


func _print_engine_information() -> void:
	var version: Dictionary = Engine.get_version_info()

	print("")
	print("[ENGINE]")
	print("Version          : ", version.get("string", "Unknown"))
	print("Renderer         : ", RenderingServer.get_current_rendering_method())
	print("Target Node      : ", get_node(target_path).get_path())


func _print_project_settings() -> void:
	print("")
	print("[PROJECT SETTINGS]")

	_print_setting("display/window/size/viewport_width")
	_print_setting("display/window/size/viewport_height")
	_print_setting("display/window/size/window_width_override")
	_print_setting("display/window/size/window_height_override")
	_print_setting("display/window/size/resizable")

	_print_setting("display/window/stretch/mode")
	_print_setting("display/window/stretch/aspect")
	_print_setting("display/window/stretch/scale")
	_print_setting("display/window/stretch/scale_mode")

	_print_setting("rendering/textures/default_filters/use_nearest_mipmap_filter")
	_print_setting("rendering/2d/snap/snap_2d_transforms_to_pixel")
	_print_setting("rendering/2d/snap/snap_2d_vertices_to_pixel")


func _print_setting(setting_name: String) -> void:
	if ProjectSettings.has_setting(setting_name):
		print(
			setting_name,
			" = ",
			ProjectSettings.get_setting(setting_name)
		)
	else:
		print(setting_name, " = [SETTING TIDAK DITEMUKAN]")


func _print_main_viewport() -> void:
	var viewport: Viewport = get_viewport()

	print("")
	print("[MAIN VIEWPORT]")
	print("Visible Rect Size : ", viewport.get_visible_rect().size)
	print("Texture Filter    : ", _get_property(viewport, "canvas_item_default_texture_filter"))
	print("MSAA 2D           : ", _get_property(viewport, "msaa_2d"))
	print("Screen AA         : ", _get_property(viewport, "screen_space_aa"))
	print("Snap Transforms   : ", _get_property(viewport, "snap_2d_transforms_to_pixel"))
	print("Snap Vertices     : ", _get_property(viewport, "snap_2d_vertices_to_pixel"))


func _scan_node(node: Node, depth: int) -> void:
	var indent: String = "  ".repeat(depth)

	print("")
	print(
		indent,
		"[NODE] ",
		node.get_path(),
		" | Type: ",
		node.get_class()
	)

	if node is CanvasItem:
		_print_canvas_item(node as CanvasItem, indent)

	if node is Control:
		_print_control(node as Control, indent)

	if node is SubViewportContainer:
		_print_subviewport_container(
			node as SubViewportContainer,
			indent
		)

	if node is SubViewport:
		_print_subviewport(node as SubViewport, indent)

	if node is Camera2D:
		_print_camera(node as Camera2D, indent)

	if node is Sprite2D:
		_print_sprite(node as Sprite2D, indent)

	if node is TextureRect:
		_print_texture_rect(node as TextureRect, indent)

	if node is TextureButton:
		_print_texture_button(node as TextureButton, indent)

	for child: Node in node.get_children():
		_scan_node(child, depth + 1)


func _print_canvas_item(item: CanvasItem, indent: String) -> void:
	print(indent, "  Visible         : ", item.visible)
	print(indent, "  Modulate        : ", item.modulate)
	print(indent, "  Self Modulate   : ", item.self_modulate)
	print(
		indent,
		"  Texture Filter  : ",
		_texture_filter_name(item.texture_filter),
		" (",
		item.texture_filter,
		")"
	)


func _print_control(control: Control, indent: String) -> void:
	print(indent, "  Size            : ", control.size)
	print(indent, "  Global Position : ", control.global_position)
	print(indent, "  Scale           : ", control.scale)
	print(indent, "  Rotation        : ", control.rotation_degrees)
	print(indent, "  Pivot Offset    : ", control.pivot_offset)
	print(indent, "  Minimum Size    : ", control.custom_minimum_size)

	print(
		indent,
		"  Anchors         : L=",
		control.anchor_left,
		" T=",
		control.anchor_top,
		" R=",
		control.anchor_right,
		" B=",
		control.anchor_bottom
	)

	print(
		indent,
		"  Offsets         : L=",
		control.offset_left,
		" T=",
		control.offset_top,
		" R=",
		control.offset_right,
		" B=",
		control.offset_bottom
	)

	print(
		indent,
		"  Size Flags      : H=",
		control.size_flags_horizontal,
		" V=",
		control.size_flags_vertical
	)

	print(indent, "  Clip Contents   : ", control.clip_contents)

	_print_scale_warning(control, indent)


func _print_subviewport_container(
	container: SubViewportContainer,
	indent: String
) -> void:
	print(indent, "  --- SUBVIEWPORT CONTAINER ---")
	print(indent, "  Stretch         : ", container.stretch)
	print(indent, "  Stretch Shrink  : ", container.stretch_shrink)
	print(indent, "  Container Size  : ", container.size)

	var subviewport: SubViewport = _find_direct_subviewport(container)

	if subviewport == null:
		print(indent, "  ERROR            : SubViewport tidak ditemukan")
		return

	var render_size: Vector2 = Vector2(subviewport.size)
	var display_size: Vector2 = container.size

	print(indent, "  Render Size     : ", render_size)
	print(indent, "  Display Size    : ", display_size)

	if render_size.x <= 0.0 or render_size.y <= 0.0:
		print(indent, "  ERROR            : Ukuran SubViewport nol")
		return

	var scale_ratio := Vector2(
		display_size.x / render_size.x,
		display_size.y / render_size.y
	)

	print(indent, "  Render Ratio    : ", scale_ratio)

	if container.stretch_shrink > 1:
		print(
			indent,
			"  WARNING          : Stretch Shrink lebih dari 1; ",
			"resolusi render dikurangi."
		)

	if not is_equal_approx(scale_ratio.x, scale_ratio.y):
		print(
			indent,
			"  WARNING          : Rasio X dan Y berbeda; ",
			"hasil dapat terdistorsi."
		)

	if not _is_near_integer(scale_ratio.x):
		print(
			indent,
			"  WARNING          : Skala horizontal pecahan: ",
			scale_ratio.x
		)

	if not _is_near_integer(scale_ratio.y):
		print(
			indent,
			"  WARNING          : Skala vertikal pecahan: ",
			scale_ratio.y
		)


func _print_subviewport(
	viewport: SubViewport,
	indent: String
) -> void:
	print(indent, "  --- SUBVIEWPORT ---")
	print(indent, "  Size            : ", viewport.size)
	print(indent, "  Transparent BG  : ", viewport.transparent_bg)
	print(indent, "  Render Target   : ", viewport.render_target_update_mode)
	print(
		indent,
		"  Texture Filter  : ",
		_get_property(viewport, "canvas_item_default_texture_filter")
	)
	print(indent, "  MSAA 2D         : ", _get_property(viewport, "msaa_2d"))
	print(indent, "  Screen AA       : ", _get_property(viewport, "screen_space_aa"))
	print(
		indent,
		"  Size Override   : ",
		_get_property(viewport, "size_2d_override")
	)
	print(
		indent,
		"  Override Stretch: ",
		_get_property(viewport, "size_2d_override_stretch")
	)


func _print_camera(camera: Camera2D, indent: String) -> void:
	print(indent, "  --- CAMERA 2D ---")
	print(indent, "  Enabled         : ", camera.enabled)
	print(indent, "  Position        : ", camera.position)
	print(indent, "  Global Position : ", camera.global_position)
	print(indent, "  Zoom            : ", camera.zoom)
	print(indent, "  Offset          : ", camera.offset)

	if not _is_near_integer(camera.zoom.x):
		print(
			indent,
			"  WARNING          : Camera zoom X pecahan: ",
			camera.zoom.x
		)

	if not _is_near_integer(camera.zoom.y):
		print(
			indent,
			"  WARNING          : Camera zoom Y pecahan: ",
			camera.zoom.y
		)


func _print_sprite(sprite: Sprite2D, indent: String) -> void:
	print(indent, "  --- SPRITE 2D ---")
	print(indent, "  Position        : ", sprite.position)
	print(indent, "  Scale           : ", sprite.scale)
	print(indent, "  Centered        : ", sprite.centered)
	print(indent, "  Pixel Snap      : ", sprite.pixel_snap)

	if sprite.texture != null:
		print(indent, "  Texture Path    : ", sprite.texture.resource_path)
		print(indent, "  Texture Size    : ", sprite.texture.get_size())
	else:
		print(indent, "  Texture         : NULL")


func _print_texture_rect(
	texture_rect: TextureRect,
	indent: String
) -> void:
	print(indent, "  --- TEXTURE RECT ---")
	print(indent, "  Stretch Mode    : ", texture_rect.stretch_mode)
	print(indent, "  Expand Mode     : ", texture_rect.expand_mode)

	if texture_rect.texture != null:
		print(
			indent,
			"  Texture Path    : ",
			texture_rect.texture.resource_path
		)
		print(
			indent,
			"  Texture Size    : ",
			texture_rect.texture.get_size()
		)
	else:
		print(indent, "  Texture         : NULL")


func _print_texture_button(
	button: TextureButton,
	indent: String
) -> void:
	print(indent, "  --- TEXTURE BUTTON ---")
	print(indent, "  Stretch Mode    : ", button.stretch_mode)
	print(indent, "  Ignore Size     : ", button.ignore_texture_size)

	if button.texture_normal != null:
		print(
			indent,
			"  Texture Path    : ",
			button.texture_normal.resource_path
		)
		print(
			indent,
			"  Texture Size    : ",
			button.texture_normal.get_size()
		)
	else:
		print(indent, "  Normal Texture  : NULL")


func _find_direct_subviewport(
	container: SubViewportContainer
) -> SubViewport:
	for child: Node in container.get_children():
		if child is SubViewport:
			return child as SubViewport

	return null


func _print_scale_warning(
	control: Control,
	indent: String
) -> void:
	if not is_equal_approx(control.scale.x, 1.0):
		print(
			indent,
			"  WARNING          : Control scale X bukan 1: ",
			control.scale.x
		)

	if not is_equal_approx(control.scale.y, 1.0):
		print(
			indent,
			"  WARNING          : Control scale Y bukan 1: ",
			control.scale.y
		)

	if not _is_near_integer(control.global_position.x):
		print(
			indent,
			"  WARNING          : Global X pecahan: ",
			control.global_position.x
		)

	if not _is_near_integer(control.global_position.y):
		print(
			indent,
			"  WARNING          : Global Y pecahan: ",
			control.global_position.y
		)


func _is_near_integer(value: float) -> bool:
	return is_equal_approx(value, round(value))


func _get_property(object: Object, property_name: String) -> Variant:
	for property: Dictionary in object.get_property_list():
		if property.get("name", "") == property_name:
			return object.get(property_name)

	return "[PROPERTY TIDAK TERSEDIA]"


func _texture_filter_name(filter_value: int) -> String:
	match filter_value:
		CanvasItem.TEXTURE_FILTER_PARENT_NODE:
			return "PARENT NODE"
		CanvasItem.TEXTURE_FILTER_NEAREST:
			return "NEAREST"
		CanvasItem.TEXTURE_FILTER_LINEAR:
			return "LINEAR"
		CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS:
			return "NEAREST + MIPMAPS"
		CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS:
			return "LINEAR + MIPMAPS"
		CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS_ANISOTROPIC:
			return "NEAREST + MIPMAPS + ANISOTROPIC"
		CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC:
			return "LINEAR + MIPMAPS + ANISOTROPIC"
		_:
			return "UNKNOWN"
