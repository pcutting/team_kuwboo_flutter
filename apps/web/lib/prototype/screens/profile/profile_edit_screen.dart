import 'package:flutter/material.dart';
import '../../proto_theme.dart';
import '../../shared/proto_image.dart';
import '../../prototype_state.dart';
import '../../prototype_demo_data.dart';
import '../../shared/proto_scaffold.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.surface,
      child: Column(
        children: [
          ProtoSubBar(
            title: 'Edit Profile',
            actions: [
              GestureDetector(
                onTap: () => state.pop(),
                child: Text('Save', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.primary)),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Photos grid
                SizedBox(
                  height: 100,
                  child: Row(
                    children: List.generate(3, (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.text.withValues(alpha: 0.1)),
                        ),
                        child: i == 0
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ProtoNetworkImage(imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop'),
                              )
                            : Icon(theme.icons.add, size: 28, color: theme.textTertiary),
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 20),

                _EditField(label: 'Name', value: 'Alex Chen'),
                _EditField(label: 'Username', value: '@alexhikes'),
                _EditField(label: 'Bio', value: 'Software engineer who loves hiking and craft beer.', multiline: true),

                const SizedBox(height: 16),
                Text('Interests', style: theme.title),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ProtoDemoData.interests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: interest.isSelected ? theme.primary : theme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: interest.isSelected ? null : Border.all(color: theme.text.withValues(alpha: 0.1)),
                      ),
                      child: Text(interest.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: interest.isSelected ? theme.onPrimary : theme.textSecondary)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;
  const _EditField({required this.label, required this.value, this.multiline = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ProtoTheme.of(context).caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: multiline ? 12 : 10),
            decoration: BoxDecoration(color: ProtoTheme.of(context).background, borderRadius: BorderRadius.circular(10), border: Border.all(color: ProtoTheme.of(context).text.withValues(alpha: 0.08))),
            child: Text(value, style: ProtoTheme.of(context).body.copyWith(color: ProtoTheme.of(context).text)),
          ),
        ],
      ),
    );
  }
}
