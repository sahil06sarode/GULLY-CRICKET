# 🏏 GULLY CRICKET APP — AI AGENT CODING PLAN
> **For:** Cursor / Claude Code / Any AI Coding Agent  
> **Stack:** Flutter + Riverpod + Hive + WebSocket  
> **Author:** Sooubh  
> **Version:** 1.0.0

---

## 🧠 AGENT PRIME DIRECTIVE

You are building a **fully offline, real-time gully cricket scoring app** called **Gully Cricket**.  
The app works **without internet** using local WiFi hotspot for multi-device sync.  
The host device runs a WebSocket server. Other devices connect as clients.

**Package ID:** `com.sooubh.gullycricket`  
**State Management:** Riverpod  
**Local DB:** Hive  
**Networking:** `shelf_web_socket` (server) + `web_socket_channel` (client)  
**Navigation:** GoRouter  

---

## 📁 COMPLETE PROJECT STRUCTURE

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── hive_keys.dart
│   └── utils/
│       ├── score_utils.dart
│       └── format_utils.dart
│
├── features/
│   ├── match_setup/
│   │   ├── domain/
│   │   │   └── match_config.dart
│   │   └── presentation/
│   │       ├── match_setup_screen.dart
│   │       ├── team_setup_screen.dart
│   │       └── rules_config_screen.dart
│   │
│   ├── scoring/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── match.dart
│   │   │   │   ├── innings.dart
│   │   │   │   ├── over.dart
│   │   │   │   ├── ball.dart
│   │   │   │   ├── player.dart
│   │   │   │   ├── partnership.dart
│   │   │   │   └── gully_rules.dart
│   │   │   └── engines/
│   │   │       ├── match_engine.dart
│   │   │       └── rule_engine.dart
│   │   └── presentation/
│   │       ├── live_score_screen.dart
│   │       ├── select_batsman_screen.dart
│   │       ├── select_bowler_screen.dart
│   │       └── widgets/
│   │           ├── score_pad.dart
│   │           ├── scoreboard_header.dart
│   │           ├── ball_timeline.dart
│   │           ├── partnership_widget.dart
│   │           └── quick_action_bar.dart
│   │
│   ├── multiplayer/
│   │   ├── domain/
│   │   │   └── sync_event.dart
│   │   ├── services/
│   │   │   ├── host_service.dart
│   │   │   └── client_service.dart
│   │   └── presentation/
│   │       ├── host_lobby_screen.dart
│   │       ├── join_screen.dart
│   │       └── spectator_screen.dart
│   │
│   ├── storage/
│   │   └── services/
│   │       ├── hive_service.dart
│   │       └── match_repository.dart
│   │
│   └── result/
│       └── presentation/
│           ├── result_screen.dart
│           └── widgets/
│               ├── win_banner.dart
│               ├── scorecard_table.dart
│               └── player_stats_card.dart
│
└── shared/
    └── widgets/
        ├── cricket_button.dart
        ├── player_chip.dart
        └── confirmation_dialog.dart
```

---

## 📦 PUBSPEC.YAML — FULL DEPENDENCIES

```yaml
name: gully_cricket
description: Offline real-time gully cricket scoring with WiFi multiplayer.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^13.0.0

  # Local DB
  hive_flutter: ^1.1.0

  # WebSocket — Server (Host)
  shelf: ^1.4.0
  shelf_web_socket: ^2.0.0

  # WebSocket — Client
  web_socket_channel: ^2.4.0

  # QR Code (Join via QR)
  qr_flutter: ^4.1.0
  mobile_scanner: ^5.0.0

  # UI
  gap: ^3.0.0
  google_fonts: ^6.1.0
  flutter_animate: ^4.5.0

  # Haptics & Sound
  haptic_feedback: ^0.5.0
  audioplayers: ^6.0.0

  # Utils
  uuid: ^4.3.0
  intl: ^0.19.0
  network_info_plus: ^5.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  hive_generator: ^2.0.0
  flutter_launcher_icons: ^0.13.0

