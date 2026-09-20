# Bloodstream Brawl

A top-down hack-and-slash where you play a white blood cell fighting waves of viruses from the inside. Swap between a spear, greatsword, and crossbow on the fly to survive as long as you can.

![Gameplay](docs/gameplay.gif)

**[Play it in your browser on itch.io](https://cutra-6.itch.io/combat-demo)**

> **Status:** Prototype. This began as a weekend combat demo built to answer one question: *does the moment-to-moment combat feel good?* It is being grown into a full wave-survival game with upgrades. All visuals are intentionally placeholder shapes so the focus stays on mechanics and systems.

## Controls

| Input | Action |
| --- | --- |
| `W` `A` `S` `D` | Move |
| Mouse | Aim |
| `Space` | Attack |
| Left / Right click | Switch weapons |

## The Weapons

The design centers on switching weapons frequently mid-fight, so each weapon plays differently and fills a different role.

| Weapon | Feel |
| --- | --- |
| **Spear** | Thrust attack with pushback for controlling space |
| **Greatsword** | Wide arc sweep with a forward lunge |
| **Crossbow** | Ranged projectile, but you plant your feet to fire |

## Combat Systems

- **Combo chains with input buffering**, so inputs pressed slightly early still register
- **Hitlag, screen shake, and knockback** for impact feedback
- **Hyper armor** on committed attacks
- **Health and invincibility frames** for the player
- **Wave spawner** with ramping difficulty, score tracking, and start / game-over screens

## Architecture

Built in **Godot 4.7** with **GDScript**. The main design goals were extensibility and decoupling: adding a new weapon or enemy should mean adding content, not rewriting systems.

**Weapons**
- A `WeaponManager` owns the equipped weapon and swapping between them
- Weapons communicate through signals (`attack_started`, `attack_finished`) rather than direct references, so the player, UI, and effects can react without being coupled to any specific weapon
- Hitboxes are driven entirely by animation tracks, which keeps attack timing in one place

**Enemies**
- Scene inheritance with a shared `base_enemy.gd`: a state machine, universal damage handling, and knockback modeled as a `STUNNED` state
- Child enemies override virtual methods to add their own behavior
- Enemy stats are data-driven through a custom `EnemyData` Resource, so tuning an enemy doesn't require touching code
- States are integer constants instead of enums, since enums don't inherit cleanly across GDScript scripts

**Notable problems solved**
- **Double-firing hitboxes:** mixing code-side `enable_hitbox()` calls with animation call tracks fired `area_entered` twice. Moving hitbox control fully into animations fixed it.
- **Sustained contact damage:** enemy contact damage polls `get_overlapping_areas()` each physics frame, because `area_entered` alone misses damage when overlap continues.
- **HTML5 export bug:** runtime `load()` broke in the web build; switching to `preload()` at the top of scripts resolved it.

## Project Structure

```
Arena/       Level scene and arena setup
Enemies/     Enemy scenes and scripts
Player/      Player scene and controller
Weapons/     Weapon scenes, WeaponManager, and projectiles
globals/     Autoloads and shared state
main.gd      Game loop and screen flow
wave_spawner.gd  Wave-based enemy spawning
enemy_data.gd    EnemyData resource definition
```

## Running Locally

1. Install [Godot 4.7](https://godotengine.org/download)
2. Clone the repo:
   ```
   git clone https://github.com/CarterLaFrenz/Combat-Demo.git
   ```
3. Open Godot, choose **Import**, and select `project.godot`
4. Press `F5` to run

## Roadmap

- [x] Three-weapon combat prototype with combos and hit feedback
- [x] Wave spawner with ramping difficulty
- [x] Public browser build on itch.io
- [ ] Scalable enemy system (in progress): chaser, rusher, and ranged enemy types
- [ ] Wave scaling logic
- [ ] Upgrade selection between waves
- [ ] Mid-combo weapon switching (weapon swaps currently can't interrupt a combo)
- [ ] On-screen control hints and reworked weapon-swap input
- [ ] Art and audio pass

## Credits

Designed and programmed by [Carter LaFrenz](https://github.com/CarterLaFrenz). All visuals are placeholder shapes made in Godot, and there is no third-party art or audio.

## License

Add a license here (MIT is a common choice for portfolio projects) and include a matching `LICENSE` file in the repo root.
