// returns true if pixel need to be rendered
// and false if it needs to be discarded
bool render_cutplane(vec4 cutplane, vec3 ver) {
    // Called for every pixel the material is visible on.
    vec3 planeNormal = cutplane.xyz;
    float planeDistance = cutplane.w;

    // float vertexDistance = dot(planeNormal, world_vertex);
    float vertexDistance = dot(planeNormal, ver);
    float dist = vertexDistance - planeDistance;
    if (dist >= 0.0)
        return false;
    return true;
}

float cutplane_dist(vec4 cutplane, vec3 ver) {
    // Called for every pixel the material is visible on.
    vec3 planeNormal = cutplane.xyz;
    float planeDistance = cutplane.w;

    // float vertexDistance = dot(planeNormal, world_vertex);
    float vertexDistance = dot(planeNormal, ver);
    float dist = vertexDistance - planeDistance;
    return dist;
}