flutter:
  uses-material-design: true
  assets:
    - assets/sounds/
    - assets/images/
  fonts:
    - family: AppFont
      fonts:
        - asset: assets/fonts/Rajdhani-Bold.ttf
          weight: 700
        - asset: assets/fonts/Rajdhani-Regular.ttf
          weight: 400
```

---

## 🏗️ PHASE-BY-PHASE IMPLEMENTATION PLAN

---

### ✅ PHASE 1 — FOUNDATION (Build First)

**Goal:** App boots, theme works, Hive initializes, navigation works.

---

#### TASK 1.1 — `main.dart`

```dart
// Initialize:
// 1. WidgetsFlutterBinding.ensureInitialized()
// 2. await Hive.initFlutter()
// 3. Register all Hive adapters (Match, Player, Innings, Ball, GullyRules)
// 4. Open Hive boxes: 'matches', 'players', 'settings'
// 5. Wrap app in ProviderScope
// 6. Run GullyCricketApp()
```

---

#### TASK 1.2 — `core/theme/app_theme.dart`

```dart
// Cricket-themed dark-first design:
// Primary: #1B5E20 (deep cricket green)
// Secondary: #FFC107 (golden yellow — like a cricket ball)
// Background: #0D1117 (dark pitch feel)
// Surface: #161B22
// Error: #CF6679
// Text: #E6EDF3
//
// Use Material 3 ColorScheme.fromSeed with dark brightness
// Define TextTheme using Google Fonts 'Rajdhani' for scoreboard feel
// Create both light + dark ThemeData
```

---

#### TASK 1.3 — `app/router.dart`

```dart
// Routes:
// '/'                → HomeScreen
// '/setup/match'     → MatchSetupScreen
// '/setup/teams'     → TeamSetupScreen
// '/setup/rules'     → RulesConfigScreen
// '/host'            → HostLobbyScreen
// '/join'            → JoinScreen
// '/live'            → LiveScoreScreen
// '/spectator'       → SpectatorScreen
// '/result'          → ResultScreen
// '/history'         → MatchHistoryScreen
```

---

### ✅ PHASE 2 — DATA MODELS (Define Before Logic)

**CRITICAL: All models must be Hive-compatible with TypeAdapters.**

---

#### TASK 2.1 — `GullyRules` model

```dart
// Fields (all bool/int, toggleable by user):
bool halfCenturyRetire = true;       // batsman retires at 50
bool centuryRetire = false;          // or 100
bool lastManBatsAlone = true;
bool runnerAllowed = false;
bool reEntryAllowed = false;
bool tipOneHandOut = true;           // 1-tip-1-hand = out
bool wallCatchOut = false;
bool oneBounceCatchOut = false;
bool sixIsOut = false;               // hitting six = out in some gully rules
bool noballFreeHit = true;
bool lbwAllowed = false;
bool powerplayEnabled = false;
int maxOversPerBowler = 0;           // 0 = unlimited
int ballsPerOver = 6;
int totalOvers = 5;
int totalPlayers = 6;
bool byesAllowed = true;
bool legByesAllowed = false;
bool overthrowsAllowed = true;
```

---

#### TASK 2.2 — `Ball` model

```dart
// Represents one ball delivered
String id;           // uuid
int runsScored;      // 0,1,2,3,4,6
bool isWicket;
bool isWide;
bool isNoBall;
bool isBye;
bool isLegBye;
bool isFreeHit;
String? wicketType;  // 'caught', 'bowled', 'run_out', 'tip_catch', etc.
String? dismissedPlayerId;
String bowlerId;
String batsmanId;
int overNumber;
int ballInOver;
```

---

#### TASK 2.3 — `Over` model

```dart
String id;
int overNumber;
String bowlerId;
List<Ball> balls;        // max 6 legal balls
int runsInOver;
int wicketsInOver;
bool isMaiden;
// Computed: legalBallCount, extraBallCount
```

---

#### TASK 2.4 — `Player` model

```dart
String id;           // uuid
String name;
String teamId;
// Batting stats (computed from balls)
int runsScored;
int ballsFaced;
bool isOut;
bool isRetired;
bool isRetiredHurt;
String? wicketType;
String? dismissedBy;
// Bowling stats
int oversBowled;
int runsConceded;
int wicketsTaken;
int widesBowled;
int noballsBowled;
bool isCurrentlyBatting;
bool isCurrentlyBowling;
int battingPosition;
```

---

#### TASK 2.5 — `Innings` model

```dart
String id;
String battingTeamId;
String bowlingTeamId;
int totalRuns;
int wickets;
List<Over> overs;
List<Ball> allBalls;        // flat list for timeline
List<Partnership> partnerships;
List<FallOfWicket> fallOfWickets;
String? currentBatsmanId;
String? currentNonStrikerId;
String? currentBowlerId;
bool isCompleted;
int targetRuns;              // set after first innings
```

---

#### TASK 2.6 — `Match` model

```dart
String id;
String team1Name;
String team2Name;
List<Player> team1Players;
List<Player> team2Players;
GullyRules rules;
Innings? firstInnings;
Innings? secondInnings;
String? winnerId;            // teamId
String? winDescription;      // "Team A won by 5 runs"
MatchStatus status;          // setup / live / completed / paused
DateTime createdAt;
DateTime? completedAt;
String? tossWinnerId;
String? tossDecision;        // 'bat' or 'bowl'
```

---

### ✅ PHASE 3 — ENGINES (Core Logic)

---

#### TASK 3.1 — `RuleEngine`

```dart
// This class is PURE LOGIC — no Flutter/UI dependencies
// Takes: Ball + GullyRules + current Match state
// Returns: RuleValidationResult

