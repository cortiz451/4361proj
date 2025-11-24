extends Control

func _preselect_resolution(window : Window) -> void:
	%ResolutionControl.value = window.size

func _update_resolution_options_enabled(window : Window) -> void:
	if OS.has_feature("web"):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for web"
	elif AppSettings.is_fullscreen(window):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for fullscreen"
	else:
		%ResolutionControl.editable = true
		%ResolutionControl.tooltip_text = "Select a screen size"

func _update_ui(window : Window) -> void:
	%FullscreenControl.value = AppSettings.is_fullscreen(window)
	_preselect_resolution(window)
	%VSyncControl.value = AppSettings.get_vsync(window)
	_update_resolution_options_enabled(window)
	
	#I added these :)
	var fov: float = PlayerConfig.get_config(AppSettings.VIDEO_SECTION, "FOV", 90.0)
	_on_fov_control_setting_changed(fov)
	$VBoxContainer/FOVControl/HSlider.value=fov
	
	var rs: float = PlayerConfig.get_config(AppSettings.VIDEO_SECTION, "ResolutionScale", 1.00)
	_on_resolution_scale_control_setting_changed(rs)
	$VBoxContainer/ResScaleSlider/HSlider.value=rs
	

func _ready() -> void:
	var window : Window = get_window()
	_update_ui(window)
	window.connect("size_changed", _preselect_resolution.bind(window))

func _on_fullscreen_control_setting_changed(value) -> void:
	var window : Window = get_window()
	AppSettings.set_fullscreen_enabled(value, window)
	_update_resolution_options_enabled(window)

func _on_resolution_control_setting_changed(value) -> void:
	AppSettings.set_resolution(value, get_window(), false)

func _on_v_sync_control_setting_changed(value) -> void:
	AppSettings.set_vsync(value, get_window())

func _on_fov_control_setting_changed(value: Variant) -> void:
	PlayerConfig.set_config(AppSettings.VIDEO_SECTION, "FOV", value)
	$VBoxContainer/FOV.text=("(%.1f)" % value)

func _on_resolution_scale_control_setting_changed(value: Variant) -> void:
	PlayerConfig.set_config(AppSettings.VIDEO_SECTION, "ResolutionScale", value)
	$VBoxContainer/Res.text=("%.2f" % value)
