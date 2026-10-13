# GRAVITY SWITCH (2D Mobile Puzzle-Platformer)

**Gravity Switch** is a complete, polished 2D mobile physics puzzle-platformer developed with **Godot Engine 4.x** and **GDScript**. Designed specifically for Android phones/tablets and Apple iOS devices (iPhone/iPad), the game features a responsive single-tap gravity-reversal mechanic, minimalist glowing neon sci-fi aesthetics, 30 designed levels across 3 themed worlds, an infinite Endless Challenge Mode, unlockable character skins & color themes, an in-game achievements system with toast notifications, procedural synthesizer audio, local save progression, and safe-area aware mobile UI.

---

## 1. Game Overview

* **Title**: Gravity Switch
* **Engine**: Godot Engine 4.x (v4.7.2+)
* **Language**: GDScript (Typed)
* **Target Platforms**: Android & iOS (Touchscreen), Windows/macOS/Linux (Desktop & Dev)
* **Orientation**: Portrait (`720 x 1280` base resolution, scalable `canvas_items` / `expand`)
* **Visual Style**: Minimalist Neon Sci-Fi with dark navy backdrops, electric cyan and magenta accents, glowing particle bursts, and geometric obstacles.
* **Audio**: Procedural waveform synthesis for SFX and ambient cyber soundtrack (zero external asset dependencies, zero latency).
* **Game Modes**:
  1. **Level Campaign**: 30 handcrafted levels across 3 themed worlds.
  2. **Endless Challenge Mode**: Procedurally generated infinite obstacle runner with real-time distance tracking and high scores.
* **Progression Systems**:
  - Star ratings (up to 3 stars per level)
  - 5 Unlockable Neon Character Skins
  - 12 In-Game Achievements with animated toast banners
  - Local save validation & settings persistence

---

## 2. Core Gameplay Mechanics

1. **Automatic Forward Motion**: The character accelerates and glides forward horizontally at constant velocity (`380 px/s`). Direct horizontal input is disabled.
2. **Gravity Reversal (One Tap)**:
   - Tapping anywhere in the gameplay area or pressing Space / Left-Click immediately flips the gravity vector between downward ($+g$) and upward ($-g$).
   - A directional impulse is applied for crisp, zero-latency vertical control.
   - Built-in debouncing (`0.08s` cooldown) prevents accidental double-triggers from a single physical touch.
   - Dynamic gravity indicator shows the current gravity vector in real time.
3. **Hazards**:
   - **Floor & Ceiling Spikes**: Triangular neon spikes with fair collision boxes.
   - **Moving Spikes**: Sinusoidally oscillating vertical hazards.
   - **Laser Beams**: Timed pulsing lasers with pre-activation warning flicker.
   - **Rotating Blades**: Continuous revolving cross hazards.
   - **Collapsing Platforms**: Step-activated platforms that shake, collapse after `0.55s`, and respawn after `2.0s`.
4. **Collectibles & Star Ratings**:
   - 3 floating energy orbs per level.
   - **1 Star**: Complete the level.
   - **2 Stars**: Collect all 3 energy orbs.
   - **3 Stars**: Complete the level within the level's gravity flip budget.
5. **Death & Instant Restart**:
   - Instant response on hazard contact: explosive particle burst and screen state halt.
   - Game Over modal with prominent Retry button, or optional Instant Auto-Retry setting.

---

## 3. Project Architecture

