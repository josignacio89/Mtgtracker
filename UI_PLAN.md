# MTG Tracker — UI Improvement Plan

> Target: modern, tactile, immersive design that feels at home on both
> phone and tablet. Grounded in Material 3 principles, a consistent 8 px
> spacing grid, and deliberate motion.

---

## 1. Design System Foundation

### 1.1 Color Tokens

Replace the single seed color with an explicit token set. Store in
`lib/theme/app_colors.dart`.

```dart
// Background layers (darkest → lightest)
static const bg0 = Color(0xFF0D0D14);   // page background
static const bg1 = Color(0xFF15151F);   // card surface
static const bg2 = Color(0xFF1E1E2C);   // elevated surface / sheet

// Per-player accent palette (distinct, accessible, high-contrast on dark)
static const playerColors = [
  Color(0xFF4D9FEC),  // P1 – sky blue
  Color(0xFFE25C5C),  // P2 – rose red
  Color(0xFF57C27C),  // P3 – emerald
  Color(0xFFF0A348),  // P4 – amber
];

// Life-total state colors
static const lifeHigh   = Color(0xFF57C27C);  // > 15
static const lifeMid    = Color(0xFFF0A348);  // 6–15
static const lifeLow    = Color(0xFFE25C5C);  // ≤ 5
static const lifeZero   = Color(0xFF6B2020);  // eliminated bg tint

// Commander damage warning
static const cmdWarning = Color(0xFFFFCC00);  // 14–20 damage
static const cmdLethal  = Color(0xFFE25C5C);  // ≥ 21
```

### 1.2 Typography Scale

