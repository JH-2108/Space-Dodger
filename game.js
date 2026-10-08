const canvas = document.getElementById("gameCanvas");
const ctx = canvas.getContext("2d");

const WIDTH = 320;
const HEIGHT = 480;

const scoreDisplay = document.getElementById("score");
const livesDisplay = document.getElementById("lives");
const difficultyDisplay = document.getElementById("difficulty");

const startButton = document.getElementById("startButton");
const pauseButton = document.getElementById("pauseButton");


// =====================================================
// SPRITES
// =====================================================

const SPRITES = {

    player: [
        ".......XX.......",
        "......XXXX......",
        "......XXXX......",
        ".....XXXXXX.....",
        ".....XXXXXX.....",
        "....XXXXXXXX....",
        "...XXXXXXXXXX...",
        "...XXXXXXXXXX...",
        "..XXXXXXXXXXXX..",
        "..XXXXXXXXXXXX..",
        ".XXXXXXXXXXXXXX.",
        ".XXXXXXXXXXXXXX.",
        "XXXXXXXXXXXXXXXX",
        "XXXXXXXXXXXXXXXX",
        "XXXXXX....XXXXXX",
        "XXXXXX....XXXXXX"
    ],

    asteroid: [
        ".....XXXXXX.....",
        "...XXXXXXXXXX...",
        "..XXXXXXXXXXXX..",
        ".XXXXXXXXXXXXXX.",
        "XXXXXXXXXXXXXXXX",
        "XXXXXXXXXXXXXXXX",
        "XXXXXXXXXXXXXXXX",
        "XXXXXXXXXXXXXXXX",
        "XXXXXXXXXXXXXXXX",
        "XXXXXXXXXXXXXXXX",
        ".XXXXXXXXXXXXXX.",
        "..XXXXXXXXXXXX..",
        "...XXXXXXXXXX...",
        "....XXXXXXXX....",
        "......XXXX......",
        ".......XX......."
    ],

    bullet: [
        "......XX........",
        "......XX........",
        ".....XXXX.......",
        ".....XXXX.......",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........",
        "......XX........"
    ],

    explosion: [
        ".......XX.......",
        "...X...XX...X...",
        "....XXXXXXXX....",
        "..XXXXXXXXXXXX..",
        "....XXXXXXXX....",
        "X...XXXXXXXX...X",
        "....XXXXXXXX....",
        "..XXXXXXXXXXXX..",
        "....XXXXXXXX....",
        "X...XXXXXXXX...X",
        "....XXXXXXXX....",
        "..XXXXXXXXXXXX..",
        "....XXXXXXXX....",
        "...X...XX...X...",
        ".......XX.......",
        "................"
    ]
};


// =====================================================
// GAME SETTINGS
// =====================================================

const PLAYER_SCALE = 2;
const ASTEROID_SCALE = 2;
const BULLET_SCALE = 2;


// =====================================================
// PLAYER
// =====================================================

const player = {

    x: 144,
    y: 410,

    width: 32,
    height: 32,

    speed: 190,

    acceleration: 0,
    maxAcceleration: 90
};


// =====================================================
// INPUT
// =====================================================

const keys = {

    left: false,
    right: false,
    forward: false,
    shooting: false
};


document.addEventListener("keydown", (event) => {

    if (
        event.code === "ArrowLeft" ||
        event.code === "KeyA"
    ) {
        keys.left = true;
    }

    if (
        event.code === "ArrowRight" ||
        event.code === "KeyD"
    ) {
        keys.right = true;
    }

    if (
        event.code === "ArrowUp" ||
        event.code === "KeyW"
    ) {
        keys.forward = true;
    }

    if (event.code === "Space") {

        keys.shooting = true;

        event.preventDefault();
    }
});