class RuleEngine {

  // Check if ball is valid (no-ball, wide detection hooks)
  RuleValidationResult validateBall(Ball ball, GullyRules rules);

  // Check if batsman must retire
  bool shouldRetire(Player batsman, GullyRules rules);

  // Check if innings is over
  InningsEndReason? checkInningsEnd(Innings innings, GullyRules rules);

  // Check if match is over
  MatchEndReason? checkMatchEnd(Match match);

  // Auto rotate strike after odd runs
  bool shouldRotateStrike(Ball ball);

  // Check if this ball = free hit
  bool isFreeHit(Ball previousBall, GullyRules rules);

  // Validate wicket type against enabled rules
  // e.g. if tipOneHandOut is false, reject 'tip_catch' wicket
  bool isWicketTypeAllowed(String wicketType, GullyRules rules);
}
```

---

#### TASK 3.2 — `MatchEngine`

```dart
// Central brain. Takes user action → updates match state → returns new state.
// All methods are SYNCHRONOUS. Persistence is handled separately.

class MatchEngine {

  // Apply a ball to current innings
  Match recordBall(Match match, Ball ball);

  // Undo last ball (full state rollback)
  Match undoLastBall(Match match);

  // Retire a batsman (voluntary)
  Match retireBatsman(Match match, String playerId, bool isHurt);

  // Set next batsman after wicket
  Match setBatsman(Match match, String playerId, bool isStriker);

  // Set bowler for next over
  Match setBowler(Match match, String playerId);

  // Start second innings
  Match startSecondInnings(Match match);

  // Complete match and set winner
  Match completeMatch(Match match);

  // Compute live run rate, required run rate
  double currentRunRate(Innings innings);
  double requiredRunRate(Innings innings, int targetRuns, int ballsRemaining);

  // Get partnership stats for current pair
  Partnership currentPartnership(Innings innings);
}
```

---

### ✅ PHASE 4 — STORAGE LAYER

---

#### TASK 4.1 — `HiveService`

```dart
// Singleton. Wraps all Hive box operations.
class HiveService {
  static const String matchBox = 'matches';

