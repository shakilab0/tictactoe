# Tic-Tac-Toe 🎮

Retro Tic-Tac-Toe built with **Clean Architecture + GetX**, **Hive** (offline
stats) and **PostHog** (product analytics). Mirrors the same architecture
style as your production app.

---

## ▶️ How to run

```bash
# 1. Create a fresh Flutter project shell (gives you android/ ios/ etc.)
flutter create tic_tac_toe
cd tic_tac_toe

# 2. Replace the generated lib/ and pubspec.yaml with the ones from here.

# 3. Install packages
flutter pub get

# 4. Add your PostHog key in lib/main.dart:
#    PostHogConfig('<YOUR_POSTHOG_PROJECT_API_KEY>')
#    (PostHog → Settings → Project API Key. Use the free tier.)

# 5. Run
flutter run
```

> Tip: while learning, leave `config.debug = true` so PostHog events print to
> the console even before you wire up the dashboard.

---

## 🧱 Architecture (feature-first Clean Architecture)

```
lib/
├── main.dart                 ← init Hive + PostHog, run app
├── my_app.dart               ← GetMaterialApp (theme + routes)
├── config/                   ← AppColor, text styles
├── core/
│   ├── routes/               ← routes list + AppRoutes constants
│   ├── failure/              ← Failure object
│   └── analytics/            ← PostHogService (reusable wrapper)
└── feature/ticTacToe/
    ├── data/
    │   ├── dataSource/       ← GameLocalDataSource (Hive)
    │   ├── repoImplementation/
    │   └── model/            ← GameStatsModel (+ hand-written Hive adapter)
    ├── domain/
    │   ├── entity/           ← GameMode, Difficulty enums
    │   └── repository/       ← abstract TicTacToeRepository
    └── presentation/
        ├── tic_tac_toe_page.dart        ← GetView<Controller> (UI)
        ├── tic_tac_toe_controller.dart  ← game logic + minimax + analytics
        └── tic_tac_toe_binding.dart     ← DI chain (Get.lazyPut)
```

**Dependency flow:** Page → Controller → Repository (abstract) →
RepositoryImplementation → LocalDataSource → Hive. Errors travel back as
`Either<Failure, T>` (fpdart), exactly like your API layer.

> No UseCase layer here — for a small offline app the Controller calls the
> Repository directly. The abstract Repository still keeps the Controller
> independent of Hive (dependency inversion). Add UseCases back when the
> business logic grows.

---

## 🤖 The AI (minimax)

- **Easy** – random empty cell.
- **Medium** – 50% optimal, 50% random.
- **Hard** – full minimax → unbeatable. It simulates every possible future
  board, scores win/lose/tie, and picks the best move.

---

## 📊 Tracked PostHog events

| Event | When | Key properties |
|---|---|---|
| `game_started` | new game begins | mode, difficulty |
| `move_made` | every move | player, position, move_number |
| `game_finished` | game ends | result, winner, total_moves, duration_seconds |
| `game_abandoned` | left mid-game (app backgrounded) | moves_played |
| `difficulty_changed` | difficulty switched | to |
| `mode_changed` | 1P/2P switched | to |
| `rematch_clicked` | NEW GAME tapped | — |
| `session_ended` | app backgrounded | duration_seconds |

These answer all your questions: when the user entered/left, time spent,
how many games, wins/losses/ties, and how often they quit half-way.

### Offline behaviour
PostHog queues events on-device while offline and flushes them when the
device reconnects — so an offline game still reports correct stats (with the
correct timestamps) once online. Lifetime totals are also saved locally in
Hive, so the in-app **Stats** screen works with zero network.

---

## 🔑 Notes
- Package versions in `pubspec.yaml` are sensible defaults — run
  `flutter pub get` and bump if pub.dev suggests newer compatible versions.
- The Hive adapter is hand-written (no build_runner needed). If you add
  fields, bump the field count in `write()` and read them in `read()`.
