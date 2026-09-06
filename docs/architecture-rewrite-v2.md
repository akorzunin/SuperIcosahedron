# SuperIcosahedron architecture rewrite v2

Historical rewrite plan; paths and migration steps below are retained as historical context, not current instructions. See [file-structure.md](file-structure.md) for the current `game/` layout, reusable labs, and remaining rewrite work.

## Goals

- One permanent `MainScene`; no scene transitions during app flow.
- Side-based gameplay: every icosahedron side is data + optional visual object.
- Collision-based pass/fail; remove `EndRay`/`RayCast3D` gameplay checks.
- Basic single-pass shader only; side/modifier visuals can be rebuilt later.
- Small Godot-native architecture: scenes for composition, Resources for data, Nodes for runtime behavior.

## Target tree

```text
MainScene
├── AppState               # menu / playing / paused / game_over / collection
├── GameSession            # run score, stage, collected sides, win/lose
├── Settings
├── SfxPlayer
├── World                  # always loaded
│   ├── Camera3D
│   ├── WorldEnvironment
│   ├── DirectionalLight3D
│   ├── SkyIcosahedron
│   ├── FigureRoot
│   │   └── Anchor
│   ├── SpawnVolume        # spawns figures
│   └── EndDetector        # Area3D, replaces EndRay
├── Controls
│   ├── MenuControls
│   └── FigureControls
└── UI
    ├── MainMenuPanel
    ├── HudPanel
    ├── PausePanel
    ├── GameOverPanel
    └── CollectionPanel
```

Panels hide/show. The world stays alive.

## Data model

```text
src/game/FigureData.gd
src/game/SideData.gd
src/game/ModifierData.gd
removed: src/game/GameSession.gd
src/game/StageGenerator.gd
```

### FigureData

```gdscript
extends Resource
class_name FigureData

var sides: Array[SideData] = []
var stage := 0
var score := 0
var collected_sides: Array[SideData] = []
```

### SideData

```gdscript
extends Resource
class_name SideData

enum Kind { POSITIVE, NEGATIVE, SOLID }

var id: int
var normal: Vector3
var kind: Kind
var modifier: ModifierData
var collected := false
var score_delta := 0
```

### ModifierData

```gdscript
extends Resource
class_name ModifierData

var id := ""
var title := ""
var quality := "normal"
var duration := "stage"
var score_value := 0
```

## Figure scene

```text
Icosahedron
├── MeshIcosahedron        # basic material only
├── Collider               # Area3D / body detector
├── SideVisuals            # optional, one child per visible side
│   ├── SideVisual_0
│   └── ...
```

`Icosahedron.gd` owns `FigureData`:

```gdscript
var data: FigureData

func init(_data: FigureData) -> Icosahedron:
    data = _data
    return self

func get_best_side(world_dir: Vector3) -> SideData:
    var best: SideData
    var best_angle := INF
    for side in data.sides:
        var angle := world_dir.angle_to(global_transform.basis * side.normal)
        if angle < best_angle:
            best_angle = angle
            best = side
    return best
```

## Collision flow, no RayCast3D

Replace `EndRay` with `EndDetector`:

```text
EndDetector Area3D
└── CollisionShape3D
```

Flow:

```text
Collider enters EndDetector
→ EndDetector asks Icosahedron for best aligned side
→ GameSession.resolve_side(side)
→ pass / score / collect / game over / win
```

`EndDetector.gd`:

```gdscript
extends Area3D
class_name EndDetector

@export var pass_dir := Vector3.LEFT
@onready var game_session: GameSession = %GameSession

func _ready():
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D):
    if not area is Collider:
        return
    var figure := area.get_figure() as Icosahedron
    var side := figure.get_best_side(pass_dir.normalized())
    game_session.resolve_side(figure, side)
```

This removes per-frame ray checks and makes pass/fail an event.

## Game state without scene changes

Replace `MainScene.change_scene()` with app states:

```gdscript
enum State { MENU, PLAYING, PAUSED, GAME_OVER, COLLECTION }
signal changed(old_state, new_state)
```

State changes do only this:

- show/hide UI panels
- enable/disable controls
- start/stop timers
- clean/spawn figures
- pause gameplay nodes if needed

No `get_tree().reload_current_scene()`. Restart means:

```gdscript
game_session.reset()
figure_root.clean_all()
spawner.start_run()
app_state.set_state(AppState.State.PLAYING)
```

## Shader simplification

Delete from runtime path:

- `cutplane_effect_*`
- `outline_*`
- `edge_highlight_*`
- shader multipass arrays in `MeshIcosahedron.gd`

Keep one basic shader/material:

```text
src/models/icosahedron/shaders/icosahedron_basic.gdshader
```

`MeshIcosahedron.gd` becomes:

```gdscript
extends MeshInstance3D
class_name MeshIcosahedron

@export var material: ShaderMaterial

func set_color(color: Color):
    material.set_shader_parameter("color", color)
```

Side meaning should come from `SideVisual` color/icon for now, not shader tricks.

## File moves / new structure

```text
src/app/AppState.gd
removed: src/game/GameSession.gd
src/game/StageGenerator.gd
src/game/FigureData.gd
src/game/SideData.gd
src/game/ModifierData.gd
src/world/EndDetector.gd
src/world/FigureRoot.gd
src/world/FigureSpawner.gd
src/models/icosahedron/Icosahedron.tscn
src/models/icosahedron/components/Icosahedron.gd
src/models/icosahedron/components/MeshIcosahedron.gd
src/models/icosahedron/components/Collider.gd
src/models/icosahedron/components/SideVisual.gd
```

Keep old files until replacements work, then delete.

## Migration order

### 1. MainScene owns everything

- Move `LoopScene` contents into `MainScene` or instantiate them once under `World`.
- Stop calling `change_scene()`.
- Convert menu/game-over to UI panels.

### 2. Add AppState

- Replace scene names with states.
- Restart becomes reset, not reload.

### 3. Add data Resources

- Add `FigureData`, `SideData`, `ModifierData`.
- Keep old `type` temporarily if needed for colors.

### 4. Replace EndRay

- Add `EndDetector Area3D`.
- Connect `area_entered`.
- Delete `EndRay` after parity works.

### 5. Move pass/fail to GameSession

- `GameSession.resolve_side(figure, side)` owns score, collection, win/lose.
- `GameProgress` becomes UI/debug only or gets deleted.

### 6. Simplify MeshIcosahedron

- Replace multipass shader logic with one material.
- Remove cutplane shader dependency from gameplay.

### 7. Add SideVisuals

- Generate one `SideVisual` per `SideData` only when needed for readability.
- Keep collision single-body unless real per-side hitboxes become necessary.

## What to delete later

- `src/scenes/LoopScene.tscn`
- `src/scenes/MenuScene.tscn`
- `src/scenes/init/LoopScene.gd`
- `src/scenes/init/MenuScene.gd`
- `src/components/EndRay.gd`
- multipass shader files
- `MeshIcosahedron.applied_shaders/default_shaders`
- scene transition helpers in `MainScene.gd`

## Deliberate simplifications

- One collider per figure, not 20 side colliders.
- Sides are data first, visuals second.
- Modifiers are passive data until concrete effects exist.
- One main scene; app states replace scene loading.
