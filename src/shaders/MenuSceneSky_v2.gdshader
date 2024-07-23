shader_type spatial;
render_mode cull_front;

#include "res://src/shaders/shader_utils.gdshaderinc"
#include "res://src/shaders/tonemap.gdshaderinc"

// tw.sky._200
uniform vec3 bg_color : source_color = vec3(0.729, 0.902, 0.992);

void fragment() {
    vec3 color = bg_color;
    // color = tonemapReinhardJodie(color);
    ALBEDO = color;
    ROUGHNESS = .5;
    METALLIC = .5;
}
