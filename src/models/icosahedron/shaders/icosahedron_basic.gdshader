shader_type spatial;
render_mode unshaded;

uniform vec4 color : source_color = vec4(0.35, 0.85, 1.0, 1.0);

void fragment() {
    ALBEDO = color.rgb;
    ALPHA = color.a;
}
