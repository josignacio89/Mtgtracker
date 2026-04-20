# MTG Tracker

A cross-platform Magic: The Gathering game tracker built with Flutter. Runs on iOS, Android, and Web from a single codebase.

## Features

- **Life counters** — +1 / +5 / -1 / -5 buttons per player, color-coded (green → amber → red)
- **Commander damage** — per-opponent damage tracking; auto-eliminates at 21
- **Auto-elimination** — players eliminated when life hits 0 or commander damage threshold is reached; last survivor is declared winner automatically
- **Win history** — every game is saved locally; persists across sessions
- **Leaderboards** — player win stats and deck win stats with win-rate progress bars
- **2–4 players** — Standard (20 life) or Commander (40 life) format

---

## Architecture

### Tech Stack

| Concern | Library |
|---|---|
| UI / cross-platform | Flutter (Dart) |
| State management | `flutter_riverpod ^2.5.1` |
| Persistence | `shared_preferences ^2.3.1` |
| Unique IDs | `uuid ^4.4.0` |

### Directory Layout

```
lib/
├── main.dart                   # App entry point, ProviderScope, routes, dark theme
│
├── models/
│   ├── player.dart             # Mutable in-game player state
│   ├── game_record.dart        # Immutable game snapshot saved after each game
│   └── app_stats.dart          # Computed win statistics (derived, not stored)
│
├── providers/
│   ├── setup_provider.dart     # Ephemeral setup-screen state (player count, format, names)
│   ├── game_provider.dart      # Live game state machine (life, damage, elimination)
│   └── history_provider.dart   # Persisted game history + derived stats provider
│
├── screens/
│   ├── setup_screen.dart       # Configure players, format, deck names → Start Game
│   ├── game_screen.dart        # Live game grid of player tiles
│   ├── end_game_screen.dart    # Winner selection → save record
│   └── stats_screen.dart       # Tabbed player/deck leaderboards
│
├── widgets/
│   ├── player_tile.dart            # Per-player card: life total, buttons, commander damage
│   ├── life_adjustment_buttons.dart # +1/+5/-1/-5 tap targets
│   ├── commander_damage_row.dart    # Single opponent row in the damage bottom sheet
│   └── win_record_row.dart         # Leaderboard row with win%, progress bar
│
└── utils/
    ├── constants.dart          # Life totals, commander threshold, format keys
    └── persistence.dart        # SharedPreferences JSON read/write helper
```

### State Management

The app uses three `StateNotifierProvider`s and one derived `Provider`:

```
setupProvider  ──► (on Start Game) ──► gameProvider
                                            │
                                    adjustLife / adjustCommanderDamage
                                            │
                                    _checkElimination ──► auto-declare winner
                                            │
                                   (on Confirm & Save)
                                            │
                                            ▼
                                    historyProvider  ──► persisted to SharedPreferences
                                            │
                                    appStatsProvider (derived, recomputes on change)
```

| Provider | Role |
|---|---|
| `setupProvider` | Form state on the Setup screen; reset after each game |
| `gameProvider` | Source of truth for the live game; drives all player tile rendering |
| `historyProvider` | Loads history on app start; appends a `GameRecord` at end of game |
| `appStatsProvider` | Pure derivation — `AppStats.fromRecords(history)`; no separate storage |

### Data Models

**`Player`** (mutable, lives only in `gameProvider`)
```dart
Player {
  id: String            // UUID
  name: String
  deckName: String
  lifeTotal: int
  isEliminated: bool
  commanderDamage: Map<String, int>  // sourcePlayerId → cumulative damage
}
```

**`GameRecord`** (immutable snapshot, persisted)
```dart
GameRecord {
  id, playedAt, format, startingLife
  players: List<PlayerSnapshot>   // name, deckName, finalLife, eliminatedByCmd
  winnerId, winnerName, winnerDeckName
}
```

**`AppStats`** (computed on demand from `List<GameRecord>`)
- Groups wins and games played by player name and deck name
- Sorted by wins descending

### Persistence

All game history is stored under a single SharedPreferences key (`game_history_v1`) as a JSON array. The `_v1` suffix is a migration hook — a schema change can introduce `_v2` with a reader that falls back to the old key.

### Screen Flow

```
SetupScreen
    └── [Start Game] ──► GameScreen
                            ├── [Commander Dmg] ──► ModalBottomSheet (CommanderDamageRow per opponent)
                            ├── [End Game FAB]  ──► EndGameScreen
                            │                           └── [Confirm & Save] ──► SetupScreen (stack cleared)
                            └── [Reset] ──► SetupScreen

SetupScreen [Stats icon] ──► StatsScreen (Player tab | Deck tab)
```

Commander damage uses `showModalBottomSheet` rather than a route push so the game board stays visible in the background.

---

## Getting Started

```bash
flutter pub get
flutter run -d chrome        # Web
flutter run -d <device-id>   # iOS or Android
```
