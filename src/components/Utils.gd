extends RefCounted
class_name Utils

## Only works in scene level script
static func is_main_scene(_self) -> bool:
    if _self.get_parent() == _self.get_tree().root \
        and ProjectSettings.get_setting("application/run/main_scene") == _self.scene_file_path:
        return true
    return false

## Returns current main scene name
static func main_scene(_self) -> String:
    # Globals always loads first so index of main scene is 1
    var node = _self.get_tree().root.get_child(1)
    if not node:
        return ''
    return node.name

static func set_scene(_self: Node, scene_name: String):
    _self.get_tree().root.get_child(1).change_scene(scene_name)
    pass

static func set_shader_param(node: MeshInstance3D, _name: String, value: Variant, idx: int = 0):
    var m = node.get_active_material(0) as ShaderMaterial
    if idx == 0:
        m.set_shader_parameter(_name, value)
    elif idx == 1 and m.next_pass:
        (m.next_pass as ShaderMaterial).set_shader_parameter(_name, value)
    elif idx == 2 and m.next_pass and m.next_pass.next_pass:
        (m.next_pass.next_pass as ShaderMaterial).set_shader_parameter(_name, value)
    elif idx == 3 and m.next_pass and m.next_pass.next_pass and m.next_pass.next_pass.next_pass:
        (m.next_pass.next_pass.next_pass as ShaderMaterial).set_shader_parameter(_name, value)
    return

enum RenderMethods {GL_COMPATIBILITY, MOBILE, FORWARD_PLUS}

static func get_render_method() -> RenderMethods:
    return RenderMethods.get(get_render_method_name())

static func get_render_method_name() -> String:
    return ProjectSettings.get_setting("rendering/renderer/rendering_method").to_upper()

enum Platform { WEB, MOBILE, PC}

static func get_platform() -> Platform:
    if [ OS.has_feature("mobile"), OS.has_feature("web_android"), OS.has_feature("web_ios"), ].any(func(x): return x):
        return Platform.MOBILE
    if [ OS.has_feature("web"), ].any(func(x): return x):
        return Platform.WEB
    if [ OS.has_feature("windows"), OS.has_feature("linux")].any(func(x): return x):
        return Platform.PC
    return Platform.WEB

## swap win_mode with one that better fit
static func change_window_mode(win_mode: DisplayServer.WindowMode, prev_wm := DisplayServer.window_get_mode()):
    if Utils.get_platform() != Utils.Platform.PC:
        return
    var ds := DisplayServer
    match win_mode:
        ds.WINDOW_MODE_WINDOWED, ds.WINDOW_MODE_MINIMIZED, ds.WINDOW_MODE_MAXIMIZED:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
        ds.WINDOW_MODE_FULLSCREEN:
            DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
        ds.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
            if prev_wm == ds.WINDOW_MODE_MAXIMIZED:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
            else:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

static func set_vsync(vm: DisplayServer.VSyncMode):
    # TODO: check on different platforms
    # if Utils.get_platform() != Utils.Platform.PC:
    #     return
    DisplayServer.window_set_vsync_mode(vm)
