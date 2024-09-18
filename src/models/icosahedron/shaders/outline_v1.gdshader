shader_type spatial;
render_mode unshaded, cull_front;

uniform bool enable = false;

uniform sampler2D screen_texture : hint_screen_texture,
                                   repeat_disable,
                                   filter_nearest;

// outline costumization
uniform float outline_thickness = 0.05;
uniform vec4 color : source_color = vec4(0.0);

// pulse customization
uniform float pulse_speed = 12.;
uniform float pulse_amplitude = 2.;

varying vec3 ver;

void vertex() {
    if (enable) {
        float t = sin(TIME * pulse_speed) / pulse_amplitude + 1.;
        VERTEX += VERTEX * (outline_thickness * t);
    }
}

void fragment() {
    vec4 currentColor = textureLod(screen_texture, SCREEN_UV, 0.0);
    if (enable) {
        ALBEDO = currentColor.rgb * color.rgb;
    } else {
        ALBEDO = currentColor.rgb;
    }
}
