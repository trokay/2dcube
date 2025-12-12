# Noir Platformer Prototype

A small, stylized 2D platformer prototype for Godot 4.5 built entirely from engine primitives (no imported art). The project demonstrates responsive movement with coyote time and jump buffering, ability unlock shrines, and simple enemies.

## Scenes
- **scenes/Main.tscn**: entry scene with camera, HUD, fade overlay, and Level1 instance.
- **scenes/Level1.tscn**: sample noir level combining platforms, shrines, enemies, and the player.
- **scenes/Player.tscn**: CharacterBody2D cube hero with melee attack, dust VFX, and timers.
- **scenes/EnemyWalker.tscn**: patrolling rectangle enemy.
- **scenes/EnemyTurret.tscn**: static turret that fires projectiles.
- **scenes/AbilityShrine.tscn**: pedestal that unlocks abilities and shows a popup.
- **scenes/Projectile.tscn**: turret bullet.
- **scenes/UI.tscn**: HUD for HP diamonds and ability popups.

## Controls
- Move: **A/D** or **Left/Right**
- Jump: **Space**, **W**, or **Up**
- Dash: **Left Shift** or **Right Mouse**
- Attack: **J** or **Left Mouse**

## Running
Open `project.godot` in Godot 4.5 and press **Play**. Tweak movement values inside `scripts/player.gd`, colors inside scenes, and reorder ability shrine `ability_bit` values to change the progression.

## Частые проблемы
- Сообщение вида «Не удалось загрузить сцену из-за отсутствия зависимостей…» появляется, если открыть `Main.tscn` напрямую без проекта. Убедитесь, что вы открываете файл `project.godot` из корня репозитория, тогда пути вида `res://scenes/Level1.tscn` и `res://scripts/main.gd` будут найдены автоматически.
- Если вы уже открыли сцену напрямую и видите предупреждение, нажмите «Исправить зависимости» и укажите пути до `scenes/Level1.tscn`, `scenes/UI.tscn` и `scripts/main.gd` внутри проекта, либо просто закройте сцену и загрузите проект заново через `project.godot`.
