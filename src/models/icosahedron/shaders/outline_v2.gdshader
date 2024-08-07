shader_type spatial;
render_mode unshaded;

// MIT License. Made by Leo Peltola. Adapted by ARez.
// Inspired by https://threejs.org/examples/webgl_postprocessing_pixel.html

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : filter_nearest;

uniform bool disable_shader = false;
uniform float MAX_DEPTH : hint_range(0.0, 10000, 1) = 1000;

uniform bool shadows_enabled = true;
uniform bool highlights_enabled = true;
uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float highlight_strength : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec3 highlight_color : source_color = vec3(0.45);
uniform vec3 shadow_color : source_color = vec3(0.0);

float getDepth(vec2 screen_uv, sampler2D depth_texture,
               mat4 inv_projection_matrix) {
    //  Credit:
    // https://godotshaders.com/shader/depth-modulated-pixel-outline-in-screen-space/
    float raw_depth = texture(depth_texture, screen_uv)[0];
    vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space =
        inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
    view_space.xyz /= view_space.w;
    return -view_space.z;
}

float normalIndicator(vec3 normalEdgeBias, vec3 baseNormal, vec3 newNormal,
                      float depth_diff) {
    // Credit: https://threejs.org/examples/webgl_postprocessing_pixel.html
    float normalDiff = dot(baseNormal - newNormal, normalEdgeBias);
    float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);
    float depthIndicator = clamp(sign(depth_diff * .25 + .0025), 0.0, 1.0);
    return (1.0 - dot(baseNormal, newNormal)) * depthIndicator *
           normalIndicator;
}

void vertex() { POSITION = vec4(VERTEX, 1.0); }

uniform int pixelSize : hint_range(2, 16, 1) = 4;
void fragment() {
    if (disable_shader) {
        discard;
    }
    // vec2 uv = SCREEN_UV;
    vec2 iRes = VIEWPORT_SIZE.xy;
    vec2 onePixelSize = 1.0 / iRes;
    vec2 cellSize = float(pixelSize) * onePixelSize;
    vec2 e = cellSize;
    vec2 uv = cellSize * round(SCREEN_UV / cellSize);
    vec2 orig_uv = SCREEN_UV;

    //  Shadows
    float depth_diff = 0.0;
    float neg_depth_diff = 0.0;
    if (shadows_enabled) {
        float depth = getDepth(uv, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
        if (depth > MAX_DEPTH) {
            discard;
        }
        float du = getDepth(uv + vec2(0.0, -1.0) * e, DEPTH_TEXTURE,
                            INV_PROJECTION_MATRIX);
        float dr = getDepth(uv + vec2(1.0, 0.0) * e, DEPTH_TEXTURE,
                            INV_PROJECTION_MATRIX);
        float dd = getDepth(uv + vec2(0.0, 1.0) * e, DEPTH_TEXTURE,
                            INV_PROJECTION_MATRIX);
        float dl = getDepth(uv + vec2(-1.0, 0.0) * e, DEPTH_TEXTURE,
                            INV_PROJECTION_MATRIX);
        depth_diff += clamp(du - depth, 0.0, 1.0);
        depth_diff += clamp(dd - depth, 0.0, 1.0);
        depth_diff += clamp(dr - depth, 0.0, 1.0);
        depth_diff += clamp(dl - depth, 0.0, 1.0);
        neg_depth_diff += depth - du;
        neg_depth_diff += depth - dd;
        neg_depth_diff += depth - dr;
        neg_depth_diff += depth - dl;
        neg_depth_diff = clamp(neg_depth_diff, 0.0, 1.0);
        neg_depth_diff =
            clamp(smoothstep(0.5, 0.5, neg_depth_diff) * 10.0, 0.0, 1.0);
        depth_diff = smoothstep(0.2, 0.3, depth_diff);

        // ALBEDO = vec3(depth_diff);
    }

    //  Highlights
    float normal_diff = 0.;
    if (highlights_enabled) {
        vec2 uv_use = max(uv, orig_uv);
        vec3 normal = texture(NORMAL_TEXTURE, uv_use).rgb * 2.0 - 1.0;
        vec3 nu =
            texture(NORMAL_TEXTURE, uv_use + vec2(0.0, -1.0) * e).rgb * 2.0 -
            1.0;
        vec3 nr =
            texture(NORMAL_TEXTURE, uv_use + vec2(1.0, 0.0) * e).rgb * 2.0 -
            1.0;
        vec3 nd =
            texture(NORMAL_TEXTURE, uv_use + vec2(0.0, 1.0) * e).rgb * 2.0 -
            1.0;
        vec3 nl =
            texture(NORMAL_TEXTURE, uv_use + vec2(-1.0, 0.0) * e).rgb * 2.0 -
            1.0;
        vec3 normal_edge_bias = (vec3(1.0, 1.0, 1.0));
        normal_diff +=
            normalIndicator(normal_edge_bias, normal, nu, depth_diff);
        normal_diff +=
            normalIndicator(normal_edge_bias, normal, nr, depth_diff);
        normal_diff +=
            normalIndicator(normal_edge_bias, normal, nd, depth_diff);
        normal_diff +=
            normalIndicator(normal_edge_bias, normal, nl, depth_diff);
        normal_diff = smoothstep(0.2, 0.8, normal_diff);
        normal_diff = clamp(normal_diff - neg_depth_diff, 0., 1.);
        // ALBEDO = vec3(normal_diff);
    }

    vec3 original_color = ALBEDO;
    original_color = texture(SCREEN_TEXTURE, uv).rgb;
    vec3 final_highlight_color =
        mix(original_color, highlight_color, highlight_strength);
    vec3 final_shadow_color =
        mix(original_color, shadow_color, shadow_strength);
    vec3 final = original_color;
    if (highlights_enabled) {
        final = mix(final, final_highlight_color, normal_diff);
    }
    if (shadows_enabled) {
        final = mix(final, final_shadow_color, depth_diff);
    }
    // ALBEDO = original_color;
    ALBEDO = vec3(normal_diff);
    // ALBEDO = vec3(depth_diff);
    // ALBEDO = vec3(depth_diff + normal_diff);
    // ALBEDO = texture(NORMAL_TEXTURE, uv).rgb * 2.0 - 1.0;
    ALBEDO = final;

    float alpha_mask = depth_diff * float(shadows_enabled) +
                       normal_diff * float(highlights_enabled);
    ALPHA = clamp(alpha_mask * 5.0, 0.0, 1.0);
    // ALPHA = 1.0;
}
