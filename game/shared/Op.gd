## Util operators as functions
extends RefCounted
class_name Op

static func xor(arg1: bool, arg2: bool) -> bool:
    return arg1 != arg2

static func v3(arr: Array) -> Vector3:
    return Vector3(arr[0], arr[1], arr[2])