  Future<void> saveMatch(Match match);
  Future<Match?> getMatch(String id);
  Future<List<Match>> getAllMatches();
  Future<void> deleteMatch(String id);
  Future<void> updateMatch(Match match);    // overwrite by id
}
```

---

#### TASK 4.2 — `MatchRepository` (Riverpod Provider)

```dart
// Wraps HiveService and exposes as Riverpod AsyncNotifier
// Used by all screens that need match data
// Handles: load, save, update, delete matches
```

---

### ✅ PHASE 5 — MULTIPLAYER SYNC

---

#### TASK 5.1 — `SyncEvent` (JSON Protocol)

```dart
// All WebSocket messages follow this format:
{
  "type": "SCORE_UPDATE" | "MATCH_STATE" | "PING" | "CLIENT_JOINED" | "ERROR",
  "payload": { ... },
  "timestamp": 1714000000000,
  "senderId": "host"
}

// Types:
// MATCH_STATE   → full Match JSON (sent on connect + after every ball)
// SCORE_UPDATE  → minimal update {ball, newScore, wickets}
// PING          → keep-alive
// CLIENT_JOINED → new device joined
// ERROR         → validation failed on host
```

---

#### TASK 5.2 — `HostService`

```dart
// Runs a shelf WebSocket server on port 4040
// ONLY the host can mutate match state

class HostService {
  String get hostIp;             // device's WiFi IP
  String get qrData;             // JSON with IP + port + matchId
  int get connectedClients;

  Future<void> startServer(Match initialMatch);
  void broadcastMatchState(Match match);   // sends full JSON to all clients
  void stopServer();
}
```

---

#### TASK 5.3 — `ClientService`

```dart
// Connects to host's WebSocket
// READ ONLY — client never sends score updates

class ClientService {
  Future<void> connect(String hostIp, int port);
  Stream<Match> get matchUpdates;   // parsed Match objects
  void disconnect();
  bool get isConnected;
  // Auto-reconnect logic with 3 retries + 2s backoff
}
```

---

### ✅ PHASE 6 — SCREENS (Build in this order)

---

#### TASK 6.1 — `HomeScreen`

```
Layout:
- App logo + "Gully Cricket" title
- Big button: "🏏 New Match"
- Button: "📡 Join Match" (as client)
- Button: "📋 Match History"
- Small: version number

State: none (stateless)
```

---

#### TASK 6.2 — `MatchSetupScreen`

```
Form fields:
- Team 1 Name (TextField)
- Team 2 Name (TextField)
- Total Overs (slider: 1–20, default 5)
- Balls per over (chips: 4 / 5 / 6)
- Players per side (slider: 2–11)
- Toss (optional toggle)

"Next →" button → goes to TeamSetupScreen
State: local form state via Riverpod StateNotifier
```

---

#### TASK 6.3 — `RulesConfigScreen`

```
Section: Batting Rules
- Half century retire toggle (default ON)
- Century retire toggle
- Re-entry allowed toggle
- Runner for last batsman toggle

Section: Fielding Rules
- 1-tip-1-hand out toggle
- Wall catch out toggle
- One bounce catch out toggle

Section: Bowling Rules
- No-ball = free hit toggle
- LBW on/off
- Max overs per bowler (0 = off, else stepper)

Section: Boundary Rules
- 6 = OUT toggle

"Start Match →" button
```

---

#### TASK 6.4 — `LiveScoreScreen` ⭐ (Most Complex)

```
Layout (Portrait):
┌─────────────────────────────────┐
│ TEAM A: 87/3  |  OV: 4.2       │  ← ScoreboardHeader
│ Need: 23 off 10 balls           │
├─────────────────────────────────┤
│ 🟢 Raju  34(22)  ●              │  ← Current batsmen
│ 🔵 Sonu  12(8)                  │
│ Bowler: Pintu  2-0-18-1         │
├─────────────────────────────────┤
│ [THIS OVER]: 1 4 W 0 1 .        │  ← BallTimeline
├─────────────────────────────────┤
│  [0]  [1]  [2]  [3]            │  ← ScorePad
│  [4]  [6]  [W]  [WD]           │
│  [NB] [BYE] [LB] [↩ UNDO]      │
├─────────────────────────────────┤
│ [⚙ Rules]  [📊 Card]  [📡 Sync]│  ← QuickActionBar
└─────────────────────────────────┘

On "W" (Wicket) tap:
  → Show bottom sheet: select wicket type
  → Then: select next batsman

On over complete:
  → Show bottom sheet: select next bowler

