vec3 linear_to_srgb(vec3 _color) {
    // If going to srgb, clamp from 0 to 1.
    _color = clamp(_color, vec3(0.0), vec3(1.0));
    const vec3 a = vec3(0.055f);
    return mix((vec3(1.0f) + a) * pow(_color.rgb, vec3(1.0f / 2.4f)) - a,
               12.92f * _color.rgb, lessThan(_color.rgb, vec3(0.0031308f)));
}

vec3 srgb_to_linear(vec3 _color) {
    return mix(
        pow((_color.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)),
        _color.rgb * (1.0 / 12.92), lessThan(_color.rgb, vec3(0.04045)));
}

// https://lygia.xyz/color/hueShift

#ifndef HCV_EPSILON
#define HCV_EPSILON 1e-10
#endif

#ifndef FNC_RGB2HCV
#define FNC_RGB2HCV
vec3 rgb2hcv(const in vec3 rgb) {
    vec4 P = (rgb.g < rgb.b) ? vec4(rgb.bg, -1.0, 2.0 / 3.0)
                             : vec4(rgb.gb, 0.0, -1.0 / 3.0);
    vec4 Q = (rgb.r < P.x) ? vec4(P.xyw, rgb.r) : vec4(rgb.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6.0 * C + HCV_EPSILON) + Q.z);
    return vec3(H, C, Q.x);
}
// vec4 rgb2hcv(vec4 rgb) {return vec4(rgb2hcv(rgb.rgb), rgb.a);}
#endif

#ifndef HSL_EPSILON
#define HSL_EPSILON 1e-10
#endif

#ifndef FNC_RGB2HSL
#define FNC_RGB2HSL
vec3 rgb2hsl(const in vec3 rgb) {
    vec3 HCV = rgb2hcv(rgb);
    float L = HCV.z - HCV.y * 0.5;
    float S = HCV.y / (1.0 - abs(L * 2.0 - 1.0) + HSL_EPSILON);
    return vec3(HCV.x, S, L);
}
// vec4 rgb2hsl(const in vec4 rgb) { return vec4(rgb2hsl(rgb.xyz),rgb.a);}
#endif

#if !defined(FNC_SATURATE) && !defined(saturate)
#define FNC_SATURATE
#define saturate(V) clamp(V, 0.0, 1.0)
#endif

#ifndef FNC_HUE2RGB
#define FNC_HUE2RGB
vec3 hue2rgb(const in float hue) {
    float R = abs(hue * 6.0 - 3.0) - 1.0;
    float G = 2.0 - abs(hue * 6.0 - 2.0);
    float B = 2.0 - abs(hue * 6.0 - 4.0);
    return saturate(vec3(R, G, B));
}
#endif

#ifndef FNC_HSL2RGB
#define FNC_HSL2RGB
vec3 hsl2rgb(const in vec3 hsl) {
    vec3 rgb = hue2rgb(hsl.x);
    float C = (1.0 - abs(2.0 * hsl.z - 1.0)) * hsl.y;
    return (rgb - 0.5) * C + hsl.z;
}
// vec4 hsl2rgb(const in vec4 hsl) { return vec4(hsl2rgb(hsl.xyz), hsl.w); }
#endif

#ifndef FNC_HUESHIFT
#define FNC_HUESHIFT
vec3 hueShift(vec3 color, float a) {
    vec3 hsl = rgb2hsl(color);
#ifndef HUESHIFT_AMOUNT
    hsl.r = hsl.r * TAU + a;
    hsl.r = fract(hsl.r / TAU);
#else
    hsl.r += a;
#endif
    return hsl2rgb(hsl);
}

// vec4 hueShift(in vec4 v, in float a) {
// return vec4(hueShift(v.rgb, a), v.a);
//}

#endif
