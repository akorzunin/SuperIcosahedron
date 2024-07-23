#ifndef FNC_LUMINANCE
#define FNC_LUMINANCE
float luminance(in vec3 linear) {
    return dot(linear, vec3(0.21250175, 0.71537574, 0.07212251));
}
// float luminance(in vec4 linear) { return luminance( linear.rgb ); }
#endif

#ifndef FNC_TONEMAPREINHARDJODIE
#define FNC_TONEMAPREINHARDJODIE
vec3 tonemapReinhardJodie(const vec3 x) {
    float l = luminance(x);
    vec3 tc = x / (x + 1.0);
    return mix(x / (l + 1.0), tc, tc);
}
// vec4 tonemapReinhardJodie(const vec4 x) { return vec4(
// tonemapReinhardJodie(x.rgb), x.a ); }
#endif
