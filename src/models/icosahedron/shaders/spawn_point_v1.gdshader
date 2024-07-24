shader_type spatial;
render_mode cull_front;

// tw.red.500
uniform vec3 color : source_color = vec3(0.937, 0.267, 0.267);

void fragment() { ALBEDO = color; }
