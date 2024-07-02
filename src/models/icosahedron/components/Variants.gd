extends RefCounted
class_name IcosahedronVarints

# magical number that represent distance between cutplane and origin
const dst := 0.794
const l := 0.577

## 20 faces 12 vert 30 egdes
# quad -> rect
const figure_variants_v2 = {
    '111' = {
        '111' = Vector4( l, l, l, dst),
        '110' = Vector4( l, l, l, dst),
        '011' = Vector4( l, l, l, dst),
        '101' = Vector4( l, l, l, dst),
    },
    '011' = {
        '111' = Vector4( l, l, l, dst),
        '110' = Vector4( l, l, l, dst),
        '011' = Vector4( l, l, l, dst),
        '101' = Vector4( l, l, l, dst),
    },
    '010' = {
        '111' = Vector4( l, l, l, dst),
        '110' = Vector4( l, l, l, dst),
        '011' = Vector4( l, l, l, dst),
        '101' = Vector4( l, l, l, dst),
    },
    '110' = {
        '111' = Vector4( l, l, l, dst),
        '110' = Vector4( l, l, l, dst),
        '011' = Vector4( l, l, l, dst),
        '101' = Vector4( l, l, l, dst),
    },
    '101' = {
        '111' = Vector4( l, l, l, dst),
        '110' = Vector4( l, l, l, dst),
        '011' = Vector4( l, l, l, dst),
        '101' = Vector4( l, l, l, dst),
    },
    '001' = {
        '111' = Vector4( l, l, l, dst),
        '110' = Vector4( l, l, l, dst),
        '011' = Vector4( l, l, l, dst),
        '101' = Vector4( l, l, l, dst),
    },
    '000' = {
        '111' = Vector4( l, l, l, dst),
        '110' = Vector4( l, l, l, dst),
        '011' = Vector4( l, l, l, dst),
        '101' = Vector4( l, l, l, dst),
    },
    '100' = {
        '111' = Vector4( l, l, l, dst),
        '110' = Vector4( l, l, l, dst),
        '011' = Vector4( l, l, l, dst),
        '101' = Vector4( l, l, l, dst),
    },
}
# 3 golden rectangles
# rect x
# rect y
# rect z
# to define eash face we ned to know what cartesian quadrant it belongs
# and what rectangle it touches (can be 2 or all)
# RX have normal (1,0,0) and so on
enum GoldenRect {RX, RY, RZ}
# so each rect can be represented as vector
# and we can use them in conmbinations also

# RX + RY = (1,1,0)


static func get_face( rects: Array[GoldenRect], quad: Vector3i):
    if len(rects) == 3:
        return figure_variants_v2[quad]['111']
    pass


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
