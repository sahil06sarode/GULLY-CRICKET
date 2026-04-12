import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/hive_keys.dart';
import '../../../core/constants/match_status.dart';
import '../../notifications/notification_service.dart';
import '../../overlay/overlay_service.dart';
import '../../players/services/saved_players_service.dart';
import '../../storage/services/match_repository.dart';
import '../domain/engines/match_engine.dart';
import '../domain/engines/rule_engine.dart';
import '../domain/models/ball_model.dart';
import '../domain/models/match_model.dart';
import '../domain/models/player_model.dart';

final activeMatchProvider = StateNotifierProvider<ActiveMatchNotifier, MatchModel?>((ref) {
  return ActiveMatchNotifier(ref);
});

class ActiveMatchNotifier extends StateNotifier<MatchModel?> {
  ActiveMatchNotifier(this._ref) : super(null);

  final Ref _ref;
  final MatchEngine _engine = const MatchEngine();
  final RuleEngine _ruleEngine = const RuleEngine();

  Future<void> setMatch(MatchModel match) async {
    state = match;
    await _persist(match);
  }

  Future<MatchModel?> recordBall(Ball ball) async {
    final match = state;
    if (match == null) return null;
    final updated = _engine.recordBall(match, ball);
    state = updated;
    await _persist(updated);
    await _updateLiveNotification(ball, updated);
    return updated;
  }

  Future<MatchModel?> undoLastBall() async {
    final match = state;
    if (match == null) return null;
    final updated = _engine.undoLastBall(match);
    state = updated;
    await _persist(updated);
    return updated;
  }

  Future<MatchModel?> setBatsman(String playerId, {required bool isStriker}) async {
    final match = state;
    if (match == null) return null;
    final updated = _engine.setBatsman(match, playerId, isStriker);
    state = updated;
    await _persist(updated);
    return updated;
  }

  Future<MatchModel?> setBowler(String playerId) async {
    final match = state;
    if (match == null) return null;
    final updated = _engine.setBowler(match, playerId);
    state = updated;
    await _persist(updated);
    return updated;
  }

  Future<MatchModel?> swapStrike() async {
    final match = state;
    final innings = match?.currentInnings;
    if (match == null || innings == null) return null;
    final striker = innings.currentBatsmanId;
    final nonStriker = innings.currentNonStrikerId;
    if (striker == null || nonStriker == null) return null;

    var updated = _engine.setBatsman(match, nonStriker, true);
    updated = _engine.setBatsman(updated, striker, false);
    state = updated;
    await _persist(updated);
    return updated;
  }

  Future<MatchModel?> retireBatsman(String playerId, {bool isHurt = false}) async {
    final match = state;
    if (match == null) return null;
    final updated = _engine.retireBatsman(match, playerId, isHurt);
    state = updated;
    await _persist(updated);
    return updated;
  }

  Future<MatchModel?> startSecondInnings() async {
    final match = state;
    if (match == null) return null;
    final updated = _engine.startSecondInnings(match).copyWith(status: MatchStatus.liveSecondInnings);
    state = updated;
    await _persist(updated);
    return updated;
  }

  Future<MatchModel?> completeMatch() async {
    final match = state;
    if (match == null) return null;
    final updated = _engine.completeMatch(match);
    state = updated;
    await _persist(updated);
    for (final player in <Player>[...updated.team1Players, ...updated.team2Players]) {
      await _ref.read(savedPlayersServiceProvider).updateCareerStats(
        player.name,
        player.runsScored,
        player.wicketsTaken,
      );
    }
    final notif = _ref.read(notificationServiceProvider);
    await notif.cancelLiveScore();
    final winner = updated.winnerTeamName;
    final description = updated.winDescription;
    if (winner != null && description != null) {
      await notif.showMatchResult(winner, description);
    }
    await OverlayService.closeOverlay();
    _ref.read(overlayActiveProvider.notifier).state = false;
    return updated;
  }

  Future<MatchModel?> triggerInningsEndIfNeeded() async {
    final match = state;
    final innings = match?.currentInnings;
    if (match == null || innings == null) return null;
    final battingPlayers = innings.battingTeamId == 'team1' ? match.team1Players : match.team2Players;
    final endReason = _ruleEngine.checkInningsEnd(
      innings: innings,
      rules: match.rules,
      battingPlayers: battingPlayers,
      target: innings.inningsNumber == 2 ? match.target : null,
    );
    if (endReason == null) return match;
    final updatedInnings = innings.copyWith(isCompleted: true);
    final updated = innings.inningsNumber == 1
        ? match.copyWith(firstInnings: updatedInnings)
        : match.copyWith(secondInnings: updatedInnings);
    state = updated;
    await _persist(updated);
    return updated;
  }

  void clearMatch() {
    state = null;
  }

  Future<void> _persist(MatchModel match) async {
    await _ref.read(matchListProvider.notifier).saveMatch(match);
  }