```text
res://
├── project.godot                     # Project configuration & Autoload definitions
├── export_presets.cfg                # Android, iOS, and Windows export configurations
├── icon.svg                          # Custom vector neon application icon
├── build/                            # Export packages (gravityswitch.pck)
├── assets/                           # Audio, textures, and fonts
├── tests/                            # Automated in-engine test suite
│   ├── test_runner.tscn
│   └── test_runner_scene.gd
├── scenes/
│   ├── gameplay/
│   │   ├── game.tscn                 # Dynamic level runner
│   │   ├── endless_mode.tscn         # Infinite procedural obstacle runner
│   │   ├── player.tscn               # CharacterBody2D with trail & particles
│   │   ├── exit_portal.tscn          # Area2D finish portal with rotating rings
│   │   ├── collectibles/
│   │   │   └── energy_orb.tscn       # Diamond energy orb with float bobbing
│   │   ├── hazards/
│   │   │   ├── spike.tscn            # Floor & ceiling spikes
│   │   │   ├── moving_spike.tscn     # Oscillating moving spike
│   │   │   ├── laser_beam.tscn       # Timed pulsing laser beam
│   │   │   └── rotating_hazard.tscn  # Revolving 4-way blade obstacle
│   │   └── platforms/
│   │       ├── platform.tscn         # Solid neon platform
│   │       └── collapsing_platform.tscn # Collapsing platform
│   ├── levels/
│   │   ├── level_base.tscn           # Reusable level scene template
│   │   ├── world_1/ (Levels 1–10: Neon Training)
│   │   ├── world_2/ (Levels 11–20: Gravity Factory)
│   │   └── world_3/ (Levels 21–30: Quantum Lab)
│   └── ui/
│       ├── splash_screen.tscn        # Animated loading splash
│       ├── main_menu.tscn            # Menu with animated character demo & modes
│       ├── hud.tscn                  # Portrait HUD (Pause, Orbs, Flips, Level)
│       ├── pause_menu.tscn           # Translucent pause overlay
│       ├── game_over.tscn            # Failure modal with instant retry
│       ├── level_complete.tscn       # Victory modal with star animations
│       ├── level_select.tscn         # 30-level card grid with 3 world tabs
│       ├── skins_menu.tscn           # Unlockable neon color themes menu
│       ├── achievements_menu.tscn    # In-game awards & badges viewer
│       └── settings_menu.tscn        # Audio sliders, haptics, auto-retry toggles
└── scripts/
    ├── autoload/
    │   ├── game_state.gd             # Global game state, scores, level switching
    │   ├── save_manager.gd           # Local persistent JSON storage & validation
    │   ├── audio_manager.gd          # Procedural audio waveform synthesizer
    │   ├── theme_manager.gd          # Dynamic skins and color themes controller
    │   └── achievement_manager.gd    # 12 achievements tracker & toast notifications
    ├── player_controller.gd
    ├── level_base.gd
    ├── endless_mode.gd
    ├── exit_portal.gd
    ├── collectible.gd
    ├── hazard.gd
    ├── moving_hazard.gd
    ├── laser_beam.gd
    ├── rotating_hazard.gd
    ├── collapsing_platform.gd
    └── ui/                           # UI controllers
```

---

## 4. The 30 Campaign Levels & Endless Mode

* **World 1: Neon Training (Levels 1–10)**:
  - *Theme*: Cyan glow & dark navy void.
  - *Mechanics*: Gravity flip fundamentals, floor/ceiling spikes, flight path timing, introductory platforms.
  - *Levels 1–3*: Interactive tutorial hints.
* **World 2: Gravity Factory (Levels 11–20)**:
  - *Theme*: Industrial amber & laser violet.
  - *Mechanics*: Timed laser beams, moving vertical spike hazards, crumbling platforms, narrow passages.
* **World 3: Quantum Lab (Levels 21–30)**:
  - *Theme*: Quantum magenta & neon emerald.
  - *Mechanics*: Revolving cross blades, dual-layer laser barriers, rapid obstacle chains.
  - *Level 30*: The Grand Finale gauntlet combining all mechanics with a game completion sequence.
* **⚡ Endless Challenge Mode**:
  - Procedural dynamic chunk generator that seamlessly stitches hazard patterns ahead of the player while recycling old segments behind the camera for 60 FPS mobile performance.
  - Velocity scales progressively from `380 px/s` up to `560 px/s`.
  - Saves personal best records in `user://gravity_switch_save.json`.

---

## 5. Unlockable Neon Skins & Achievements

### Character Skins:
1. **Cyber Cyan**: Default neon palette (0 stars required).
2. **Neon Magenta**: Unlocked at 15 stars.
3. **Solar Amber**: Unlocked at 30 stars.
4. **Quantum Emerald**: Unlocked at 45 stars.
5. **Plasma Violet**: Unlocked at 60 stars.

### In-Game Achievements:
* **First Flip**: Reversed gravity for the first time.
* **Spark Collector**: Collected 10 total energy orbs.
* **Orb Hoarder**: Collected 50 total energy orbs.
* **Cadet Graduate**: Completed World 1 (Neon Training).
* **Factory Mechanic**: Completed World 2 (Gravity Factory).
* **Quantum Master**: Conquered World 3 & Level 30.
* **Star Gatherer**: Earned 30 stars.
* **Starlight Adept**: Earned 60 stars.
* **Galaxy Legend**: Achieved all 90 stars!
* **Endless Runner**: Traveled 250m in Endless Mode.
* **Endless Legend**: Traveled 500m in Endless Mode.
* **Gravity Master**: Performed 100 total gravity switches.

---

## 6. How to Run Locally

