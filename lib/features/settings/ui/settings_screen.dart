import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final controller = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(
              switch (mode) {
                ThemeMode.light => 'Light',
                ThemeMode.dark => 'Dark',
                ThemeMode.system => 'System',
              },
            ),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode == ThemeMode.system ? ThemeMode.light : mode},
              onSelectionChanged: (set) async {
                // Prototype: only Light/Dark toggle (as requested)
                final selected = set.first;
                await controller.setThemeMode(selected);
              },
            ),
          ),
          const Divider(height: 1),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'Messenger UI',
            applicationVersion: '1.0.0',
            applicationLegalese: 'Prototype (no backend).',
          ),
        ],
      ),
    );
  }
}