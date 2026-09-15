# /// script
# dependencies = ["fonttools==4.62.1", "shapely==2.1.2", "pillow==12.1.1"]
# ///
"""Modify Plastic Bag's existing outlines; rebuild and compare at UI sizes."""

import argparse
from pathlib import Path

from fontTools.pens.basePen import BasePen
from fontTools.pens.t2CharStringPen import T2CharStringPen
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFont
from shapely.affinity import rotate, translate
from shapely.geometry import LineString, Point, Polygon
from shapely.geometry.polygon import orient
from shapely.ops import polygonize, unary_union

ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = ROOT / "game/game-assets/fonts/plastic-bag"
SOURCE = DIRECTORY / "Plastic Bag.otf"
TARGET = DIRECTORY / "PlasticBagReadable.otf"


class OutlinePen(BasePen):
    """Flatten the few curved symbols to sub-font-unit accuracy for offsetting."""

    def __init__(self, glyph_set):
        super().__init__(glyph_set)
        self.contours = []
        self.points = []

    def _moveTo(self, point):
        self.points = [point]

    def _lineTo(self, point):
        self.points.append(point)

    def _curveToOne(self, p1, p2, p3):
        def flatten(a, b, c, d):
            chord = LineString([a, d])
            if max(chord.distance(Point(p)) for p in (b, c)) < 0.5:
                self.points.append(d)
                return
            ab, bc, cd = [
                tuple((x + y) / 2 for x, y in zip(u, v))
                for u, v in ((a, b), (b, c), (c, d))
            ]
            abc, bcd = [
                tuple((x + y) / 2 for x, y in zip(u, v))
                for u, v in ((ab, bc), (bc, cd))
            ]
            mid = tuple((x + y) / 2 for x, y in zip(abc, bcd))
            flatten(a, ab, abc, mid)
            flatten(mid, bcd, cd, d)

        flatten(self._getCurrentPoint(), p1, p2, p3)

    def _closePath(self):
        if len(self.points) >= 3:
            self.contours.append(self.points + [self.points[0]])


def filled_outline(contours):
    # Resolve overlapping contours with the font's nonzero winding fill rule.
    edges = unary_union([LineString(contour) for contour in contours])
    rings = [
        (Polygon(contour), 1 if Polygon(contour).exterior.is_ccw else -1)
        for contour in contours
    ]
    return unary_union(
        [
            face
            for face in polygonize(edges)
            if sum(
                sign for ring, sign in rings if ring.covers(face.representative_point())
            )
            != 0
        ]
    )


def build(inset, spacing):
    font = TTFont(SOURCE, recalcTimestamp=False)
    glyph_set = font.getGlyphSet()
    top = font["CFF "].cff.topDictIndex[0]
    outlines = {}
    for name in font.getGlyphOrder():
        pen = OutlinePen(glyph_set)
        glyph_set[name].draw(pen)
        outlines[name] = pen.contours
    # Single diagonal terminals, not paired bevels: I/1 are cut at the top
    # left and bottom right, giving parallel ends. T keeps its bottom-right cut.
    # Match whole contours so lowercase and accented copies get the same edit
    # without touching their accents or unrelated glyphs.
    i_stem = outlines["I"][0]
    t_stem = outlines["T"][0]
    slanted_i = [
        (163, 692),
        (26, 592),
        (26, 0),
        (163, 100),
        (163, 692),
    ]
    # Numeral 1 has its own slightly wider stem and original side bearings.
    outlines["one"] = [[(182, 692), (44, 592), (44, 0), (182, 100), (182, 692)]]
    slanted_t = [
        (-35, 692),
        (37, 534),
        (148, 534),
        (148, 0),
        (285, 100),
        (285, 534),
        (397, 534),
        (465, 692),
        (-35, 692),
    ]
    for name, contours in outlines.items():
        outlines[name] = [
            slanted_i
            if contour == i_stem
            else slanted_t
            if contour == t_stem
            else contour
            for contour in contours
        ]
    # Keep the original plus's hexagonal horizontal bar, and rotate a copy
    # for an equally thick/long vertical bar with matching terminal bevels.
    plus_bar = Polygon(
        [(15, 346), (52, 426), (360, 426), (397, 346), (360, 266), (52, 266)]
    )
    plus = plus_bar.union(rotate(plus_bar, 90, origin=(206, 346)))
    outlines["plus"] = [list(plus.exterior.coords)]
    # Reuse Plastic Bag's own slashed-O outline to distinguish zero from O.
    outlines["zero"] = outlines["Oslash"]
    for name, contours in outlines.items():
        width, bearing = font["hmtx"][name]
        new_width = width + spacing if width else 0
        pen = T2CharStringPen(new_width, None)
        if contours:
            original = filled_outline(contours)
            # Small accents/punctuation must not disappear under the same erosion
            # as full-size letters. Limit thinning locally to preserve components.
            pieces = [original] if original.geom_type == "Polygon" else original.geoms
            modified = []
            for piece in pieces:
                amount = inset
                while True:
                    candidate = piece.buffer(-amount, join_style="mitre")
                    if (
                        not candidate.is_empty
                        and candidate.geom_type == "Polygon"
                        and candidate.area >= piece.area * 0.65
                        and len(candidate.interiors) == len(piece.interiors)
                    ):
                        break
                    amount /= 2
                    if amount < 0.1:
                        candidate = piece
                        break
                modified.append(candidate)
            shape = translate(unary_union(modified), xoff=spacing / 2)
            polygons = [shape] if shape.geom_type == "Polygon" else shape.geoms
            for polygon in polygons:
                polygon = orient(polygon, sign=-1)
                for ring in [polygon.exterior, *polygon.interiors]:
                    points = list(ring.coords)[:-1]
                    pen.moveTo(points[0])
                    for point in points[1:]:
                        pen.lineTo(point)
                    pen.closePath()
            bearing = round(shape.bounds[0])
        font["hmtx"][name] = (new_width, bearing)
        top.CharStrings[name] = pen.getCharString(
            private=top.Private, globalSubrs=top.GlobalSubrs
        )
    family = "Plastic Bag Readable"
    for record in font["name"].names:
        replacements = {
            1: family,
            2: "Regular",
            3: "PlasticBagReadable-1.0",
            4: family,
            6: "PlasticBagReadable",
            16: family,
            17: "Regular",
        }
        if record.nameID in replacements:
            record.string = replacements[record.nameID].encode(record.getEncoding())
    font["CFF "].cff.fontNames = ["PlasticBagReadable"]
    top.FamilyName = family
    top.FullName = family
    font.save(TARGET)
    check = TTFont(TARGET)
    assert check.getBestCmap() == font.getBestCmap(), "Character coverage changed"
    assert check.getGlyphOrder() == font.getGlyphOrder(), "Glyphs lost"
    assert "GPOS" in check, "Original kerning lost"
    plus_pen = OutlinePen(check.getGlyphSet())
    check.getGlyphSet()["plus"].draw(plus_pen)
    plus = filled_outline(plus_pen.contours)
    assert plus.symmetric_difference(rotate(plus, 90, origin="center")).area < 1, (
        "Plus lost four-way symmetry"
    )
    print(TARGET)


