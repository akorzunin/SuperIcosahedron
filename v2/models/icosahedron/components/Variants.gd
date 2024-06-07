extends RefCounted
class_name IcosahedronVarints

# magical number that represent distance between cutplane and origin
const dst := 0.794

const figure_variants = {
    8: {
        name = "top_left",
        cutplane = Vector4(0.0, 0.934, -0.358, dst),
    },
    7: {
        name = "top_right",
        cutplane = Vector4(0.0, 0.934, 0.358, dst),
    },
    6: {
        name = "bot_left",
        cutplane = Vector4( -0.577, -0.577, -0.577, dst),
    },
    5: {
        name = "bot_right",
        cutplane = Vector4( -0.577, -0.577, 0.577, dst),
    },
    4: {
        name = "bot_mid",
        cutplane = Vector4( -0.934, -0.358, 0., dst),
    },
    3: {
        name = "mid_mid",
        cutplane = Vector4( -0.934, 0.358, 0., dst),
    },
    2: {
        name = "mid_left",
        cutplane = Vector4( -0.577, 0.577, -0.577, dst),
    },
    1: {
        name = "mid_right",
        cutplane = Vector4( -0.577, 0.577, 0.577, dst),
    },
    0: {
        name = "default",
    },
}