### Running with Godot Editor:
1. Open Godot Engine 4.x.
2. Click **Import**, browse to `c:\Users\ASUS\OneDrive\Desktop\gravityswitch`, and open [project.godot](file:///c:/Users/ASUS/OneDrive/Desktop/gravityswitch/project.godot).
3. Press **F5** (or the Play icon) to start playing.

### Running via Command Line:
```powershell
# Run the game directly from project files:
& "C:\Users\ASUS\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"

# Or run the compiled package:
& "C:\Users\ASUS\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --main-pack "build\gravityswitch.pck"
```

---

## 7. Automated Testing & QA

Run the headless integration test suite:
```powershell
& "C:\Users\ASUS\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --headless "res://tests/test_runner.tscn"
```

### Verified Test Output:
```text
==========================================
GRAVITY SWITCH FULL SYSTEM INTEGRATION TEST SUITE
==========================================
--- Testing Procedural Audio Synthesizer ---
[PASS] AudioManager Autoload exists
[PASS] Audio SFX 'switch_up' generated
[PASS] Audio SFX 'switch_down' generated
[PASS] Audio SFX 'orb' generated
[PASS] Audio SFX 'death' generated
[PASS] Audio SFX 'win' generated
[PASS] Audio SFX 'click' generated
[PASS] Ambient music generated and non-empty

--- Testing Save System & Persistence ---
[PASS] SaveManager Autoload exists
[PASS] Recorded 3 stars for Level 1
[PASS] Level 2 unlocked after Level 1 completion
[PASS] Level 1 remains unlocked
[PASS] Setting updated successfully
[PASS] Setting reverted successfully

--- Testing GameState & Star Calculation ---
[PASS] GameState Autoload exists
[PASS] Level initialized to 1
[PASS] Game state active
[PASS] Orb target set to 3
[PASS] Perfect score awards 3 stars (completed + all orbs + under budget)
[PASS] Base completion awards 1 star when orbs and budget missed

--- Testing Theme & Skins System ---
[PASS] ThemeManager Autoload exists
[PASS] Current theme has primary color
[PASS] Default cyber cyan skin is unlocked
[PASS] 5 neon themes registered

--- Testing Achievements System ---
[PASS] AchievementManager Autoload exists
[PASS] 12 achievements registered
[PASS] 'first_flip' achievement marked unlocked

--- Testing Player Physics & Gravity Switching ---
[PASS] Player scene loaded
[PASS] Player starts alive
[PASS] Player starts with normal downward gravity
[PASS] Player gravity inverted to UP
[PASS] Switch cooldown activated to prevent double trigger
[PASS] Player dies properly
[PASS] Player velocity stopped on death

--- Testing Hazards & Collectibles Scenes ---
[PASS] Spike scene exists
[PASS] Moving spike scene exists
[PASS] Laser beam scene exists
[PASS] Rotating hazard scene exists
[PASS] Energy orb scene exists
[PASS] Exit portal scene exists

--- Testing Endless Mode and Menu Scenes ---
[PASS] Endless mode scene loads
[PASS] Skins menu scene loads
[PASS] Achievements menu scene loads

--- Testing All 30 Level Scenes Integrity ---
[PASS] All 30 Level Scenes exist and instantiate cleanly
==========================================
TEST RESULTS SUMMARY:
Passed: 44, Failed: 0
==========================================
ALL TESTS PASSED WITH 100% SUCCESS!
```

---

## 8. Mobile Export & Build Instructions

### Android Setup & Export:
1. **Prerequisites**:
   - Install **Android Studio** and the **Android SDK** (API Level 33+).
   - Set environment variables `ANDROID_HOME` and `JAVA_HOME` (JDK 17).
   - In Godot Editor: Go to **Editor > Editor Settings > Export > Android**:
     - Set path to `adb` (e.g. `C:/Users/<Username>/AppData/Local/Android/Sdk/platform-tools/adb.exe`).
     - Set path to debug keystore (`debug.keystore`).
2. **Exporting Debug APK**:
   ```bash
   godot --headless --export-debug "Android" "build/GravitySwitch.apk"
   ```
3. **Exporting Release AAB (Google Play Store)**:
   - Generate a release keystore:
     ```bash
     keytool -v -genkey -v -keystore release.keystore -alias gravityswitch -keyalg RSA -keysize 2048 -validity 10000
     ```
   - In `export_presets.cfg` (Android preset):
     - Set `package/signed=true`
     - Provide keystore path, alias, and password.
   - Export:
     ```bash
     godot --headless --export-release "Android" "build/GravitySwitch.aab"
     ```

### iOS Setup & Export:
1. **Prerequisites** (Requires macOS & Xcode):
   - macOS computer with **Xcode 15+** installed.
   - Apple Developer account for code signing.
2. **Generating the Xcode Project**:
   ```bash
   godot --headless --export-release "iOS" "build/ios/GravitySwitch.xcodeproj"
   ```
3. **Building & Running in Xcode**:
   - Open `build/ios/GravitySwitch.xcodeproj` in Xcode.
   - In the target settings under **Signing & Capabilities**:
     - Select your Apple Developer Team.
     - Verify Bundle Identifier: `com.antigravity.gravityswitch`.
   - Connect an iPhone/iPad or choose an iOS Simulator.
   - Press **Cmd + R** to build and run on device.
#   g r a v i t y s w i t c h  
 