document.addEventListener("keyup", (event) => {

    if (
        event.code === "ArrowLeft" ||
        event.code === "KeyA"
    ) {
        keys.left = false;
    }

    if (
        event.code === "ArrowRight" ||
        event.code === "KeyD"
    ) {
        keys.right = false;
    }

    if (
        event.code === "ArrowUp" ||
        event.code === "KeyW"
    ) {
        keys.forward = false;
    }

    if (event.code === "Space") {
        keys.shooting = false;
    }
});


// =====================================================
// GAME VARIABLES
// =====================================================

let score = 0;
let lives = 3;

let highScore =
    Number(localStorage.getItem("spaceDodgerHighScore")) || 0;

let difficultyLevel = 1;

const MAX_DIFFICULTY = 10;
const SCORE_PER_LEVEL = 1000;

let gameRunning = false;
let gamePaused = false;

let lastTime = 0;

let asteroidSpawnTimer = 0;
let shootTimer = 0;

const asteroids = [];
const bullets = [];
const particles = [];
const stars = [];


// =====================================================
// DIFFICULTY SYSTEM
// =====================================================

function updateDifficulty() {

    difficultyLevel = Math.min(
        MAX_DIFFICULTY,
        Math.floor(score / SCORE_PER_LEVEL) + 1
    );

    difficultyDisplay.textContent = difficultyLevel;
}


function getAsteroidSpawnInterval() {

    return Math.max(
        0.25,
        1.0 - (difficultyLevel - 1) * 0.075
    );
}


function getAsteroidSpeed() {

    return 70 + (difficultyLevel - 1) * 18;
}


// =====================================================
// STARS
// =====================================================

for (let i = 0; i < 80; i++) {

    stars.push({

        x: Math.random() * WIDTH,
        y: Math.random() * HEIGHT,

        size: Math.random() < 0.8 ? 1 : 2,

        speed: 20 + Math.random() * 50
    });
}


// =====================================================
// DRAW BITMAP
// =====================================================

function drawBitmap(bitmap, x, y, scale, fillStyle) {

    ctx.fillStyle = fillStyle;

    for (let row = 0; row < bitmap.length; row++) {

        for (let col = 0; col < bitmap[row].length; col++) {

            if (bitmap[row][col] === "X") {

                ctx.fillRect(
                    x + col * scale,
                    y + row * scale,
                    scale,
                    scale
                );
            }
        }
    }
}


// =====================================================
// ASTEROIDS
// =====================================================

function spawnAsteroid() {

    const size = 32;

    asteroids.push({

        x: Math.random() * (WIDTH - size),
        y: -size,

        width: size,
        height: size,

        speed:
            getAsteroidSpeed() *
            (0.8 + Math.random() * 0.4)
    });
}


// =====================================================
// BULLETS
// =====================================================

function shoot() {

    bullets.push({

        x:
            player.x +
            player.width / 2 -
            2,

        y:
            player.y - 10,

        width: 4,
        height: 16,

        speed: 500
    });
}


// =====================================================
// PARTICLES
// =====================================================

function createExplosion(x, y) {

    for (let i = 0; i < 12; i++) {

        particles.push({

            x,
            y,

            vx:
                (Math.random() - 0.5) *
                120,

            vy:
                (Math.random() - 0.5) *
                120,

            life: 0.5
        });
    }
}


// =====================================================
// COLLISION
// =====================================================

function collision(a, b) {

    return (
        a.x < b.x + b.width &&
        a.x + a.width > b.x &&
        a.y < b.y + b.height &&
        a.y + a.height > b.y
    );
}


// =====================================================
// RESET GAME
// =====================================================

function resetGame() {

    score = 0;
    lives = 3;

    difficultyLevel = 1;

    player.x = 144;
    player.y = 410;

    player.acceleration = 0;

    asteroids.length = 0;
    bullets.length = 0;
    particles.length = 0;

    asteroidSpawnTimer = 0;
    shootTimer = 0;

    updateHUD();
    updateDifficulty();
}


// =====================================================
// HUD
// =====================================================

