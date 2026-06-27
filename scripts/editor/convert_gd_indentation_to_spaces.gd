@tool
extends EditorScript

const INDENT_SIZE := 4
const INCLUDE_ADDONS := false
const ROOT_DIR := "res://"

func _run() -> void:
    var files: PackedStringArray = []
    _collect_gd_files(ROOT_DIR, files)

    var changed_count := 0
    for file_path in files:
        if _convert_file(file_path):
            changed_count += 1

    EditorInterface.get_resource_filesystem().scan()
    print("Converted indentation in %d of %d GDScript files." % [changed_count, files.size()])

func _collect_gd_files(dir_path: String, files: PackedStringArray) -> void:
    if not INCLUDE_ADDONS and dir_path.begins_with("res://addons"):
        return

    var dir := DirAccess.open(dir_path)
    if dir == null:
        push_warning("Could not open directory: %s" % dir_path)
        return

    dir.list_dir_begin()
    var entry := dir.get_next()
    while entry != "":
        if entry.begins_with("."):
            entry = dir.get_next()
            continue

        var path := dir_path.path_join(entry)
        if dir.current_is_dir():
            _collect_gd_files(path, files)
        elif entry.ends_with(".gd"):
            files.append(path)

        entry = dir.get_next()
    dir.list_dir_end()

func _convert_file(file_path: String) -> bool:
    var file := FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        push_warning("Could not read file: %s" % file_path)
        return false

    var original := file.get_as_text()
    var converted := _leading_tabs_to_spaces(original)
    if converted == original:
        return false

    file = FileAccess.open(file_path, FileAccess.WRITE)
    if file == null:
        push_warning("Could not write file: %s" % file_path)
        return false

    file.store_string(converted)
    print("Converted: %s" % file_path)
    return true

func _leading_tabs_to_spaces(text: String) -> String:
    var spaces := " ".repeat(INDENT_SIZE)
    var lines := text.split("\n", true)
    var converted_lines: Array[String] = []
    converted_lines.resize(lines.size())

    for line_index in lines.size():
        var line := lines[line_index]
        var char_index := 0
        while char_index < line.length() and line[char_index] == "\t":
            char_index += 1

        if char_index == 0:
            converted_lines[line_index] = line
        else:
            converted_lines[line_index] = spaces.repeat(char_index) + line.substr(char_index)

    return "\n".join(converted_lines)
