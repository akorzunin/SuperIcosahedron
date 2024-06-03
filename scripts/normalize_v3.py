#!/usr/bin/env python

from math import sqrt

res = input("Insert vector values (comma sep, ex: 1, 1, 1):\n")
x, y, z = res.strip().split(", ")


def normalize(_x: str, _y: str, _z: str):
    x, y, z = float(_x), float(_y), float(_z)
    length = sqrt(x**2 + y**2 + z**2)
    v = (round(x / length, 3), round(y / length, 3), round(z / length, 3))
    return v


v = normalize(x, y, z)
print(v)