function updateHUD() {

    scoreDisplay.textContent = score;
    livesDisplay.textContent = lives;

    difficultyDisplay.textContent =
        difficultyLevel;

    if (score > highScore) {

        highScore = score;

        localStorage.setItem(
            "spaceDodgerHighScore",
            highScore
        );
    }
}


// =====================================================
// UPDATE
// =====================================================

function update(dt) {

    // -----------------------------
    // PLAYER MOVEMENT
    // -----------------------------

    let movementSpeed = player.speed;

    if (keys.forward) {

        player.acceleration +=
            120 * dt;

        player.acceleration =
            Math.min(
                player.acceleration,
                player.maxAcceleration
            );

    } else {

        player.acceleration -=
            100 * dt;

        player.acceleration =
            Math.max(
                player.acceleration,
                0
            );
    }

    movementSpeed += player.acceleration;


    if (keys.left) {

        player.x -=
            movementSpeed * dt;
    }

    if (keys.right) {

        player.x +=
            movementSpeed * dt;
    }


    player.x =
        Math.max(
            0,
            Math.min(
                WIDTH - player.width,
                player.x
            )
        );


    // -----------------------------
    // DIFFICULTY
    // -----------------------------

    updateDifficulty();


    // -----------------------------
    // ASTEROID SPAWNING
    // -----------------------------

    asteroidSpawnTimer -= dt;

    if (asteroidSpawnTimer <= 0) {

        spawnAsteroid();

        asteroidSpawnTimer =
            getAsteroidSpawnInterval();
    }


    // -----------------------------
    // SHOOTING
    // -----------------------------

    shootTimer -= dt;

    if (
        keys.shooting &&
        shootTimer <= 0
    ) {

        shoot();

        shootTimer = 0.18;
    }


    // -----------------------------
    // BULLETS
    // -----------------------------

    for (
        let i = bullets.length - 1;
        i >= 0;
        i--
    ) {

        const bullet = bullets[i];

        bullet.y -=
            bullet.speed * dt;


        if (bullet.y < -20) {

            bullets.splice(i, 1);

            continue;
        }


        for (
            let j = asteroids.length - 1;
            j >= 0;
            j--
        ) {

            const asteroid =
                asteroids[j];


            if (
                collision(
                    bullet,
                    asteroid
                )
            ) {

                createExplosion(
                    asteroid.x +
                    asteroid.width / 2,

                    asteroid.y +
                    asteroid.height / 2
                );


                bullets.splice(i, 1);

                asteroids.splice(j, 1);


                score += 100;

                updateDifficulty();
                updateHUD();

                break;
            }
        }
    }


    // -----------------------------
    // ASTEROIDS
    // -----------------------------

    for (
        let i = asteroids.length - 1;
        i >= 0;
        i--
    ) {

        const asteroid =
            asteroids[i];


        asteroid.y +=
            asteroid.speed * dt;


        if (
            asteroid.y >
            HEIGHT + asteroid.height
        ) {

            asteroids.splice(i, 1);

            score += 10;

            updateDifficulty();
            updateHUD();

            continue;
        }


        if (
            collision(
                player,
                asteroid
            )
        ) {

            createExplosion(
                player.x +
                player.width / 2,

                player.y +
                player.height / 2
            );


            asteroids.splice(i, 1);

            lives--;

            updateHUD();


            if (lives <= 0) {

                gameOver();

                return;
            }
        }
    }


    // -----------------------------
    // PARTICLES
    // -----------------------------

    for (
        let i = particles.length - 1;
        i >= 0;
        i--
    ) {

        const particle =
            particles[i];


        particle.x +=
            particle.vx * dt;

        particle.y +=
            particle.vy * dt;

        particle.life -= dt;


        if (particle.life <= 0) {

            particles.splice(i, 1);
        }
    }


    // -----------------------------
    // STARS
    // -----------------------------

    const starSpeedMultiplier =
        1 +
        player.acceleration / 60;


    for (const star of stars) {

        star.y +=
            star.speed *
            starSpeedMultiplier *
            dt;


        if (star.y > HEIGHT) {

            star.y = 0;

            star.x =
                Math.random() * WIDTH;
        }
    }
}


