shader_type spatial;
render_mode cull_disabled;

uniform bool pulse_enabled = false;
uniform bool colorflow_enbled = false;
instance uniform vec4 cutplane = vec4(-0.988, 0.977, 1., 1.345 );
//uniform vec4 cutplane = vec4(-0.988, 0.977, 1., 1.345 ); anjacent to front plane
//uniform vec4 cutplane = vec4(-1.875, 0.725, 0., 1.578 ); cut front corner
//uniform vec4 cutplane = vec4(1.0, 1.0, 1., 1.376 ); one corner

varying vec3 world_vertex;
varying vec3 ver;

void vertex() {
	// Called for every vertex the material is visible on.
    //world_vertex = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
    ver = VERTEX;
    VERTEX = VERTEX;
}

void fragment() {
	// Called for every pixel the material is visible on.
    vec3 planeNormal = cutplane.xyz;
    float planeDistance = cutplane.w;

    //float vertexDistance = dot(planeNormal, world_vertex);
    float vertexDistance = dot(planeNormal, ver);
    float dist = vertexDistance - planeDistance;
    if (dist >= 0.0) discard;

    ALBEDO = vec3(clamp(cutplane.x, 0., 0.2), cutplane.y, cutplane.z );
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
