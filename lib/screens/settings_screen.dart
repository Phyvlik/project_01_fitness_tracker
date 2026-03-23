import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context, AppProvider provider) async {
    try {
      final path = await provider.exportDataToJson();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to: $path')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export data.')),
      );
    }
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
                subtitle: const Text('Save workouts and quests to local storage'),
                trailing: const Icon(Icons.download),
                onTap: () => _exportData(context, provider),
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
