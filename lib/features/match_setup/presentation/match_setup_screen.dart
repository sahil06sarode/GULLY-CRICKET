import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../teams/domain/team_model.dart';
import '../../teams/services/teams_service.dart';
import 'match_setup_notifier.dart';

class MatchSetupScreen extends ConsumerStatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  ConsumerState<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  late final TextEditingController _team1Controller;
  late final TextEditingController _team2Controller;
  late int _totalOvers;
  late int _ballsPerOver;
  late int _team1PlayerCount;
  late int _team2PlayerCount;
  late bool _enableToss;
  String? _team1SavedId;
  String? _team2SavedId;
  List<String> _team1PresetPlayers = const <String>[];
  List<String> _team2PresetPlayers = const <String>[];
  bool _editPlayersAfterSaved = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(matchSetupProvider);
    _team1Controller = TextEditingController(text: config.team1Name);
    _team2Controller = TextEditingController(text: config.team2Name);
    _totalOvers = config.totalOvers;
    _ballsPerOver = config.ballsPerOver;
    _team1PlayerCount = config.team1PlayerCount;
    _team2PlayerCount = config.team2PlayerCount;
    _enableToss = config.enableToss;
  }

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    super.dispose();
  }

  void _handleNext() {
    final team1 = _team1Controller.text.trim();
    final team2 = _team2Controller.text.trim();
    if (team1.isEmpty || team2.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Team names cannot be empty')));
      return;
    }

    final team1Players = _team1PresetPlayers.isEmpty
        ? List<String>.filled(_team1PlayerCount, '')
        : _team1PresetPlayers;
    final team2Players = _team2PresetPlayers.isEmpty
        ? List<String>.filled(_team2PlayerCount, '')
        : _team2PresetPlayers;

    final setup = ref.read(matchSetupProvider.notifier);
    setup.updateTeamPlayers(team1Players: team1Players, team2Players: team2Players);
    setup.updateBase(
      team1Name: team1,
      team2Name: team2,
      totalOvers: _totalOvers,
      ballsPerOver: _ballsPerOver,
      team1PlayerCount: _team1PlayerCount,
      team2PlayerCount: _team2PlayerCount,
      enableToss: _enableToss,
    );

    final bothSaved = _team1SavedId != null && _team2SavedId != null;
    if (bothSaved && !_editPlayersAfterSaved) {
      context.push('/rules');
      return;
    }
    context.push('/setup/teams');
  }

  void _selectSavedTeam({required TeamModel team, required bool isTeam1}) {
    final players = team.playerNames.where((name) => name.trim().isNotEmpty).toList();
    final count = players.isEmpty ? 1 : players.length.clamp(1, 11).toInt();
    setState(() {
      if (isTeam1) {
        _team1SavedId = team.id;
        _team1Controller.text = team.name;
        _team1PlayerCount = count;
        _team1PresetPlayers = players;
      } else {
        _team2SavedId = team.id;
        _team2Controller.text = team.name;
        _team2PlayerCount = count;
        _team2PresetPlayers = players;
      }
    });
  }

  void _clearSavedTeam(bool isTeam1) {
    setState(() {
      if (isTeam1) {
        _team1SavedId = null;
        _team1PresetPlayers = const <String>[];
      } else {
        _team2SavedId = null;
        _team2PresetPlayers = const <String>[];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);
    final bothSavedSelected = _team1SavedId != null && _team2SavedId != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('New Match')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text('Match Settings', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Load saved team?', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                _SavedTeamChips(
                  title: 'Team A',
                  teams: teams,
                  selectedTeamId: _team1SavedId,
                  onSelect: (team) => _selectSavedTeam(team: team, isTeam1: true),
                  onClear: () => _clearSavedTeam(true),
                ),
                const SizedBox(height: 6),
                _SavedTeamChips(
                  title: 'Team B',
                  teams: teams,
                  selectedTeamId: _team2SavedId,
                  onSelect: (team) => _selectSavedTeam(team: team, isTeam1: false),
                  onClear: () => _clearSavedTeam(false),
                ),
                const SizedBox(height: 8),
                if (bothSavedSelected)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: _editPlayersAfterSaved,
                    title: const Text('Edit Players?'),
                    onChanged: (value) => setState(() => _editPlayersAfterSaved = value ?? false),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: _team1Controller,
                  decoration: const InputDecoration(labelText: 'Team 1 Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _team2Controller,
                  decoration: const InputDecoration(labelText: 'Team 2 Name'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    const Expanded(child: Text('Total Overs')),
                    Text(_totalOvers.toString()),
                  ],
                ),
                Slider(
                  min: 1,
                  max: 20,
                  divisions: 19,
                  value: _totalOvers.toDouble(),
                  onChanged: (value) => setState(() => _totalOvers = value.round()),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    const Expanded(child: Text('Balls per Over')),
                    Wrap(
                      spacing: 8,
                      children: <int>[4, 5, 6]
                          .map(
                            (balls) => ChoiceChip(
                              label: Text('$balls'),
                              selected: _ballsPerOver == balls,
                              onSelected: (_) => setState(() => _ballsPerOver = balls),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          const Text('Team A Players'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _team1PlayerCount > 1
                                    ? () => setState(() => _team1PlayerCount--)
                                    : null,
                              ),
                              Text(
                                '$_team1PlayerCount',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: _team1PlayerCount < 11
                                    ? () => setState(() => _team1PlayerCount++)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 60, color: AppColors.dotGray),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          const Text('Team B Players'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _team2PlayerCount > 1
                                    ? () => setState(() => _team2PlayerCount--)
                                    : null,
                              ),
                              Text(
                                '$_team2PlayerCount',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: _team2PlayerCount < 11
                                    ? () => setState(() => _team2PlayerCount++)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_team1PlayerCount != _team2PlayerCount)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '⚡ Uneven match: $_team1PlayerCount vs $_team2PlayerCount',
                      style: const TextStyle(color: AppColors.accentGold, fontSize: 12),
                    ),
                  ),
                SwitchListTile(
                  title: const Text('Enable Toss'),
                  value: _enableToss,
                  onChanged: (value) => setState(() => _enableToss = value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    child: Text(
                      bothSavedSelected && !_editPlayersAfterSaved
                          ? 'Next: Rules →'
                          : 'Next: Add Players →',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedTeamChips extends StatelessWidget {
  const _SavedTeamChips({
    required this.title,
    required this.teams,
    required this.selectedTeamId,
    required this.onSelect,
    required this.onClear,
  });

  final String title;
  final List<TeamModel> teams;
  final String? selectedTeamId;
  final ValueChanged<TeamModel> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              ...teams.map(
                (team) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: selectedTeamId == team.id,
                    label: Text(team.name),
                    onSelected: (_) => onSelect(team),
                  ),
                ),
              ),
              ActionChip(
                label: const Text('+ New Team'),
                onPressed: () => context.push('/teams/create'),
              ),
              if (selectedTeamId != null) ...<Widget>[
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Clear'),
                  onPressed: onClear,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
