shader_type spatial;
render_mode cull_back;

#include "res://src/shaders/shader_utils.gdshaderinc"

uniform vec3 color = vec3(.0, 1., .0);

void fragment() {
    ALBEDO = OUTPUT_IS_SRGB ? linear_to_srgb(color.rgb) : color.rgb;
}
