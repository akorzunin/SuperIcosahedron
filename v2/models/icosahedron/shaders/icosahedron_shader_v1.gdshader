shader_type spatial;
render_mode cull_disabled;

uniform bool pulse_enabled = false;
uniform bool colorflow_enbled = false;
instance uniform bool cutplate_visible = true;

// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
//top left
//uniform vec4 cutplane = vec4(0, .334, -.128, 0.284);
// TODO normalize cutpalne vaectors
////top right
//uniform vec4 cutplane = vec4(0, .334, .128, 0.284);
////bot mid
//uniform vec4 cutplane = vec4(-.334, -.128, 0., 0.284);
//top mid
//uniform vec4 cutplane = vec4(-.334, .128, 0., 0.284);
//top left
//uniform vec4 cutplane = vec4(-1., 1., -1., 1.375);
//top right
//uniform vec4 cutplane = vec4(-1., 1., 1., 1.375);
instance uniform vec4 cutplane = vec4(-0.988, 0.977, 1., 1.345);

varying vec3 world_vertex;
varying vec3 ver;

void vertex() {
    // Called for every vertex the material is visible on.
    // world_vertex = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
    ver = VERTEX;
}

void fragment() {
    if (cutplate_visible) {
        // Called for every pixel the material is visible on.
        vec3 planeNormal = cutplane.xyz;
        float planeDistance = cutplane.w;

        // float vertexDistance = dot(planeNormal, world_vertex);
        float vertexDistance = dot(planeNormal, ver);
        float dist = vertexDistance - planeDistance;
        if (dist >= 0.0)
            discard;
        ALBEDO = vec3(clamp(cutplane.x, 0., 0.2), cutplane.y, cutplane.z);
    }
    if (!cutplate_visible) {
        ALBEDO = vec3(1.,0.,0.);
    }
    //ALPHA = 0.99;
}

// void light() {
// Called for every pixel for every light affecting the material.
// Uncomment to replace the default light processing function with this one.
//}
