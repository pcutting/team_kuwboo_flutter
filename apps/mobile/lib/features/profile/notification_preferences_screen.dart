import 'package:flutter/material.dart';

/// Notification preferences screen grouped by module.
///
/// Each category has toggles for push and in-app notifications.
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  // Module → Category → {push, inApp}
  final Map<String, Map<String, _NotifToggle>> _prefs = {
    'Video': {
      'New followers': _NotifToggle(push: true, inApp: true),
      'Likes on your videos': _NotifToggle(push: true, inApp: true),
      'Comments': _NotifToggle(push: true, inApp: true),
      'Mentions': _NotifToggle(push: false, inApp: true),
    },
    'Social': {
      'Friend requests': _NotifToggle(push: true, inApp: true),
      'Nearby matches': _NotifToggle(push: true, inApp: true),
      'Messages': _NotifToggle(push: true, inApp: true),
    },
    'Shop': {
      'Auction updates': _NotifToggle(push: true, inApp: true),
      'Price drops': _NotifToggle(push: false, inApp: true),
      'Order updates': _NotifToggle(push: true, inApp: true),
      'New bids': _NotifToggle(push: true, inApp: true),
    },
    'YoYo': {
      'Waves received': _NotifToggle(push: true, inApp: true),
      'Wave accepted': _NotifToggle(push: true, inApp: true),
      'Nearby users': _NotifToggle(push: false, inApp: true),
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                SizedBox(
                  width: 56,
                  child: Center(
                    child: Text(
                      'Push',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Center(
                    child: Text(
                      'In-App',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          for (final module in _prefs.entries) ...[
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                module.key,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(indent: 16, endIndent: 16),

            for (final category in module.value.entries)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.key,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Checkbox(
                        value: category.value.push,
                        onChanged: (value) {
                          setState(() {
                            category.value.push = value ?? false;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Checkbox(
                        value: category.value.inApp,
                        onChanged: (value) {
                          setState(() {
                            category.value.inApp = value ?? false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                // TODO: persist to backend when ready
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification preferences saved'),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save Preferences'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifToggle {
  _NotifToggle({required this.push, required this.inApp});

  bool push;
  bool inApp;
}
