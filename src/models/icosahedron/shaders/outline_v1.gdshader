shader_type spatial;
render_mode unshaded, cull_front;

uniform bool enable = false;
// outline costumization
uniform float outline_thickness = 0.05;
uniform vec4 color : source_color = vec4(0.0);

varying vec3 ver;
varying vec3 old_ver;
varying vec3 n;
varying vec4 wrld_vertex;

void vertex() {
    if (enable) {
        old_ver = VERTEX;
        VERTEX += VERTEX * outline_thickness;
        ver = VERTEX;
        // n = NORMAL;
        // wrld_vertex = MODEL_MATRIX * vec4(VERTEX, 1.0);
    }
}

void fragment() {
    if (enable) {
        ALBEDO = color.rgb;
        ALPHA = 0.5;
    } else {
        ALPHA = 0.;
    }
}
