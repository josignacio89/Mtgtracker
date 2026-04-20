# Changelog

## [Unreleased] — 2026-04-20

### Added
- **Deck name combobox** — deck name field on the setup screen now shows a searchable autocomplete dropdown populated with all previously played deck names (sourced from game history). Typing filters by substring match; new names not in history still work as free text.
- `previousDeckNamesProvider` derived Riverpod provider that extracts unique, alphabetically sorted deck names from `historyProvider`, filtering out blank entries and the "Unknown Deck" sentinel.
- Summary card at the top of each leaderboard in the Stats screen showing total entry count and total games played.

### Changed

#### Setup Screen
- Sections (Format, Number of Players, Players) are now wrapped in individual Cards for clearer visual grouping.
- Body padding changed from uniform `16` to `fromLTRB(16, 20, 16, 24)` for better breathing room.
- Start Game button has rounded corners (`borderRadius: 12`).
- Each player row is now wrapped in a Card with inner padding.
- Player avatar `CircleAvatar` radius increased from `16` to `18`.

#### Game Screen — Player Tile
- Life color thresholds adjusted for Commander's 40-life range: green above 15 (was 10), amber above 5 (was 4).
- Deck name font size increased from `11` to `12`; color lightened slightly from `white60` to `white54` for better readability.
- Commander damage button color changed from `white54` to `blueGrey.shade300` to signal it as a secondary action rather than disabled.
- Eliminated overlay icon size increased from `44` to `48`; eliminated player's name now shown below the elimination reason.

#### Life Adjustment Buttons
- Visual gap (`SizedBox(width: 12)`) added between the +1 and −1 buttons to separate gain from loss groups.
- Button height increased from `44` to `48` for easier tapping.
- Eliminated players: buttons now visually fade to 35% opacity via `Opacity` wrapper.
- ±5 buttons use `fontSize: 12`; ±1 buttons use `fontSize: 14` to visually distinguish increment sizes.

#### End Game Screen
- Selected winner row highlighted with a semi-transparent green background.
- Life total display replaced with a color-coded `Chip` showing `{life} HP` (green if alive, red if zero or below).
- Divider added below the "Select the winner" heading.
- Confirm button has rounded corners (`borderRadius: 12`).

#### Stats Screen
- Separator in app bar title changed from `  ·  ` to ` — ` for cleaner typography.
- Leaderboard tabs now show a summary card at the top (entry count and game count) when data is present.

#### Win Record Row
- Progress bar `minHeight` increased from `6` to `8` for better readability.

### Fixed
- `web/index.html`: `serviceWorkerVersion` now passed as `null` instead of referencing the undefined variable, fixing the blank-screen error when running in Chrome dev mode.