Score buttons:
  → Each tap = call MatchEngine.recordBall()
  → Then: HiveService.saveMatch()
  → Then: HostService.broadcastMatchState() [if hosting]
  → Then: Check RuleEngine for innings/match end

UNDO button:
  → MatchEngine.undoLastBall()
  → Animate last ball indicator removal
  → Show snackbar: "Last ball undone"
```

---

#### TASK 6.5 — `SpectatorScreen` (Client View)

```
Same layout as LiveScoreScreen BUT:
- All buttons are DISABLED / hidden
- Shows "📡 LIVE" indicator
- Reconnect button if connection drops
- Auto-updates from ClientService stream
```

---

#### TASK 6.6 — `HostLobbyScreen`

```
Shows:
- Match summary (teams, overs, rules)
- QR code (from HostService.qrData)
- IP address text (manual entry option)
- Connected clients count: "2 devices connected"
- "Start Match →" button (enabled always, clients = bonus)
```

---

#### TASK 6.7 — `JoinScreen`

```
Two methods:
1. QR scan (using mobile_scanner)
2. Manual IP entry (TextField + port)

On connect:
- Show loading
- Connect via ClientService
- On success → navigate to SpectatorScreen
- On fail → show error + retry
```

---

#### TASK 6.8 — `ResultScreen`

```
Sections:
- Win banner: "🏆 TEAM A WON by 12 runs!"
- Match summary card:
    Team A: 94/4 in 5 overs
    Team B: 82 all out in 4.3 overs
- Top Scorer: "Raju — 45(28), SR: 160"
- Best Bowler: "Pintu — 2/14 in 2 overs"
- Full scorecard (expandable table)
- Buttons: "New Match" | "Share" | "Home"
```

---

### ✅ PHASE 7 — ADVANCED FEATURES (After MVP)

---

#### TASK 7.1 — Voice Scoring

```dart
// Use speech_to_text package
// Listen for: "four", "six", "out", "wide", "no ball", "undo"
// Map to MatchEngine actions
// Show voice indicator in LiveScoreScreen
```

---

#### TASK 7.2 — AI Commentary

```dart
// On significant events (4, 6, wicket, milestone):
// Send event to Gemini API:
//   "Raju just hit a six in gully cricket. Give a fun 1-line Hindi/English commentary."
// Display as animated toast overlay
// Examples:
//   "🔥 Raju ne chha maar diya! That's gone straight into the society parking!"
//   "💀 Pintu strikes again! That batsman never stood a chance!"
```

---

#### TASK 7.3 — Tournament Mode

```dart
// Data: Tournament model with List<Match>
// Formats: Round Robin | Knockout | League
// Auto-generate fixtures
// Points table with NRR
// Winner bracket visualization
```

---

## 🔄 DATA FLOW — EVERY BALL

```
User taps [4] button
     ↓
ScorePad widget calls scoringProvider.recordRuns(4)
     ↓
scoringProvider → MatchEngine.recordBall(match, ball)
     ↓
RuleEngine.validateBall() → passes
     ↓
RuleEngine.shouldRetire()? → no
     ↓
RuleEngine.checkInningsEnd()? → no
     ↓
New Match state returned (immutable)
     ↓
HiveService.saveMatch(newMatch)   ← persisted
     ↓
HostService.broadcastMatchState() ← sent to clients (if hosting)
     ↓
UI rebuilds via Riverpod watch()
     ↓
BallTimeline animates new ball indicator
     ↓
HapticFeedback.mediumImpact()
```

---

## 🧪 RIVERPOD PROVIDER MAP

```dart
// Core providers:
matchRepositoryProvider      → AsyncNotifierProvider<MatchRepository, List<Match>>
currentMatchProvider         → StateNotifierProvider<MatchNotifier, Match?>
scoringProvider              → NotifierProvider<ScoringNotifier, ScoringState>
ruleEngineProvider           → Provider<RuleEngine>   // pure, no state

// Multiplayer:
hostServiceProvider          → StateNotifierProvider<HostNotifier, HostState>
clientServiceProvider        → StateNotifierProvider<ClientNotifier, ClientState>

