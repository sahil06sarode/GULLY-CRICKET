import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/hive_keys.dart';
import '../../audio/sound_service.dart';
import '../../overlay/overlay_service.dart';
import '../../scoring/presentation/active_match_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _notifEnabled;
  late bool _overlayEnabled;

  @override
  void initState() {
    super.initState();
    final settings = Hive.box<dynamic>(HiveKeys.settingsBox);
    _notifEnabled = (settings.get(HiveKeys.notifEnabled, defaultValue: true) as bool?) ?? true;
    _overlayEnabled = (settings.get(HiveKeys.overlayEnabled, defaultValue: false) as bool?) ?? false;
  }

  Future<void> _saveBool(String key, bool value) async {
    await Hive.box<dynamic>(HiveKeys.settingsBox).put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final sound = ref.watch(soundServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: sound.isEnabled,
            onChanged: (value) => sound.setEnabled(value),
          ),
          SwitchListTile(
            title: const Text('Live Notifications'),
            value: _notifEnabled,
            onChanged: (value) async {
              setState(() => _notifEnabled = value);
              await _saveBool(HiveKeys.notifEnabled, value);
            },
          ),
          SwitchListTile(
            title: const Text('Floating Overlay'),
            value: _overlayEnabled,
            onChanged: (value) async {
              setState(() => _overlayEnabled = value);
              await _saveBool(HiveKeys.overlayEnabled, value);
              if (!value) {
                await OverlayService.closeOverlay();
                ref.read(overlayActiveProvider.notifier).state = false;
              }
            },
          ),
        ],
      ),
    );
  }
}