Use `google_fonts` with **Cinzel** (a free serif with a fantasy-card
feel, close to MTG's look) for headlines and **Noto Sans** for body copy.
Beleren, the real MTG title font, is owned by Wizards of the Coast and
should not be bundled.

```dart
// lib/theme/app_text.dart
static const headline = TextStyle(
  fontFamily: 'Cinzel',
  fontSize: 22, letterSpacing: 0.5, color: Colors.white);
static const lifeDisplay = TextStyle(
  fontFamily: 'Cinzel', fontSize: 64,
  height: 1.0, color: Colors.white);
static const label = TextStyle(
  fontSize: 11, letterSpacing: 1.4,
  fontWeight: FontWeight.w600, color: Colors.white54);
static const body = TextStyle(fontSize: 14, color: Colors.white70);
```

### 1.3 Spacing & Radius Grid

| Token | Value | Use |
|---|---|---|
| `space1` | 4 px | icon gap, dense padding |
| `space2` | 8 px | inner card padding |
| `space3` | 16 px | section padding |
| `space4` | 24 px | screen edge padding |
| `radiusSm` | 8 px | button corners |
| `radiusMd` | 14 px | cards |
| `radiusLg` | 24 px | bottom sheets |

---

## 2. Screen-by-Screen Improvements

### 2.1 Setup Screen

**Current:** flat fields inside plain cards, no visual identity per player.

**Target:** each player row is a self-contained "player slot" card with
a bold accent stripe on the left edge matching that player's color.

Changes:
- Replace `OutlineInputBorder` text fields with `FilledTextField`
  (Material 3) — fills match `bg2`, no border clutter.
- Player avatar circle is larger (28 px radius), uses the player accent
  color as background with an icon (sword/shield) instead of a number.
- Deck autocomplete shows a small trophy icon beside names that have won
  at least once (read from `appStatsProvider`).
- Format toggle becomes two large illustrated cards instead of a
  segmented button — each shows an example life total and a subtle card
  art texture overlay.
- "Start Game" button is full-width, 56 px tall, rounded `radiusMd`,
  with a right-arrow icon and a subtle shimmer animation on idle.
- Add a smooth `AnimatedSwitcher` when `playerCount` changes so rows
  slide in/out rather than jump.

---

### 2.2 Game Screen — Player Tile

**Current:** uniform grey card, life total in colored text, four equal
buttons in a row.

**Target:** each tile is distinct to its player. The life total is the
dominant element. Buttons are large tap targets with tactile ripple.

Changes:

**Tile header:**
- Thin 3 px horizontal accent bar at the top of each card using the
  player's accent color.
- Player name in `headline` style; deck name in small italic below.

**Life total:**
- Display using `lifeDisplay` style (64 sp, bold).
- Surrounded by a soft glow ring whose color matches the life-state
  token (`lifeHigh` / `lifeMid` / `lifeLow`) — implemented as a
  `Container` with `BoxShadow`.
- When life changes, show a floating `+5` / `−1` delta label that
  fades and slides upward over ~400 ms using `AnimatedOpacity` +
  `AnimatedPositioned`. This provides instant feedback even on fast taps.

**Adjustment buttons:**
- Two rows: `[+5]` and `[+1]` on top, `[−1]` and `[−5]` below.
- Each button: `InkWell` with `splashColor` = player accent at 40 %
  opacity. Size 56 × 52 px minimum.
- `+` buttons: `bg2` fill with green icon; `−` buttons: `bg2` fill with
  red icon. Avoid full-color backgrounds — they compete with the life total.

**Commander damage button:**
- Replaced by a small badge row below the life total: one small colored
  dot per opponent, showing that opponent's cumulative damage dealt to
  this player. Tapping any dot opens the damage sheet filtered to that
  opponent.
- If any source is ≥ 14 (warning range), the dot pulses yellow.
- If any source is ≥ 21, the dot is red and an ⚠ icon replaces it.

**Eliminated state:**
- Instead of a flat black overlay, use a darkened version of the player
  color with a large ✕ icon and the elimination reason as a tag chip
  (`Commander Damage` or `Life = 0`). A translucent skull SVG asset
  sits behind the text for visual flavor.

**Grid layout:**
- 2 players: vertical split, each tile full width, equal height.
- 3 players: two tiles on top (equal halves), one full-width tile below.
- 4 players: 2×2 grid.
- Use `LayoutBuilder` to adapt button sizes to tile height.

---

### 2.3 Commander Damage Sheet

**Current:** plain list of rows with +/− icon buttons.

**Target:** compact, color-coded matrix that reads at a glance.

Changes:
- Sheet drag handle at top (standard Material 3 pill).
- Title includes the target player's avatar circle and accent color.
- Each opponent row has:
  - Left: opponent avatar dot (their player color).
  - Center: damage value in large bold text.
  - Right: compact `[−] [+]` pair with `FilledTonalButton` style.
  - Background tint ramps from neutral → yellow → red as damage
    approaches 21 (interpolate `bg2` → `cmdWarning` → `cmdLethal`
    at opacity 0.15).
- A horizontal progress bar below the damage value shows `damage / 21`
  with the same color ramp.
- A "Quick +1 all" shortcut button if the format is Commander — one tap
  increments combat damage from all opponents by 1 (common after a
  multi-block scenario).

---

### 2.4 End Game Screen

**Current:** plain radio list, life shown as a chip.

**Target:** celebratory summary with clear winner highlight.

Changes:
- Winner auto-selected when navigating here (pre-populated from
  `gameProvider.winnerId`) shows their card with a golden border and a
  trophy icon.
- Non-winners show their final life in a muted state.
- Add "Cause of defeat" tag under each losing player (eliminated by
  commander damage or life loss).
- "Confirm & Save" button shows a brief confetti animation on press
  (package: `confetti ^0.7.0`) before navigating away.
- After saving, show a dismissible "Game Saved" snackbar with an undo
  action (calls `historyProvider.removeLastRecord()`).

---

### 2.5 Stats Screen

**Current:** two list tabs with a linear progress bar per row.

**Target:** richer data story with visual hierarchy.

Changes:

**Tab: Players**
- Top card: "Most wins overall" — large name, win count, and a trophy.
- Below: ranked list. Rank 1–3 show medal colors (gold/silver/bronze).
  Rank 4+ show a subtle number badge.
- Each row expands on tap to show a mini bar chart: wins per deck used.

**Tab: Decks**
- Same ranked list structure.
- Each row shows win rate as a percentage gauge (arc progress indicator)
  rather than a linear bar — more visually interesting and compact.

**Tab: History** *(new tab)*
- Chronological list of past games, most recent first.
- Each entry: date, format badge, player avatars as a row of dots, and
  winner name with a crown icon.
- Swipe-to-delete individual records with confirmation.

**Empty state:**
- Replace plain text with an illustrated empty state: a centered MTG
  mana symbol SVG, a headline "No games yet", and a "Start a game"
  CTA button that pops back to Setup.

---

## 3. Motion & Feedback

| Trigger | Animation | Duration |
|---|---|---|
| Life total changes | Delta label floats up and fades | 400 ms |
| Player eliminated | Overlay fades in with scale 0.9 → 1.0 | 300 ms |
| Commander damage ≥ 21 | Tile border pulses red (repeat 2×) | 600 ms total |
| Game screen entry | Player tiles stagger-fade in (100 ms offset each) | — |
| End game confirm | Confetti burst | 1.5 s |
| Route transitions | `FadeTransition` replace default slide | 200 ms |

Use `HapticFeedback.lightImpact()` on every life button tap;
`HapticFeedback.heavyImpact()` on elimination and game save.

---

## 4. Accessibility & Polish

- Minimum tap target 48 × 48 px on all interactive elements.
- Life total text passes WCAG AA contrast (4.5:1) against tile
  background at all three life-state colors — verify in widget tests
  with `expectLater(tester, meetsGuideline(textContrastGuideline))`.
- All icon-only buttons carry `tooltip` and `semanticsLabel`.
- Support system font-scale: use `MediaQuery.textScaler` guards so
  the 64 sp life display shrinks gracefully at 200 % scale.
- `Semantics` wrapper on each `PlayerTile` announces
  `"${player.name}, ${player.lifeTotal} life"` to screen readers.

---

## 5. New Packages Required

| Package | Version | Purpose |
|---|---|---|
| `confetti` | `^0.7.0` | End-game celebration |
| `google_fonts` | `^6.2.1` | Cinzel headlines, Noto Sans body |
| `flutter_animate` | `^4.5.0` | Delta-label float, stagger-fade |
| `percent_indicator` | `^4.2.3` | Arc win-rate gauge in Deck tab |

Add to `pubspec.yaml` and run `flutter pub get`.

---

## 6. File Change Map

| File | Change scope |
|---|---|
| `lib/theme/app_colors.dart` | **New** — full color token set |
| `lib/theme/app_text.dart` | **New** — typography scale |
| `lib/main.dart` | Update `ThemeData` to use new tokens |
| `lib/widgets/player_tile.dart` | Full redesign (accent bar, glow, delta label, cmd badge) |
| `lib/widgets/life_adjustment_buttons.dart` | Resize, new visual style |
| `lib/widgets/commander_damage_row.dart` | Color-ramp tints, progress bar |
| `lib/widgets/win_record_row.dart` | Expandable row, medal colors |
| `lib/widgets/delta_label.dart` | **New** — floating delta animation |
| `lib/widgets/player_avatar.dart` | **New** — reusable accent dot / circle |
| `lib/screens/setup_screen.dart` | Illustrated format cards, FilledTextField, animated rows |
| `lib/screens/game_screen.dart` | Stagger-fade entry, updated grid (3-player layout) |
| `lib/screens/end_game_screen.dart` | Trophy highlight, confetti, undo snackbar |
| `lib/screens/stats_screen.dart` | 3 tabs, arc gauge, game history tab, empty state |
| `lib/providers/history_provider.dart` | Add `removeLastRecord()` for undo |

---

## 7. Implementation Order

1. **Theme layer** — `app_colors.dart`, `app_text.dart`, update `main.dart`. Zero risk, sets the foundation.
2. **`PlayerTile` redesign** — highest visual impact; self-contained change.
3. **`LifeAdjustmentButtons` + `DeltaLabel`** — tactile feedback next.
4. **`CommanderDamageRow` redesign** — color-ramp and progress bar.
5. **Setup screen** — illustrated format cards, autocomplete improvements.
6. **End game screen** — confetti, trophy highlight, undo.
7. **Stats screen** — 3rd tab, arc gauge, empty state.
8. **Accessibility pass** — contrast checks, semantics, tap targets.
