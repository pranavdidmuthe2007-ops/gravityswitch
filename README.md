# Gravity Switch

**Gravity Switch** is a portrait-oriented 2D puzzle-platformer made with Godot 4 and GDScript. The player moves forward automatically; one tap reverses gravity to avoid hazards, collect energy orbs, and reach the exit.

The project targets Android and iOS, while remaining playable on desktop for development and testing.

## Features

- 30 campaign levels across three worlds
- Endless mode with procedural obstacle chunks and saved personal bests
- One-tap gravity switching, with mouse click, <kbd>Space</kbd>, and touch support
- Spikes, moving hazards, timed laser beams, rotating hazards, and collapsing platforms
- Three-star scoring based on completion, orb collection, and switch-budget performance
- Five unlockable colour themes and twelve achievements
- Local progress/settings persistence and procedural sound effects
- Portrait mobile layout with a 720 × 1280 base viewport

## Requirements

- [Godot Engine 4.7](https://godotengine.org/download/) or a compatible Godot 4 release
- No external game assets or third-party packages are required to run the project

For mobile exports, install the platform tooling described in Godot’s export documentation:

- Android: Android SDK and JDK 17
- iOS: macOS, Xcode, and an Apple Developer signing identity

## Run the game

### Godot editor

1. Open Godot and choose **Import**.
2. Select `project.godot` from this repository.
3. Open the imported project and press <kbd>F6</kbd> / <kbd>F5</kbd> to run it.

### Command line

From the repository root, run:

```powershell
godot --path . --editor
godot --path .
```

If `godot` is not on your `PATH`, replace it with the full path to your Godot executable. The included [Play_Gravity_Switch.bat](Play_Gravity_Switch.bat) is a local Windows convenience launcher; update its Godot path if you choose to use it.

## Controls

| Input | Action |
| --- | --- |
| Tap / left mouse click | Reverse gravity |
| <kbd>Space</kbd> | Reverse gravity |

Horizontal movement is automatic. A brief input cooldown avoids duplicate gravity switches from a single tap.

## Gameplay

Each campaign level contains three energy orbs and an exit portal.

- **1 star** — finish the level
- **2 stars** — finish after collecting every orb
- **3 stars** — also remain within the level’s gravity-switch budget

Worlds introduce the mechanics in this order:

| World | Levels | Focus |
| --- | ---: | --- |
| Neon Training | 1–10 | Gravity-switch fundamentals, spikes, and platforms |
| Gravity Factory | 11–20 | Lasers, moving hazards, and collapsing platforms |
| Quantum Lab | 21–30 | Rotating hazards, dense obstacle chains, and combined mechanics |

Endless mode progressively increases speed and records the best distance in the local save file.

## Project layout

```text
.
├── project.godot                 # Godot configuration, input map, autoloads
├── export_presets.cfg            # Android, iOS, and Windows export presets
├── scenes/
│   ├── gameplay/                 # Player, hazards, platforms, endless mode
│   ├── levels/                   # Base scene and 30 campaign levels
│   └── ui/                       # Splash, menus, HUD, and result screens
├── scripts/
│   ├── autoload/                 # Save, audio, theme, achievement, game state
│   └── ui/                       # UI controllers
├── tests/                        # Headless integration test scenes and runners
└── build/                        # Generated/exported artifacts, when present
```

The project registers these global autoloads: `SaveManager`, `AudioManager`, `ThemeManager`, `AchievementManager`, and `GameState`.

## Test

Run the primary headless integration suite from the repository root:

```powershell
godot --headless --path . res://tests/test_runner.tscn
```

The test scene checks the autoloads, save/progression behavior, gravity switching, game scenes, endless mode, and that all 30 level scenes can be instantiated. It exits with a non-zero code if a check fails.

> The test suite updates the local Godot user-data save while exercising persistence. Remove or reset the save through the game if you need a clean progress state afterwards.

## Export

Export presets are already defined for **Android**, **iOS**, and **Windows Desktop**. Configure SDK paths and signing credentials in the Godot editor before creating a release build.

```powershell
# Example debug Android export
godot --headless --path . --export-debug "Android" "build/GravitySwitch.apk"

# Example Windows export
godot --headless --path . --export-release "Windows Desktop" "build/windows/GravitySwitch.exe"
```

For Android release builds, provide a keystore in the Android export preset. For iOS, generate the Xcode project on macOS, configure signing in Xcode, then build from there.

## Save data

Progress, settings, unlocks, and endless-mode high scores are stored locally through Godot’s `user://` location. They are intentionally not committed to this repository.

## License

No license file is currently included. Add an explicit license before distributing the source or accepting external contributions.