def preview():
    image = Image.new("RGB", (2000, 1180), "#111827")
    draw = ImageDraw.Draw(image)
    for x, path, title in [
        (20, SOURCE, "Plastic Bag - original"),
        (1020, TARGET, "Plastic Bag - modified outlines"),
    ]:
        draw.text((x, 12), title, fill="white", font=ImageFont.load_default(24))
        y = 55
        for size in (16, 18, 20, 24, 32, 48):
            draw.text(
                (x, y),
                f"{size}px  Super Icosahedron\nSpeed +25% / Mirror controls\n0123456789  O0 I1L B8 S5 Z2",
                font=ImageFont.truetype(str(path), size),
                fill="white",
                spacing=8,
            )
            y += size * 3 + 43
        draw.text(
            (x, y),
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\nÀÁÂÃÄÅ Ç ÈÉÊË Ñ Ö Ø Ü ß\n.,:;!? +-= /\\ () % @ &",
            font=ImageFont.truetype(str(path), 32),
            fill="white",
            spacing=12,
        )
    target = ROOT / "build/font-preview.png"
    target.parent.mkdir(exist_ok=True)
    image.save(target)
    print(target)

    signs = Image.new("RGB", (1200, 650), "#111827")
    draw = ImageDraw.Draw(signs)
    for x, path, title in [(20, SOURCE, "Original +"), (620, TARGET, "Symmetrical +")]:
        draw.text((x, 16), title, fill="white", font=ImageFont.load_default(24))
        y = 60
        for size in (18, 24, 48, 100):
            draw.text(
                (x, y),
                "+100  -250\n-500  +700",
                font=ImageFont.truetype(str(path), size),
                fill="white",
                spacing=12,
            )
            y += size * 2 + 40
    target = ROOT / "build/font-plus-preview.png"
    signs.save(target)
    print(target)

    specimen = Image.new("RGB", (1600, 850), "#111827")
    draw = ImageDraw.Draw(specimen)
    for x, path, title in [
        (20, SOURCE, "Original"),
        (820, TARGET, "Modified I / T / 1"),
    ]:
        draw.text((x, 16), title, fill="white", font=ImageFont.load_default(24))
        y = 60
        for size in (18, 24, 48, 80):
            draw.text(
                (x, y),
                "Tree Tower\nIsac Ico Item 1",
                font=ImageFont.truetype(str(path), size),
                fill="white",
                spacing=12,
            )
            y += size * 2 + 55
        draw.text(
            (x, y),
            "I i T t 1  Í Î Ï Ī Ť Ţ",
            font=ImageFont.truetype(str(path), 40),
            fill="white",
        )
    target = ROOT / "build/font-it-preview.png"
    specimen.save(target)
    print(target)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--inset",
        type=float,
        default=10,
        help="Outline erosion in 1000-em font units (0–20)",
    )
    parser.add_argument(
        "--spacing",
        type=int,
        default=60,
        help="Extra advance per glyph in font units (0–120)",
    )
    args = parser.parse_args()
    if not 0 <= args.inset <= 20 or not 0 <= args.spacing <= 120:
        parser.error("inset must be 0–20 and spacing 0–120")
    build(args.inset, args.spacing)
    preview()
