shader_type spatial;
render_mode cull_disabled;

uniform bool pulse_enabled = false;
uniform bool colorflow_enbled = false;
instance uniform bool cutplate_visible = true;

// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
instance uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
instance uniform vec3 color = vec3(.0, 1., .0);

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
    }
    ALBEDO = color.rgb;
}

// void light() {
// Called for every pixel for every light affecting the material.
// Uncomment to replace the default light processing function with this one.
//}