// Derived (computed):
currentInningsProvider       → Provider<Innings?>        // watches currentMatchProvider
currentBatsmenProvider       → Provider<List<Player>>    // watches currentInningsProvider
ballTimelineProvider         → Provider<List<Ball>>      // last 6 balls
runRateProvider              → Provider<RunRateData>     // CRR + RRR
```

---

## ⚠️ CRITICAL RULES FOR AGENT

1. **Never mutate Match state directly.** Always return a new Match object (immutable pattern).
2. **Host is single source of truth.** Clients never send score data.
3. **Always run RuleEngine BEFORE saving.** Validate first, persist after.
4. **Undo = full state snapshot.** Keep a `List<Match> stateHistory` in the notifier for undo.
5. **Ball ID = UUID.** Never use index as ball identifier.
6. **Hive adapters must be registered before box open.** Crash otherwise.
7. **WebSocket port = 4040.** Hardcoded. Clients must use this port.
8. **Score buttons = minimum 72x72px.** Players use on ground in sunlight.
9. **Always show loading state** when connecting to host.
10. **Test rule combinations.** "6 = OUT" + "no-ball free hit" must not conflict.

---

## 🎨 UI/UX RULES

```
Color palette:
- Buttons: Primary green (#2E7D32) for runs, Red (#C62828) for wicket
- Background: Deep dark (#0D1117) — easy in sunlight
- Score display: Large bold Rajdhani font, min 48sp
- Ball timeline: Colored circles (green=runs, red=W, yellow=extras, gray=dot)
- Current over balls: Always visible at top of scoring area

Touch targets:
- All score buttons: minimum 72x72dp
- Wicket button: Larger, red, different shape (rounded rect vs circle)
- Undo: Bottom right, small, requires 2 taps (prevent accidental)

Animations:
- flutter_animate for score increment pop
- Slide-in for new ball in timeline
- Bounce for 4/6 celebration
- Screen flash for wicket

Haptics:
- Every ball tap: light
- Wicket: heavy
- 4 runs: medium + 2 taps
- 6 runs: heavy + 3 taps
```

---

## 🚀 BUILD SEQUENCE (Recommended Agent Order)

```
Step 1:  pubspec.yaml + main.dart + Hive init
Step 2:  All data models with Hive adapters
Step 3:  RuleEngine (pure logic, test immediately)
Step 4:  MatchEngine (pure logic, test immediately)
Step 5:  HiveService + MatchRepository
Step 6:  Theme + Router
Step 7:  HomeScreen
Step 8:  MatchSetupScreen + RulesConfigScreen
Step 9:  LiveScoreScreen (scoring only, no multiplayer yet)
Step 10: ResultScreen
Step 11: HostService + ClientService
Step 12: HostLobbyScreen + JoinScreen + SpectatorScreen
Step 13: Match History Screen
Step 14: Voice scoring (stretch)
Step 15: AI commentary via Gemini (stretch)
Step 16: Tournament mode (stretch)
```

---

## 📊 MVP SUCCESS CRITERIA

Before calling Phase 1 done, verify:

- [ ] Can create a match with custom rules
- [ ] Can score a full 5-over innings ball-by-ball
- [ ] Half-century retire rule triggers correctly
- [ ] Wicket flow: tap W → choose type → choose next batter → continues
- [ ] Over complete: auto-prompt for next bowler
- [ ] Second innings loads correctly with target display
- [ ] Match ends, winner declared, result screen shows
- [ ] Match saved to Hive, visible in history
- [ ] App survives kill + reopen (state restored)
- [ ] Undo works for last 3 balls

---

## 🔥 HACKATHON PITCH CHECKLIST

- [ ] Offline multiplayer demo (2 phones on same WiFi hotspot)
- [ ] QR code join working live
- [ ] Gully rules demo: "Watch — 6 = OUT toggle"
- [ ] AI commentary showing on 6 hit
- [ ] Match summary screen with stats
- [ ] Match history with past games

---

*Built with ❤️ for every gully cricket ground in India.*  
*"Make every street match feel like IPL scoring."*
