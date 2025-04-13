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
    0: Vector4( c, b, 0, dst),
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
    15: Vector4( b, 0, -c, dst),
    16: Vector4( -b, 0, -c, dst),
    17: Vector4( -a, a, -a, dst),
    18: Vector4( -c, b, 0, dst),
    19: Vector4( -a, a, a, dst),
}

static var figure_variants_v3 := {
    0: {
        cutplane = Vector4( c, b, 0, dst),
        center = Vector2( 0.92, 0.71),
        color = TwColors.tw.blue._700,
        accent_color = TwColors.tw.blue._950,
        glow_color = TwColors.tw.blue._400,
    },
    1: {
        cutplane = Vector4( a, a, -a, dst),
        center = Vector2( 0.38, 0.625),
        color = TwColors.tw.green._700,
        accent_color = TwColors.tw.green._950,
        glow_color = TwColors.tw.green._400,
    },
    2: {
        cutplane = Vector4( 0, c, -b, dst),
        center = Vector2( 0.24, 0.67),
        color = TwColors.tw.sky._700,
        accent_color = TwColors.tw.sky._950,
        glow_color = TwColors.tw.sky._400,
    },
    3: {
        cutplane = Vector4( 0, c, b, dst),
        center = Vector2( 0.24, 0.835),
        color = TwColors.tw.red._700,
        accent_color = TwColors.tw.red._950,
        glow_color = TwColors.tw.red._400,
    },
    4: {
        cutplane = Vector4( a, a, a, dst),
        center = Vector2( 0.375, 0.885),
        color = TwColors.tw.yellow._700,
        accent_color = TwColors.tw.yellow._950,
        glow_color = TwColors.tw.yellow._400,
    },
    5: {
        cutplane = Vector4( b, 0, c, dst),
        center = Vector2( 0.66, 0.445),
        color = TwColors.tw.purple._700,
        accent_color = TwColors.tw.purple._950,
        glow_color = TwColors.tw.purple._400,
    },
    6: {
        cutplane = Vector4( -b, 0, c, dst),
        center = Vector2( 0.57, 0.31),
        color = TwColors.tw.indigo._700,
        accent_color = TwColors.tw.indigo._950,
        glow_color = TwColors.tw.indigo._400,
    },
    7: {
        cutplane = Vector4( -a, -a, a, dst),
        center = Vector2( 0.11, 0.4),
        color = TwColors.tw.orange._700,
        accent_color = TwColors.tw.orange._950,
        glow_color = TwColors.tw.orange._400,
    },
    8: {
        cutplane = Vector4( 0, -c, b, dst),
        center = Vector2( 0.24, 0.355),
        color = TwColors.tw.lime._700,
        accent_color = TwColors.tw.lime._950,
        glow_color = TwColors.tw.lime._400,
    },
    9: {
        cutplane = Vector4( a, -a, a, dst),
        center = Vector2( 0.375, 0.4),
        color = TwColors.tw.emerald._700,
        accent_color = TwColors.tw.emerald._950,
        glow_color = TwColors.tw.emerald._400,
    },
    10: {
        cutplane = Vector4( c, -b, 0, dst),
        center = Vector2( 0.825, 0.86),
        color = TwColors.tw.teal._700,
        accent_color = TwColors.tw.teal._950,
        glow_color = TwColors.tw.teal._400,
    },
    11: {
        cutplane = Vector4( a, -a, -a, dst),
        center = Vector2( 0.375, 0.14),
        color = TwColors.tw.cyan._700,
        accent_color = TwColors.tw.cyan._950,
        glow_color = TwColors.tw.cyan._400,
    },
    12: {
        cutplane = Vector4( 0, -c, -b, dst),
        center = Vector2( 0.24, 0.19),
        color = TwColors.tw.pink._700,
        accent_color = TwColors.tw.pink._950,
        glow_color = TwColors.tw.pink._400,
    },
    13: {
        cutplane = Vector4( -a, -a, -a, dst),
        center = Vector2( 0.12, 0.135),
        color = TwColors.tw.amber._700,
        accent_color = TwColors.tw.amber._950,
        glow_color = TwColors.tw.amber._400,
    },
    14: {
        cutplane = Vector4( -c, -b, 0, dst),
        center = Vector2( 0.12, 0.135),
        color = TwColors.tw.red._700,
        accent_color = TwColors.tw.red._950,
        glow_color = TwColors.tw.red._400,
    },
    15: {
        cutplane = Vector4( b, 0, -c, dst),
        center = Vector2( 0.24, 0.19),
        color = TwColors.tw.orange._700,
        accent_color = TwColors.tw.orange._950,
        glow_color = TwColors.tw.orange._400,
    },
    16: {
        cutplane = Vector4( -b, 0, -c, dst),
        center = Vector2( 0.24, 0.19),
        color = TwColors.tw.amber._700,
        accent_color = TwColors.tw.amber._950,
        glow_color = TwColors.tw.amber._400,
    },
    17: {
        cutplane = Vector4( -a, a, -a, dst),
        center = Vector2( 0.115, 0.62),
        color = TwColors.tw.yellow._700,
        accent_color = TwColors.tw.yellow._950,
        glow_color = TwColors.tw.yellow._400,
    },
    18: {
        cutplane = Vector4( -c, b, 0, dst),
        center = Vector2( 0.91, 0.305),
        color = TwColors.tw.lime._700,
        accent_color = TwColors.tw.lime._950,
        glow_color = TwColors.tw.lime._400,
    },
    19: {
        cutplane = Vector4( -a, a, a, dst),
        center = Vector2( 0.105, 0.88),
        color = TwColors.tw.green._700,
        accent_color = TwColors.tw.green._950,
        glow_color = TwColors.tw.green._400,
    },
}
