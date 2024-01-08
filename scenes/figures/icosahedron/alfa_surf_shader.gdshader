shader_type spatial;
render_mode cull_disabled;

uniform vec4 cutplane;

varying vec3 world_vertex;

void vertex() {
   	// Called for every vertex the material is visible on.
    //  https://docs.godotengine.org/en/stable/tutorials/shaders/advanced_postprocessing.html
    world_vertex = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 planeNormal = cutplane.xyz;

    float planeDistance = cutplane.w;
    float vertexDistance = dot(planeNormal, world_vertex);
    float dist = vertexDistance - planeDistance;
    if (dist > 0.0) discard;
    ALBEDO = vec3(1.0, 0.2, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
