# Wanuy Ñan

Videojuego de plataformas 2D desarrollado en **Godot Engine 4.6** (renderizador *GL Compatibility*).

## 📜 Contexto histórico

El juego se sitúa en el año **1532**, durante un momento crucial para el Tahuantinsuyo: el inicio de la invasión española y la conquista del Imperio Incaico.

El jugador acompaña a un valiente súbdito del Imperio Inca que, al avistar por primera vez a los conquistadores liderados por Francisco Pizarro, sospecha que esas extrañas personas con armaduras plateadas no traen buenas intenciones.

Decidido a advertir a su gobernante, el **Atahualpa**, emprende una peligrosa aventura a través de montañas, caminos y territorios del imperio. En su recorrido deberá enfrentarse a soldados españoles y animales salvajes que intentarán impedir su misión.

Armado únicamente con su **lanza** y su **honda**, el protagonista deberá superar obstáculos, derrotar enemigos y avanzar por distintos niveles hasta llegar a la capital del imperio, donde se encuentra su señor Inca. Solo entonces podrá cumplir su objetivo: advertir sobre la llegada de los invasores.

## 🎮 Controles

| Acción | Tecla / Entrada |
|--------|-----------------|
| Moverse a la izquierda | `A` / `←` |
| Moverse a la derecha | `D` / `→` |
| Saltar | `Espacio` |
| Ataque con lanza | `Tab` |
| Ataque cuerpo a cuerpo | `Enter` |
| Apuntar / lanzar honda | Mantener y soltar **clic izquierdo** del mouse |

> Al apuntar con la honda, el jugador se detiene y se muestra una **trayectoria parabólica** que predice el vuelo de la piedra hacia la posición del cursor.

## ✨ Estado actual (lo implementado)

### Jugador (`scripts/player.gd`)
- Movimiento horizontal, salto y gravedad (`CharacterBody2D`).
- Sistema de **vidas** (5 por defecto) con señal `vida_cambiada` para la interfaz.
- **Invencibilidad temporal** con parpadeo tras recibir daño.
- Ataques: lanza (`spear`), cuerpo a cuerpo (`ataque`) y honda a distancia.
- **Honda con física parabólica**: apuntado con línea de trayectoria y disparo de piedra (`scripts/player/piedra.gd`) hacia el cursor.
- Animaciones: `idle`, `run`, `salto`, `spear`, `ataque`, `honda`, `soltar`, `death`.

### Enemigos (`scripts/enemy/`)
- **Clase base `Enemy`** (`enemy.gd`): gravedad, detección del jugador por rango, patrulla, vidas y sistema de daño compartido.
- **Enemigo a distancia** (`ranged-enemy.gd`): patrulla entre límites, detecta al jugador y **dispara ráfagas de proyectiles** en abanico (`projectile.gd`).
- **Enemigo cuerpo a cuerpo** (`melee_enemy.gd`): patrulla con detección de bordes vía `RayCast`, persigue al jugador, ataca con *cooldown* y reproduce animación de muerte.
- **Spawner de enemigos** (`enemy_spawner.gd`): genera enemigos periódicamente en puntos (`Marker2D`) definidos en la escena.

### Interfaz de usuario (`scripts/ui/`)
- **Menú principal** (`menu.gd`): botones de *Jugar* y *Salir*.
- **HUD de vidas** (`heads_up_display.gd`): corazones dinámicos sincronizados con las vidas del jugador (con *preview* en el editor).
- **Pantalla de Game Over** (`game_over.gd`): pausa el juego y permite reiniciar el nivel.

### Niveles y escenas (`scenes/`)
- `main.tscn` — escena principal que integra nivel, jugador, HUD, spawner y Game Over.
- `levels/level-1.tscn` — primer nivel jugable.
- `map.tscn`, `menu.tscn` y escenas de enemigos, jugador y UI.
- Fondos disponibles: Cusco y Machu Picchu.

## 📁 Estructura del proyecto

```
wanuy-nan-videogame/
├── assets/              # Sprites, fondos, fuentes e íconos de UI
│   ├── player/          # Animaciones del protagonista
│   ├── enemy/           # Sprites de enemigos
│   ├── sprites/         # Fondos y tilemaps
│   ├── ui/              # Corazones, menú
│   └── fonts/           # PressStart2P, upheavtt
├── scenes/              # Escenas (.tscn)
│   ├── levels/          # Niveles
│   ├── player/          # Jugador y piedra
│   ├── enemy/           # Enemigos y proyectiles
│   └── ui/              # Menú, HUD, Game Over
├── scripts/             # Lógica en GDScript
│   ├── player.gd
│   ├── player/
│   ├── enemy/
│   └── ui/
├── tile_sets/           # Tilesets del terreno
└── project.godot        # Configuración del proyecto
```

## 🚀 Cómo ejecutar

1. Instala **Godot Engine 4.6** (o superior de la rama 4.x).
2. Clona este repositorio.
3. Abre Godot, selecciona *Importar* y elige el archivo `project.godot`.
4. Pulsa **F5** (o el botón *Play*) para ejecutar el juego.

## 🛠️ Tecnologías

- **Motor:** Godot Engine 4.6
- **Lenguaje:** GDScript
- **Renderizado:** GL Compatibility (compatible con equipos de gama baja y web)

## 🗺️ Capas de física

| Capa | Nombre |
|------|--------|
| 1 | Sólido |
| 2 | Daño |
| 3 | Jugador |
| 4 | Recolectable |
| 5 | Enemigo |

---

*Proyecto en desarrollo. La historia y las mecánicas continúan expandiéndose.*
