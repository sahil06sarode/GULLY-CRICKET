import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/innings_model.dart';
import '../../domain/models/match_model.dart';

class ScoreboardHeader extends StatefulWidget {
  const ScoreboardHeader({
    super.key,
    required this.match,
    required this.innings,
  });

  final MatchModel match;
  final Innings innings;

  @override
  State<ScoreboardHeader> createState() => _ScoreboardHeaderState();
}

class _ScoreboardHeaderState extends State<ScoreboardHeader> {
  @override
  Widget build(BuildContext context) {
    final isTeam1Batting = widget.innings.battingTeamId == 'team1';
    final battingTeamName = isTeam1Batting ? widget.match.team1Name : widget.match.team2Name;
    final legalBalls = widget.innings.legalBallsCount();
    final ballsPerOver = widget.match.rules.ballsPerOver;
    final overText = '${legalBalls ~/ ballsPerOver}.${legalBalls % ballsPerOver}';
    final crr = legalBalls == 0 ? 0 : (widget.innings.totalRuns / legalBalls) * ballsPerOver;

    final target = widget.innings.inningsNumber == 2 ? widget.match.target : null;
    final ballsRemaining = (widget.match.rules.totalOvers * ballsPerOver) - legalBalls;
    final safeBallsRemaining = ballsRemaining < 0 ? 0 : ballsRemaining;
    final runsNeeded = target == null ? 0 : (target - widget.innings.totalRuns).clamp(0, 9999);
    final rrr = safeBallsRemaining == 0 ? 0 : (runsNeeded / safeBallsRemaining) * ballsPerOver;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  battingTeamName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.innings.score,
                key: ValueKey<int>(widget.innings.totalRuns),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
              )
                  .animate()
                  .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 100.ms)
                  .then()
                  .scale(begin: const Offset(1.3, 1.3), end: const Offset(1, 1), duration: 100.ms)
                  .shimmer(color: AppColors.accentGold, duration: 180.ms),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: <Widget>[
              Text('Overs: $overText'),
              Text('CRR: ${crr.toStringAsFixed(1)}'),
            ],
          ),
          if (target != null) ...<Widget>[
            const SizedBox(height: 4),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: <Widget>[
                Text(
                  'Target: $target',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'Need: $runsNeeded off $safeBallsRemaining',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'RRR: ${rrr.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
