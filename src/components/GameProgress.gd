extends Node
class_name GameProgress

var figures_passed := 0
var time_passed := 0.

func add_one():
    figures_passed += 1

func reset():
    figures_passed = 0
