import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class SponsoredCampaignDetail extends StatefulWidget {
  const SponsoredCampaignDetail({super.key});

  @override
  State<SponsoredCampaignDetail> createState() =>
      _SponsoredCampaignDetailState();
}

class _SponsoredCampaignDetailState extends State<SponsoredCampaignDetail> {
  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            ProtoSubBar(
              title: 'Campaign Detail',
              actions: [
                GestureDetector(
                  onTap: () => ProtoToast.show(
                    context,
                    theme.icons.settings,
                    'Campaign settings',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      theme.icons.moreHoriz,
                      size: 22,
                      color: theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),

                  // Campaign header
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: theme.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.primary, theme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            theme.icons.campaign,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Summer Collection Launch',
                                style: theme.title.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Product Spotlight · Started 3 days ago',
                                style: theme.caption,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _isPaused
                                ? Colors.orange.withValues(alpha: 0.12)
                                : Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isPaused ? 'Paused' : 'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _isPaused ? Colors.orange : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Key metrics
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          theme: theme,
                          value: '12.4K',
                          label: 'Impressions',
                          change: '+18%',
                          positive: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricCard(
                          theme: theme,
                          value: '348',
                          label: 'Clicks',
                          change: '+12%',
                          positive: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          theme: theme,
                          value: '2.8%',
                          label: 'CTR',
                          change: '-0.2%',
                          positive: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricCard(
                          theme: theme,
                          value: '£45.20',
                          label: 'Spent',
                          change: '45%',
                          positive: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Performance chart
                  Text(
                    'Daily Performance',
                    style: theme.title.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  _PerformanceChart(theme: theme),

                  const SizedBox(height: 20),

                  // Budget progress
                  Text('Budget', style: theme.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: theme.cardDecoration,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '£45.20 spent',
                              style: theme.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text('£100.00 budget', style: theme.caption),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.452,
                            minHeight: 8,
                            backgroundColor: theme.text.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '£54.80 remaining',
                              style: theme.caption.copyWith(
                                color: theme.primary,
                              ),
                            ),
                            Text('11 days left', style: theme.caption),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Targeting summary
                  Text('Targeting', style: theme.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: theme.cardDecoration,
                    child: Column(
                      children: [
                        _DetailRow(
                          theme: theme,
                          label: 'Modules',
                          value: 'Video, Social, Shop',
                        ),
                        _DetailRow(
                          theme: theme,
                          label: 'Location',
                          value: 'United Kingdom',
                        ),
                        _DetailRow(theme: theme, label: 'Age', value: '18–45+'),
                        _DetailRow(
                          theme: theme,
                          label: 'Bid type',
                          value: 'CPM (£2.94 avg)',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Creative preview
                  Text('Creative', style: theme.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: theme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            gradient: LinearGradient(
                              colors: [theme.primary, theme.secondary],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              theme.icons.image,
                              size: 36,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Summer Collection — Up to 50% Off',
                                style: theme.title.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discover our new summer collection with styles for every occasion.',
                                style: theme.caption,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Shop Now',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ProtoPressButton(
                          onTap: () {
                            setState(() => _isPaused = !_isPaused);
                            ProtoToast.show(
                              context,
                              _isPaused
                                  ? Icons.pause_circle_outlined
                                  : Icons.play_circle_outlined,
                              _isPaused
                                  ? 'Campaign paused'
                                  : 'Campaign resumed',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.text.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isPaused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                  size: 20,
                                  color: theme.text,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPaused ? 'Resume' : 'Pause',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ProtoPressButton(
                          onTap: () async {
                            final confirmed = await ProtoConfirmDialog.show(
                              context,
                              title: 'End Campaign?',
                              message:
                                  'This will stop your campaign. Remaining budget will not be charged.',
                            );
                            if (confirmed && mounted) {
                              ProtoToast.show(
                                context,
                                theme.icons.checkCircle,
                                'Campaign ended',
                              );
                              PrototypeStateProvider.of(context).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.stop_circle_outlined,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'End',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final ProtoTheme theme;
  final String value;
  final String label;
  final String change;
  final bool positive;
  const _MetricCard({
    required this.theme,
    required this.value,
    required this.label,
    required this.change,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: theme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.text,
                  fontFamily: theme.displayFont,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (positive ? Colors.green : Colors.red).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: positive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.caption),
        ],
      ),
    );
  }
}

class _PerformanceChart extends StatelessWidget {
  final ProtoTheme theme;
  const _PerformanceChart({required this.theme});

  @override
  Widget build(BuildContext context) {
    // Mock daily data for 7 days
    final data = [820, 1450, 2100, 1800, 2400, 1950, 2800];
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: theme.cardDecoration,
      child: Column(
        children: [
          // Chart bars
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final fraction = data[i] / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(data[i] / 1000).toStringAsFixed(1)}K',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: theme.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 80 * fraction,
                          decoration: BoxDecoration(
                            color: i == data.length - 1
                                ? theme.primary
                                : theme.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          // Day labels
          Row(
            children: labels.map((l) {
              return Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: TextStyle(fontSize: 10, color: theme.textTertiary),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final String value;
  const _DetailRow({
    required this.theme,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.caption.copyWith(fontSize: 12)),
          Text(
            value,
            style: theme.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
