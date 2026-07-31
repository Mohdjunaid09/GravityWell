# GravityWell
A Flutter-based 2D space game featuring black holes, gravity physics, particle effects, and cosmic animations.
# 🌌 GRAVITY WELL

A physics-inspired **Flutter arcade game** where you launch a growing black hole through deep space, consume celestial bodies, increase your mass, and survive Hawking evaporation.

---

## 🚀 Features

* 🕳️ Launch and control a black hole using drag-and-release mechanics
* ⭐ Consume cosmic objects to increase your mass
* 🔥 Hawking radiation gradually reduces black hole mass over time
* 💥 Particle explosion effects when objects are absorbed
* 🌊 Event horizon ripple animations
* 🎯 Combo streak system with bonus mass rewards
* 🎨 Fully custom rendering using `CustomPainter`
* ⚡ Smooth game loop powered by Flutter's `Ticker`

---

## 📸 Gameplay

1. Drag from the spawn point to aim.
2. Release to launch the black hole.
3. Absorb cosmic objects to grow larger.
4. Build combo streaks for additional mass.
5. Avoid evaporating due to Hawking radiation.
6. Restart and try to achieve a higher total mass.

---

## 🛠️ Built With

* Flutter
* Dart
* CustomPainter
* Ticker Animation System
* Material Design

---

## 📂 Project Structure

```text
lib/
│
├── main.dart
│
├── Models
│   ├── CosmicTarget
│   ├── Singularity
│   ├── HorizonRipple
│   └── Particle
│
├── Game Logic
│   ├── Physics Engine
│   ├── Collision Detection
│   ├── Target Spawning
│   └── Particle System
│
└── Rendering
    └── CosmicCanvasPainter
```

---

## ▶️ Getting Started

### Prerequisites

* Flutter SDK (latest stable version)
* Dart SDK
* Android Studio, VS Code, or another Flutter-compatible IDE

### Installation

Clone the repository:

```bash
git clone https://github.com/your-username/singularity-black-hole-game.git
```

Navigate to the project:

```bash
cd singularity-black-hole-game
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## 🎮 Controls

| Action  | Control                                        |
| ------- | ---------------------------------------------- |
| Aim     | Drag from the spawn point                      |
| Launch  | Release your finger or mouse                   |
| Restart | Press the **Restart** button after evaporation |

---

## 🧠 Game Mechanics

### Black Hole

* Starts with an initial mass.
* Moves according to launch velocity.
* Grows by absorbing nearby cosmic objects.

### Hawking Radiation

* Continuously decreases the black hole's mass.
* If the mass falls below the minimum threshold, the singularity evaporates.

### Cosmic Targets

Each target has:

* Random size
* Random color
* Orbital movement
* Mass value

Destroying targets increases your total mass score.

### Combo System

Consecutive absorptions increase your combo multiplier, granting bonus mass for each successful absorption.

---

## ✨ Visual Effects

* Particle explosions
* Event horizon ripples
* Animated target movement
* Dynamic singularity scaling
* Deep-space themed rendering

---

## 📈 Future Improvements

* 🌌 Animated starfield background
* 🪐 Planets with gravity
* 🌠 Asteroid belts
* 🔊 Sound effects and background music
* 🏆 High score leaderboard
* 💾 Save game progress
* 🎮 Multiple difficulty levels
* 🌍 Endless survival mode
* 📱 Haptic feedback
* 🌈 Gravitational lensing effects

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Push the branch.
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## 👨‍💻 Author

Developed with Flutter and Dart as a custom physics-based arcade game exploring the fascinating concepts of black holes, gravity, and Hawking radiation.

**MOHAMMED ABDUL JUNAID**
