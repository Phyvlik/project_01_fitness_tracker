import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context, AppProvider provider) async {
    try {
      final path = await provider.exportDataToJson();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data exported to: $path')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to export data.')));
    }
  }

  Future<void> _importData(BuildContext context, AppProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        throw const FormatException('Selected file has no readable content.');
      }

      final content = utf8.decode(bytes);
      final counts = await provider.importDataFromJsonString(content);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${counts['workouts']} workouts and ${counts['quests']} quests.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  Future<void> _runOfflineSync(
    BuildContext context,
    AppProvider provider,
  ) async {
    final synced = await provider.syncPendingOperations();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offline sync complete. Processed $synced operations.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Preferences',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark theme'),
                value: provider.isDarkMode,
                onChanged: (value) => provider.toggleDarkMode(),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Enable workout reminders'),
                value: provider.notificationsEnabled,
                onChanged: (value) => provider.toggleNotifications(),
              ),
              const Divider(),
              ListTile(
                title: const Text('Weekly Goal'),
                subtitle: Text('${provider.weeklyGoal} workouts per week'),
                trailing: DropdownButton<int>(
                  value: provider.weeklyGoal,
                  items: [3, 4, 5, 6, 7].map((goal) {
                    return DropdownMenuItem(value: goal, child: Text('$goal'));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setWeeklyGoal(value);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Weight Unit'),
                subtitle: Text(
                  provider.weightUnit == 'lbs' ? 'Pounds' : 'Kilograms',
                ),
                trailing: DropdownButton<String>(
                  value: provider.weightUnit,
                  items: ['lbs', 'kg'].map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setWeightUnit(value);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Export Data (JSON)'),
                subtitle: const Text(
                  'Save workouts and quests to local storage',
                ),
                trailing: const Icon(Icons.download),
                onTap: () => _exportData(context, provider),
              ),
              const Divider(),
              ListTile(
                title: const Text('Import Data (JSON)'),
                subtitle: const Text(
                  'Restore workouts and quests from JSON file',
                ),
                trailing: const Icon(Icons.upload_file),
                onTap: () => _importData(context, provider),
              ),
              const Divider(),
              ListTile(
                title: const Text('Offline Sync Queue'),
                subtitle: Text(
                  provider.pendingSyncCount == 0
                      ? 'No pending operations'
                      : '${provider.pendingSyncCount} pending operations',
                ),
                trailing: provider.isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                onTap: provider.isSyncing
                    ? null
                    : () => _runOfflineSync(context, provider),
              ),
              const Divider(),
              const SizedBox(height: 32),
              const Text(
                'App Info',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const ListTile(title: Text('Version'), subtitle: Text('1.0.0')),
              const ListTile(
                title: Text('About'),
                subtitle: Text('Fitness Quest & Training Challenge Hub'),
              ),
            ],
          );
        },
      ),
    );
  }
}
