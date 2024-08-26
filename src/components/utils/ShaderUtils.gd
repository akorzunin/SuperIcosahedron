extends RefCounted
class_name ShaderUtils

static func set_shader_param(node: MeshInstance3D, _name: String, value: Variant, idx: int = 0):
    var m = node.get_active_material(0) as ShaderMaterial
    if not m:
        return
    if idx == 0:
        m.set_shader_parameter(_name, value)
    elif idx == 1 and m.next_pass:
        (m.next_pass as ShaderMaterial).set_shader_parameter(_name, value)
    elif idx == 2 and m.next_pass and m.next_pass.next_pass:
        (m.next_pass.next_pass as ShaderMaterial).set_shader_parameter(_name, value)
    elif idx == 3 and m.next_pass and m.next_pass.next_pass and m.next_pass.next_pass.next_pass:
        (m.next_pass.next_pass.next_pass as ShaderMaterial).set_shader_parameter(_name, value)
    return

static func create_shader_material(_shader: Shader) -> ShaderMaterial:
    var sm = ShaderMaterial.new()
    sm.shader = _shader
    return sm

static func apply_shaders(_shaders: Array, node: MeshInstance3D) -> MeshInstance3D:
    for i in _shaders.size():
        var m := create_shader_material(_shaders[i])
#        TODO: figure out how to do it w/ set and property path
        #node.set("material_override" + ":next_pass".repeat(i), m)
        match i:
            0: node.material_override = m
            1: node.material_override.next_pass = m
            2: node.material_override.next_pass.next_pass = m
            3: node.material_override.next_pass.next_pass.next_pass = m
            4: node.material_override.next_pass.next_pass.next_pass.next_pass = m
            5: node.material_override.next_pass.next_pass.next_pass.next_pass.next_pass = m
    return node
