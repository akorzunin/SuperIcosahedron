extends GutTest

var discoveries: Array
var progress_bytes: PackedByteArray
var had_progress: bool
var difficulty: int

func before_each() -> void:
    discoveries = G.discovered_modifiers.duplicate()
    difficulty = G.unlocked_difficulty
    had_progress = FileAccess.file_exists(G.PROGRESS_PATH)
    if had_progress:
        progress_bytes = FileAccess.get_file_as_bytes(G.PROGRESS_PATH)
    G.discovered_modifiers = []

func after_each() -> void:
    G.discovered_modifiers = discoveries
    G.unlocked_difficulty = difficulty
    if had_progress:
        var file := FileAccess.open(G.PROGRESS_PATH, FileAccess.WRITE)
        file.store_buffer(progress_bytes)
    else:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(G.PROGRESS_PATH))

func test_discovery_persists_once_and_survives_level_unlock() -> void:
    G.discover_modifier("points")
    G.discover_modifier("points")
    G.discover_modifier("unknown")
    assert_eq(G.discovered_modifiers, ["points"])
    G.unlocked_difficulty = 0
    G.unlock_difficulty(1)
    var saved := ConfigFile.new()
    assert_eq(saved.load(G.PROGRESS_PATH), OK)
    assert_eq(saved.get_value("progress", "discovered_modifiers"), ["points"])
    assert_eq(G.reset_progress(), OK)
    assert_true(G.discovered_modifiers.is_empty())

func test_empty_library_and_page_boundaries() -> void:
    var library := ModifierLibrary.new()
    add_child_autofree(library)
    assert_eq(library.cards.get_child_count(), 1)
    assert_true(library.previous.disabled)
    assert_true(library.next.disabled)
    library.entries = UpgradeCatalog.data.pickups
    library.show_page(0)
    assert_eq(library.cards.get_child_count(), ModifierLibrary.PAGE_SIZE)
    assert_false(library.next.disabled)
    library.show_page(999)
    assert_eq(library.page, 1)
    assert_true(library.next.disabled)
    assert_false(library.previous.disabled)
    library.show_page(-1)
    assert_eq(library.page, 0)

func test_library_only_shows_discoveries() -> void:
    G.discovered_modifiers = ["tier"]
    var library := ModifierLibrary.new()
    add_child_autofree(library)
    assert_eq(library.entries.size(), 1)
    assert_eq(library.entries[0].id, "tier")
    assert_string_contains(library.cards.get_child(0).text, "TIER")
