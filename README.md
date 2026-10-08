# Space Dodgers

**Space Dodgers** is a simple pixel-art space survival game built with **HTML, CSS, and JavaScript**.

Pilot your spaceship, dodge incoming asteroids, and shoot them down to increase your score. As your score increases, the game becomes progressively more difficult.

## How to Play

Your goal is to survive for as long as possible and get the highest score you can.

### Controls

| Key       | Action     |
| --------- | ---------- |
| `A` / `←` | Move left  |
| `D` / `→` | Move right |
| `W` / `↑` | Accelerate |
| `SPACE`   | Shoot      |

## Features

* Pixel-art spaceship
* Incoming asteroids
* Shoot asteroids with Space
* Explosion particle effects
* Three lives
* High-score tracking
* 10 difficulty levels
* Increasing asteroid speed
* Increasing asteroid spawn rate
* Animated starfield
* Pause and resume
* High score saved using browser `localStorage`
* Responsive game layout
* Custom bitmap sprites

## Difficulty System

The game has **10 difficulty levels**.

Every **1,000 points**, the difficulty increases.

|       Score | Difficulty |
| ----------: | ---------: |
|       0–999 |    Level 1 |
| 1,000–1,999 |    Level 2 |
| 2,000–2,999 |    Level 3 |
| 3,000–3,999 |    Level 4 |
| 4,000–4,999 |    Level 5 |
| 5,000–5,999 |    Level 6 |
| 6,000–6,999 |    Level 7 |
| 7,000–7,999 |    Level 8 |
| 8,000–8,999 |    Level 9 |
|      9,000+ |   Level 10 |

As the difficulty increases:

* Asteroids move faster.
* Asteroids spawn more frequently.
* The game becomes progressively harder to survive.

##  Pixel Art

The game's sprites are created directly in JavaScript using bitmap arrays.

For example:

```javascript
player: [
    ".......XX.......",
    "......XXXX......",
    "......XXXX......",
    ".....XXXXXX.....",
    ".....XXXXXX....."
]
```

Each `X` represents a filled pixel, while `.` represents an empty pixel.

This makes it easy to create and modify custom pixel-art sprites directly in the source code.

## Project Structure

```text
Space-Dodgers/
│
├── index.html
├── style.css
├── game.js
└── README.md
```

### `index.html`

Contains the game's webpage structure, HUD, canvas, buttons, and controls.

### `style.css`

Controls the appearance of the game interface and makes the game fit within the browser window without requiring scrolling.

### `game.js`

Contains the main game logic, including:

* Player movement
* Shooting
* Asteroid spawning
* Collision detection
* Score
* Lives
* Difficulty
* Particles
* Starfield
* Game loop
* High-score saving

## Goal

The project was created as a small, beginner-friendly game project focused on learning:

* JavaScript game loops
* Canvas rendering
* Keyboard input
* Collision detection
* Object management
* Pixel-art rendering
* Difficulty scaling
* Browser storage

## Pictures of the game 
<img width="787" height="898" alt="image" src="https://github.com/user-attachments/assets/2c6ff64f-9a51-46f9-b318-20914654d94d" />


Made with 🚀 and JavaScript.