// =====================================================
// DRAW
// =====================================================

function draw() {

    ctx.clearRect(
        0,
        0,
        WIDTH,
        HEIGHT
    );


    ctx.fillStyle = "#020208";

    ctx.fillRect(
        0,
        0,
        WIDTH,
        HEIGHT
    );


    // -----------------------------
    // STARS
    // -----------------------------

    for (const star of stars) {

        ctx.fillStyle = "#ffffff";

        ctx.fillRect(
            star.x,
            star.y,
            star.size,
            star.size
        );
    }


    // -----------------------------
    // PLAYER
    // -----------------------------

    drawBitmap(
        SPRITES.player,
        player.x,
        player.y,
        PLAYER_SCALE,
        "#4fdfff"
    );


    // -----------------------------
    // ASTEROIDS
    // -----------------------------

    for (const asteroid of asteroids) {

        drawBitmap(
            SPRITES.asteroid,
            asteroid.x,
            asteroid.y,
            ASTEROID_SCALE,
            "#888899"
        );
    }


    // -----------------------------
    // BULLETS
    // -----------------------------

    for (const bullet of bullets) {

        drawBitmap(
            SPRITES.bullet,
            bullet.x,
            bullet.y,
            BULLET_SCALE,
            "#ffff66"
        );
    }


    // -----------------------------
    // PARTICLES
    // -----------------------------

    for (const particle of particles) {

        ctx.fillStyle = "#ffffff";

        ctx.globalAlpha =
            Math.max(
                particle.life * 2,
                0
            );

        ctx.fillRect(
            particle.x,
            particle.y,
            2,
            2
        );
    }

    ctx.globalAlpha = 1;


    // -----------------------------
    // GAME OVER
    // -----------------------------

    if (!gameRunning) {

        if (lives <= 0) {

            ctx.fillStyle =
                "rgba(0, 0, 0, 0.7)";

            ctx.fillRect(
                0,
                0,
                WIDTH,
                HEIGHT
            );


            ctx.fillStyle = "white";

            ctx.textAlign = "center";

            ctx.font =
                "bold 24px Times New Roman";

            ctx.fillText(
                "GAME OVER",
                WIDTH / 2,
                HEIGHT / 2 - 20
            );


            ctx.font =
                "14px Arial";

            ctx.fillText(
                "Press START to play again",
                WIDTH / 2,
                HEIGHT / 2 + 15
            );


            ctx.textAlign = "left";
        }
    }
}


// =====================================================
// GAME LOOP
// =====================================================

function gameLoop(timestamp) {

    if (!gameRunning) {

        draw();

        return;
    }


    if (gamePaused) {

        draw();

        requestAnimationFrame(
            gameLoop
        );

        return;
    }


    const dt =
        Math.min(
            (timestamp - lastTime) / 1000,
            0.05
        );


    lastTime = timestamp;


    update(dt);

    draw();


    requestAnimationFrame(
        gameLoop
    );
}


// =====================================================
// START
// =====================================================

startButton.addEventListener(
    "click",
    () => {

        resetGame();

        gameRunning = true;
        gamePaused = false;

        lastTime =
            performance.now();

        requestAnimationFrame(
            gameLoop
        );
    }
);


// =====================================================
// PAUSE
// =====================================================

pauseButton.addEventListener(
    "click",
    () => {

        if (!gameRunning) {
            return;
        }

        gamePaused =
            !gamePaused;

        pauseButton.textContent =
            gamePaused
                ? "RESUME"
                : "PAUSE";
    }
);


// =====================================================
// GAME OVER
// =====================================================

function gameOver() {

    gameRunning = false;

    gamePaused = false;

    pauseButton.textContent =
        "PAUSE";

    updateHUD();

    draw();
}


// =====================================================
// INITIALIZE
// =====================================================

updateHUD();
updateDifficulty();
draw();