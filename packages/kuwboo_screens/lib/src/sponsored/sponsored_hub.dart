import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class SponsoredHub extends StatelessWidget {
  const SponsoredHub({super.key});

  // Demo campaigns. Replace with `sponsoredCampaignsProvider` when the
  // advertiser backend lands.
  static const _demoCampaigns = <_DemoCampaign>[
    _DemoCampaign(
      title: 'Summer Collection Launch',
      type: 'Product Spotlight',
      status: 'Active',
      statusColor: Colors.green,
      impressions: '12.4K',
      clicks: '348',
      spent: '\u00a345.20',
      budget: '\u00a3100.00',
    ),
    _DemoCampaign(
      title: 'New Store Opening',
      type: 'Video Ad',
      status: 'Active',
      statusColor: Colors.green,
      impressions: '8.7K',
      clicks: '195',
      spent: '\u00a332.80',
      budget: '\u00a375.00',
    ),
    _DemoCampaign(
      title: 'Weekend Flash Sale',
      type: 'Promoted Post',
      status: 'Paused',
      statusColor: Colors.orange,
      impressions: '5.2K',
      clicks: '87',
      spent: '\u00a318.50',
      budget: '\u00a350.00',
    ),
    _DemoCampaign(
      title: 'Spring Clearance',
      type: 'Banner Ad',
      status: 'Completed',
      statusColor: Colors.grey,
      impressions: '22.1K',
      clicks: '614',
      spent: '\u00a3100.00',
      budget: '\u00a3100.00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);
    final activeCount =
        _demoCampaigns.where((c) => c.status == 'Active').length;

    return Container(
      color: theme.background,
      child: Column(
        children: [
          ProtoSubBar(title: 'Promote'),
          if (!kSponsoredEnabled) _ComingSoonBanner(theme: theme),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 16),

                // Stats overview cards
                _StatsRow(theme: theme),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ProtoPressButton(
                        onTap: () => state.push(ProtoRoutes.sponsoredCreate),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(theme.icons.add, size: 20, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Create Campaign',
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
                  ],
                ),

                const SizedBox(height: 24),

                // Section header
                Row(
                  children: [
                    Text(
                      'My Campaigns',
                      style: theme.title.copyWith(fontSize: 18),
                    ),
                    const Spacer(),
                    Text(
                      '$activeCount active',
                      style: theme.caption.copyWith(color: theme.primary),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Campaign cards
                for (var i = 0; i < _demoCampaigns.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _CampaignCard(
                    theme: theme,
                    campaign: _demoCampaigns[i],
                    onTap: () => state.push(ProtoRoutes.sponsoredCampaign),
                  ),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ProtoTheme theme;
  const _StatsRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(theme: theme, label: 'Impressions', value: '48.4K', icon: Icons.visibility_outlined)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(theme: theme, label: 'Clicks', value: '1,244', icon: Icons.touch_app_outlined)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(theme: theme, label: 'Spend', value: '\u00a3196', icon: Icons.payments_outlined)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.theme, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: theme.cardDecoration,
      child: Column(
        children: [
          Icon(icon, size: 22, color: theme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.text,
              fontFamily: theme.displayFont,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final ProtoTheme theme;
  final _DemoCampaign campaign;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.theme,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: theme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(campaign.title, style: theme.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(campaign.type, style: theme.caption),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: campaign.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    campaign.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: campaign.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                _CampaignStat(theme: theme, label: 'Impressions', value: campaign.impressions),
                const SizedBox(width: 16),
                _CampaignStat(theme: theme, label: 'Clicks', value: campaign.clicks),
                const Spacer(),
                Text(
                  '${campaign.spent} / ${campaign.budget}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.primary,
                    fontFamily: theme.displayFont,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple value-object for demo campaigns. Replaces the inline positional
/// duplication; swap for a real `Campaign` model once the backend lands.
class _DemoCampaign {
  final String title;
  final String type;
  final String status;
  final Color statusColor;
  final String impressions;
  final String clicks;
  final String spent;
  final String budget;

  const _DemoCampaign({
    required this.title,
    required this.type,
    required this.status,
    required this.statusColor,
    required this.impressions,
    required this.clicks,
    required this.spent,
    required this.budget,
  });
}

/// Shown at the top of the Promote hub while the advertiser backend is
/// still in build. Invisible when [kSponsoredEnabled] is flipped to true.
class _ComingSoonBanner extends StatelessWidget {
  final ProtoTheme theme;
  const _ComingSoonBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.08),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign_outlined, size: 18, color: theme.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Coming soon — Sponsored campaigns enable after launch.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignStat extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final String value;
  const _CampaignStat({required this.theme, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.title.copyWith(fontSize: 13)),
        Text(label, style: theme.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}
