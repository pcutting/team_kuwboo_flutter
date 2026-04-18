import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'yoyo_providers.dart';

class YoyoUserProfile extends ConsumerStatefulWidget {
  const YoyoUserProfile({super.key});

  @override
  ConsumerState<YoyoUserProfile> createState() => _YoyoUserProfileState();
}

class _YoyoUserProfileState extends ConsumerState<YoyoUserProfile> {
  bool _hasWaved = false;
  bool _isRevealed = true; // toggle for teaser/revealed demo

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final user = DemoData.nearbyUsers[0];
    final encounter = ProtoDemoData.encounters[0]; // Maya — shared, friend
    // First real nearby user (if loaded) — target for the live wave button.
    final realTarget = ref.watch(yoyoNearbyProvider).valueOrNull?.firstOrNull;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(
              title: !_isRevealed ? 'Anonymous User' : user.name,
              actions: [
                ProtoPressButton(
                  onTap: () => ProtoShareSheet.show(context),
                  child: Icon(theme.icons.share, size: 20, color: theme.text),
                ),
              ],
            ),
            Expanded(
              child: _buildProfile(
                context,
                theme,
                state,
                user,
                encounter,
                realTarget?.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    ProtoTheme theme,
    PrototypeStateProvider state,
    NearbyUser user,
    DemoEncounter enc,
    String? realTargetId,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 12),
        // Teaser/revealed toggle
        Center(
          child: ProtoPressButton(
            onTap: () => setState(() => _isRevealed = !_isRevealed),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _isRevealed
                    ? 'Viewing: Revealed'
                    : 'Viewing: Teaser (pre-consent)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (!_isRevealed) ...[
          // Teaser view — blurred placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(theme.radiusMd),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 48,
                    color: theme.textTertiary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profile Hidden',
                    style: theme.body.copyWith(color: theme.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Anonymous User', style: theme.headline.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          // Encounter badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: enc.encounterType == EncounterType.nearby
                      ? theme.secondary.withValues(alpha: 0.15)
                      : Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      enc.encounterType == EncounterType.nearby
                          ? Icons.pin_drop_rounded
                          : Icons.flash_on_rounded,
                      size: 12,
                      color: enc.encounterType == EncounterType.nearby
                          ? theme.secondary
                          : Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      enc.encounterType == EncounterType.nearby
                          ? 'Nearby'
                          : 'Pass-by',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: enc.encounterType == EncounterType.nearby
                            ? theme.secondary
                            : Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Very Near',
                style: theme.caption.copyWith(color: theme.textTertiary),
              ),
              if (enc.ageRange != null) ...[
                const SizedBox(width: 8),
                Text(
                  enc.ageRange!,
                  style: theme.caption.copyWith(color: theme.textTertiary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text('Interests', style: theme.title),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: enc.interests
                .map(
                  (i) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: theme.accentPillDecoration(theme.primary),
                    child: Text(
                      i[0].toUpperCase() + i.substring(1),
                      style: theme.caption.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          // Consent buttons
          SizedBox(
            width: double.infinity,
            child: ProtoPressButton(
              onTap: () {
                setState(() => _isRevealed = true);
                ProtoToast.show(
                  context,
                  Icons.celebration_rounded,
                  'Profiles revealed! Say hello',
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Share My Card',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: ProtoPressButton(
              onTap: () {
                state.pop();
                ProtoToast.show(
                  context,
                  Icons.schedule_rounded,
                  'Maybe next time',
                );
              },
              child: Text(
                'Not now',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ),
          ),
        ] else ...[
          // Revealed view
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.radiusMd),
              child: Image.network(
                user.imageUrl.replaceAll('100', '400'),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(user.name, style: theme.headline.copyWith(fontSize: 24)),
              const SizedBox(width: 8),
              if (enc.relationship == RelationshipType.friend)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Friend',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                )
              else if (enc.relationship == RelationshipType.partner)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_rounded, size: 12, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'Partner',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              if (user.isOnline) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          // "How you met" encounter badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  enc.encounterType == EncounterType.nearby
                      ? Icons.pin_drop_rounded
                      : Icons.flash_on_rounded,
                  size: 14,
                  color: theme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${enc.encounterType == EncounterType.nearby ? "Nearby" : "Pass-by"} encounter, ${enc.encounterTime}',
                  style: TextStyle(fontSize: 12, color: theme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Interests', style: theme.title),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProtoDemoData.interests
                .take(6)
                .map(
                  (i) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: theme.accentPillDecoration(theme.primary),
                    child: Text(
                      i.name,
                      style: theme.caption.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          // Who Saw Me section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: theme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      size: 16,
                      color: theme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Who Saw Me',
                      style: theme.title.copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Seen 3 times this week', style: theme.caption),
                Text('Last seen by you: 2h ago', style: theme.caption),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Retention indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_delete_rounded,
                  size: 14,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  'Profile data expires in 28h',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(context, theme, state, user, realTargetId),
        ],
        const SizedBox(height: 24),
        Center(
          child: ProtoPressButton(
            onTap: () => ProtoToast.show(
              context,
              theme.icons.flag,
              'Report dialog would open',
            ),
            child: Text(
              'Report or Block',
              style: theme.caption.copyWith(color: theme.textTertiary),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ProtoTheme theme,
    PrototypeStateProvider state,
    NearbyUser user,
    String? realTargetId,
  ) {
    return Row(
      children: [
        Expanded(
          child: ProtoPressButton(
            onTap: () async {
              if (_hasWaved) return;
              setState(() => _hasWaved = true);
              if (realTargetId != null) {
                try {
                  await ref
                      .read(yoyoApiProvider)
                      .sendWave(toUserId: realTargetId);
                  ref.invalidate(yoyoSentWavesProvider);
                } catch (_) {
                  /* swallow */
                }
              }
              if (!context.mounted) return;
              ProtoToast.show(
                context,
                theme.icons.wavingHand,
                'Waved at ${user.name}!',
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _hasWaved ? theme.secondary : theme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _hasWaved
                    ? Row(
                        key: const ValueKey('waved'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            theme.icons.check,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Waved!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('wave'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            theme.icons.wavingHand,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Wave',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ProtoPressButton(
            onTap: () => state.push(ProtoRoutes.chatConversation),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.text.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    theme.icons.chatBubbleOutline,
                    size: 18,
                    color: theme.text,
                  ),
                  const SizedBox(width: 8),
                  Text('Message', style: theme.title.copyWith(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
