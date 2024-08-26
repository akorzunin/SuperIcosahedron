extends RefCounted
class_name IcosahedronVarints

# magical number that represent distance between cutplane and origin
const dst := 0.794
const l := 0.577

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

const a := 0.577
const b := 0.358
const c := 0.934

static var figure_variants_v2 := {
    #0: Vector4( c, b, 0, dst),
    0: Vector4( -b, 0, -c, dst),
    15: Vector4( b, 0, -c, dst),

    1: Vector4( a, a, -a, dst),
    2: Vector4( 0, c, -b, dst),
    3: Vector4( 0, c, b, dst),
    4: Vector4( a, a, a, dst),
    5: Vector4( b, 0, c, dst),
    6: Vector4( -b, 0, c, dst),
    7: Vector4( -a, -a, a, dst),
    8: Vector4( 0, -c, b, dst),
    9: Vector4( a, -a, a, dst),
    10: Vector4( c, -b, 0, dst),
    11: Vector4( a, -a, -a, dst),
    12: Vector4( 0, -c, -b, dst),
    13: Vector4( -a, -a, -a, dst),
    14: Vector4( -c, -b, 0, dst),

    17: Vector4( -a, a, -a, dst),
    18: Vector4( -c, b, 0, dst),
    19: Vector4( -a, a, a, dst),
}