  Future<void> _updateLiveNotification(Ball ball, MatchModel match) async {
    if (!_notificationsEnabled()) return;
    final innings = match.currentInnings;
    if (innings == null) return;
    final notif = _ref.read(notificationServiceProvider);
    final batsmanName = _playerName(match, ball.batsmanId);
    final dismissedName =
        ball.dismissedPlayerId == null ? batsmanName : _playerName(match, ball.dismissedPlayerId);

    var event = '';
    final isBoundaryScoringBall = !ball.isWide && !ball.isNoBall && !ball.isBye && !ball.isLegBye;
    if (ball.runsScored == 4 && isBoundaryScoringBall) {
      event = '🏏 FOUR! $batsmanName hits a boundary';
    } else if (ball.runsScored == 6 && isBoundaryScoringBall) {
      event = '💥 SIX! $batsmanName clears the boundary';
    }
    if (ball.isWicket) {
      event = '🎯 WICKET! $dismissedName is OUT';
    }

    final legalBalls = innings.legalBallsCount();
    final ballsPerOver = match.rules.ballsPerOver;
    final totalBalls = match.rules.totalOvers * ballsPerOver;
    final ballsRemaining = (totalBalls - legalBalls).clamp(0, totalBalls);
    final battingTeam = innings.battingTeamId == 'team1' ? match.team1Name : match.team2Name;
    final crr = legalBalls == 0 ? 0.0 : (innings.totalRuns / legalBalls) * ballsPerOver;
    final target = innings.inningsNumber == 2 ? match.target : null;
    final runsNeeded = target == null ? 0 : (target - innings.totalRuns).clamp(0, target);
    final rrr = target == null || ballsRemaining == 0 ? null : ((runsNeeded / ballsRemaining) * ballsPerOver);
    final firstInnings = match.firstInnings;

    await notif.showLiveScore(
      team1Name: battingTeam,
      team1Score: '${innings.totalRuns}/${innings.wickets}',
      team1Overs: _formatOvers(legalBalls, ballsPerOver),
      team2Score:
          innings.inningsNumber == 1 ? null : firstInnings == null ? null : '${firstInnings.totalRuns}/${firstInnings.wickets}',
      team2Overs: innings.inningsNumber == 1 ? null : 'Target ${match.target ?? '-'}',
      currentEvent: event,
      battingTeam: battingTeam,
      crr: crr.toStringAsFixed(1),
      rrr: rrr?.toStringAsFixed(1),
    );

    if (event.isNotEmpty) {
      await notif.showMatchEvent('Gully Cricket', event);
    }
    await _updateOverlay(match, event);
  }

  bool _notificationsEnabled() {
    final settings = Hive.box<dynamic>(HiveKeys.settingsBox);
    return (settings.get(HiveKeys.notifEnabled, defaultValue: true) as bool?) ?? true;
  }

  String _formatOvers(int legalBalls, int ballsPerOver) {
    return '${legalBalls ~/ ballsPerOver}.${legalBalls % ballsPerOver} ov';
  }

  String _playerName(MatchModel match, String? playerId) {
    if (playerId == null) return 'Batter';
    for (final player in <Player>[...match.team1Players, ...match.team2Players]) {
      if (player.id == playerId) return player.name;
    }
    return 'Batter';
  }

  Future<void> _updateOverlay(MatchModel match, String event) async {
    if (!_ref.read(overlayActiveProvider)) return;
    final innings = match.currentInnings;
    if (innings == null) return;

    final legalBalls = innings.legalBallsCount();
    final ballsPerOver = match.rules.ballsPerOver;
    final totalBalls = match.rules.totalOvers * ballsPerOver;
    final ballsRemaining = (totalBalls - legalBalls).clamp(0, totalBalls);
    final battingTeam = innings.battingTeamId == 'team1' ? match.team1Name : match.team2Name;
    final crr = legalBalls == 0 ? 0.0 : (innings.totalRuns / legalBalls) * ballsPerOver;
    final target = innings.inningsNumber == 2 ? match.target : null;
    final runsNeeded = target == null ? 0 : (target - innings.totalRuns).clamp(0, target);
    final rrr = target == null || ballsRemaining == 0 ? null : ((runsNeeded / ballsRemaining) * ballsPerOver);
    final batters = innings.battingTeamId == 'team1' ? match.team1Players : match.team2Players;
    final striker = _findPlayerInList(batters, innings.currentBatsmanId);
    final nonStriker = _findPlayerInList(batters, innings.currentNonStrikerId);

    final batsmenInfo =
        '${striker?.name ?? 'Striker'} ${striker?.runsScored ?? 0}* · ${nonStriker?.name ?? 'Non-striker'} ${nonStriker?.runsScored ?? 0}';

    await OverlayService.updateOverlay(
      OverlayScoreData(
        battingTeam: battingTeam,
        score: '${innings.totalRuns}/${innings.wickets}',
        overs: '${legalBalls ~/ ballsPerOver}.${legalBalls % ballsPerOver}',
        crr: crr.toStringAsFixed(1),
        rrr: rrr?.toStringAsFixed(1),
        batsmenInfo: batsmenInfo,
        currentEvent: event,
      ),
    );
  }

  Player? _findPlayerInList(List<Player> players, String? playerId) {
    if (playerId == null) return null;
    for (final player in players) {
      if (player.id == playerId) return player;
    }
    return null;
  }
}
