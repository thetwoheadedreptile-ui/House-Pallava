#!/usr/bin/env python3
"""Generate placeholder pixel-art sprites for Thondaimandalam (Sprint 1).

Run from repo root:  python3 tools/gen_art.py
Outputs PNGs into assets/sprites/. These are temporary programmer art.
"""
import os
import random

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "sprites")
random.seed(42)

TILE_W, TILE_H = 64, 32


def new(w, h):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


def diamond_points(cx, cy, w, h):
    return [
        (cx, cy - h // 2),
        (cx + w // 2, cy),
        (cx, cy + h // 2),
        (cx - w // 2, cy),
    ]


def save(img, name):
    path = os.path.join(OUT, name)
    img.save(path)
    print("wrote", os.path.relpath(path, ROOT))


def speckle(draw, img, color, n):
    w, h = img.size
    for _ in range(n):
        x = random.randrange(w)
        y = random.randrange(h)
        if img.getpixel((x, y))[3] > 0:
            draw.point((x, y), color)


def tile(name, top, left, right, speckle_color=None, speckles=0):
    img, d = new(TILE_W, TILE_H)
    cx, cy = TILE_W // 2, TILE_H // 2
    d.polygon(diamond_points(cx, cy, TILE_W, TILE_H), fill=top)
    d.polygon(diamond_points(cx - 1, cy + 1, TILE_W - 4, TILE_H - 6),
              fill=None, outline=left, width=1)
    if speckle_color:
        speckle(d, img, speckle_color, speckles)
    save(img, name)


def iso_box(canvas, origin, w, d, h, top, left, right):
    """Draw an isometric box. origin = screen pos of the box's south corner."""
    ox, oy = origin
    half_w, half_d = w // 2, d // 2
    top_face = diamond_points(ox, oy - h, half_w * 2, half_d * 2)
    left_face = [
        (ox - half_w, oy - h),
        (ox, oy - h + half_d),
        (ox, oy + half_d),
        (ox - half_w, oy),
    ]
    right_face = [
        (ox + half_w, oy - h),
        (ox, oy - h + half_d),
        (ox, oy + half_d),
        (ox + half_w, oy),
    ]
    drw = ImageDraw.Draw(canvas)
    drw.polygon(left_face, fill=left)
    drw.polygon(right_face, fill=right)
    drw.polygon(top_face, fill=top)


def roof(canvas, origin, w, d, h, color, dark):
    ox, oy = origin
    hw = w // 2
    apex = (ox, oy - h - 10)
    front = [(ox - hw, oy - h), (ox + hw, oy - h), apex]
    right = [(ox + hw, oy - h), (ox + hw, oy - h + d // 2), (ox, oy - h + 10 + d // 2), apex]
    drw = ImageDraw.Draw(canvas)
    drw.polygon(front, fill=color)
    drw.polygon(right, fill=dark)


def building(name, size, colors, two_tier=False, sign=None):
    canvas_w, canvas_h = 112, 96
    img, _ = new(canvas_w, canvas_h)
    w, d, h = size
    top, left, right, rc, rd = colors
    ox, oy = canvas_w // 2, canvas_h - 20
    iso_box(img, (ox, oy), w, d, h, top, left, right)
    if two_tier:
        iso_box(img, (ox, oy - 14), int(w * 0.7), int(d * 0.7), h + 8,
                top, left, right)
        roof(img, (ox, oy - 14 - h - 8), int(w * 0.8), int(d * 0.8), 12, rc, rd)
    else:
        roof(img, (ox, oy - h), w + 6, d + 6, 14, rc, rd)
    if sign:
        drw = ImageDraw.Draw(img)
        drw.polygon([(ox - 8, oy - h - 26), (ox + 8, oy - h - 26),
                     (ox, oy - h - 36)], fill=sign)
    save(img, name)


def field_plot():
    img, d = new(112, 80)
    cx, cy = 56, 46
    d.polygon(diamond_points(cx, cy, 104, 56), fill=(96, 74, 52, 255))
    d.polygon(diamond_points(cx, cy, 92, 48), fill=(72, 54, 38, 255))
    for r in range(4):
        y = cy - 18 + r * 12
        d.line([(cx - 40 + r * 6, y), (cx + 6 - r * 6, y + 14)],
               fill=(118, 148, 66, 255), width=4)
    speckle(d, img, (52, 40, 28, 255), 90)
    save(img, "field.png")


def tree():
    img, d = new(64, 80)
    trunk = (96, 70, 46, 255)
    leaf = (66, 112, 52, 255)
    leaf_dark = (52, 92, 42, 255)
    d.rectangle([28, 44, 36, 72], fill=trunk)
    d.ellipse([10, 8, 54, 52], fill=leaf)
    d.ellipse([16, 2, 46, 18], fill=leaf)
    d.ellipse([18, 20, 34, 40], fill=leaf_dark)
    save(img, "tree.png")


def villager_frames():
    for frame in range(2):
        img, d = new(24, 32)
        skin = (146, 96, 62, 255)
        cloth = (232, 226, 212, 255)
        hair = (32, 26, 22, 255)
        d.ellipse([9, 2, 15, 8], fill=skin)
        d.arc([9, 1, 15, 7], 180, 360, fill=hair, width=2)
        d.rectangle([8, 8, 16, 18], fill=skin)
        d.rectangle([8, 14, 16, 24], fill=cloth)
        if frame == 0:
            d.line([10, 24, 9, 30], fill=skin, width=3)
            d.line([14, 24, 16, 29], fill=skin, width=3)
            d.line([8, 10, 6, 16], fill=skin, width=2)
            d.line([16, 10, 18, 16], fill=skin, width=2)
        else:
            d.line([10, 24, 12, 30], fill=skin, width=3)
            d.line([14, 24, 12, 29], fill=skin, width=3)
            d.line([8, 10, 5, 14], fill=skin, width=2)
            d.line([16, 10, 19, 14], fill=skin, width=2)
        save(img, f"villager_{frame}.png")


def main():
    os.makedirs(OUT, exist_ok=True)
    tile("tile_grass.png", (96, 128, 62, 255), (74, 102, 48, 255), (80, 110, 52, 255),
         (108, 142, 70, 255), 60)
    tile("tile_dirt.png", (150, 120, 84, 255), (120, 94, 64, 255), (130, 104, 72, 255),
         (168, 138, 98, 255), 70)
    tile("tile_water.png", (58, 108, 148, 255), (42, 84, 122, 255), (48, 92, 130, 255),
         (108, 164, 196, 255), 40)
    tile("tile_sand.png", (196, 172, 122, 255), (168, 142, 96, 255), (180, 154, 108, 255),
         (212, 190, 138, 255), 50)

    building("hut.png", (36, 36, 14),
             ((86, 74, 56, 255), (66, 56, 42, 255), (76, 64, 48, 255),
              (150, 118, 70, 255), (122, 94, 54, 255)))
    building("seat.png", (52, 38, 20),
             ((92, 80, 60, 255), (70, 60, 46, 255), (80, 68, 52, 255),
              (158, 124, 72, 255), (128, 100, 58, 255)), two_tier=True, sign=(198, 92, 70, 255))
    building("granary.png", (34, 34, 30),
             ((104, 84, 60, 255), (82, 66, 46, 255), (92, 74, 52, 255),
              (140, 106, 62, 255), (112, 84, 48, 255)))
    building("kennel.png", (30, 26, 12),
             ((96, 78, 58, 255), (76, 60, 44, 255), (86, 68, 50, 255),
              (110, 84, 50, 255), (88, 66, 38, 255)))
    field_plot()
    tree()
    villager_frames()


if __name__ == "__main__":
    main()
