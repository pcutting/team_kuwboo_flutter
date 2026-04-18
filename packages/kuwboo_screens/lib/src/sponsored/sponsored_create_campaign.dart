import 'package:flutter/material.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

class SponsoredCreateCampaign extends StatefulWidget {
  const SponsoredCreateCampaign({super.key});

  @override
  State<SponsoredCreateCampaign> createState() =>
      _SponsoredCreateCampaignState();
}

class _SponsoredCreateCampaignState extends State<SponsoredCreateCampaign> {
  int _currentStep = 0;

  // Step 1: Campaign type
  int _selectedType = -1;

  // Step 2: Targeting
  final Set<String> _selectedModules = {'video_making', 'social_stumble'};
  double _ageMin = 18;
  double _ageMax = 45;

  // Step 4: Budget
  int _selectedBudgetType = 0; // 0=daily, 1=lifetime
  int _selectedBidType = 0; // 0=CPM, 1=CPC

  static const _campaignTypes = [
    ('Promoted Post', Icons.article_outlined, 'Native post in social feeds'),
    ('Video Ad', Icons.videocam_outlined, 'Short video in the video feed'),
    (
      'Product Spotlight',
      Icons.storefront_outlined,
      'Featured listing in shop',
    ),
    ('Banner Ad', Icons.web_outlined, 'Banner across any module'),
  ];

  static const _modules = [
    ('video_making', 'Video Feed', Icons.play_circle_outline_rounded),
    ('social_stumble', 'Social', Icons.people_outline_rounded),
    ('buy_sell', 'Shop', Icons.storefront_outlined),
    ('dating', 'Dating', Icons.favorite_outline_rounded),
  ];

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      PrototypeStateProvider.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            _CreateCampaignBar(theme: theme, onBack: _prevStep),
            // Progress indicator
            _StepIndicator(
              theme: theme,
              currentStep: _currentStep,
              totalSteps: 6,
            ),
            Expanded(child: _buildCurrentStep(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ProtoTheme theme) {
    switch (_currentStep) {
      case 0:
        return _buildTypeStep(theme);
      case 1:
        return _buildTargetStep(theme);
      case 2:
        return _buildCreativeStep(theme);
      case 3:
        return _buildBudgetStep(theme);
      case 4:
        return _buildReviewStep(theme);
      case 5:
        return _buildWebPreviewStep(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Choose campaign type ──────────────────────────────────────────

  Widget _buildTypeStep(ProtoTheme theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Choose Ad Type', style: theme.headline.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          'Select the format for your campaign',
          style: theme.body.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 20),

        ...List.generate(_campaignTypes.length, (i) {
          final (title, icon, desc) = _campaignTypes[i];
          final isSelected = _selectedType == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProtoPressButton(
              onTap: () => setState(() => _selectedType = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primary.withValues(alpha: 0.08)
                      : theme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? theme.primary
                        : theme.text.withValues(alpha: 0.08),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primary.withValues(alpha: 0.12)
                            : theme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isSelected ? theme.primary : theme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.title.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(desc, style: theme.caption),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        theme.icons.checkCircle,
                        size: 22,
                        color: theme.primary,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        _NextButton(
          theme: theme,
          label: 'Continue',
          enabled: _selectedType >= 0,
          onTap: _nextStep,
        ),
      ],
    );
  }

  // ── Step 2: Target audience ───────────────────────────────────────────────

  Widget _buildTargetStep(ProtoTheme theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Target Audience', style: theme.headline.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          'Choose who sees your ad',
          style: theme.body.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 20),

        // Module targeting
        Text('Show in modules', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _modules.map((m) {
            final (key, label, icon) = m;
            final isSelected = _selectedModules.contains(key);
            return ProtoPressButton(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedModules.remove(key);
                  } else {
                    _selectedModules.add(key);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primary.withValues(alpha: 0.1)
                      : theme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.primary
                        : theme.text.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? theme.primary : theme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: theme.caption.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? theme.primary : theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Location
        Text('Location', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(theme.icons.locationOn, size: 20, color: theme.primary),
              const SizedBox(width: 10),
              Text('United Kingdom', style: theme.body),
              const Spacer(),
              Icon(
                theme.icons.chevronRight,
                size: 20,
                color: theme.textTertiary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Age range
        Text('Age Range', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              '${_ageMin.round()}',
              style: theme.body.copyWith(fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: RangeSlider(
                values: RangeValues(_ageMin, _ageMax),
                min: 13,
                max: 65,
                divisions: 52,
                activeColor: theme.primary,
                inactiveColor: theme.text.withValues(alpha: 0.1),
                onChanged: (values) {
                  setState(() {
                    _ageMin = values.start;
                    _ageMax = values.end;
                  });
                },
              ),
            ),
            Text(
              '${_ageMax.round()}+',
              style: theme.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Interests
        Text('Interests', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              [
                'Fashion',
                'Tech',
                'Music',
                'Sports',
                'Food',
                'Travel',
                'Art',
                'Fitness',
              ].map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    interest,
                    style: theme.caption.copyWith(color: theme.primary),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: 24),
        _NextButton(
          theme: theme,
          label: 'Continue',
          enabled: _selectedModules.isNotEmpty,
          onTap: _nextStep,
        ),
      ],
    );
  }

  // ── Step 3: Creative ──────────────────────────────────────────────────────

  Widget _buildCreativeStep(ProtoTheme theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ad Creative', style: theme.headline.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          'Design your ad content',
          style: theme.body.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 20),

        // Image upload placeholder
        GestureDetector(
          onTap: () => ProtoToast.show(
            context,
            Icons.photo_library_outlined,
            'Media picker would open',
          ),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.text.withValues(alpha: 0.1),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    theme.icons.addPhoto,
                    size: 28,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload Image or Video',
                  style: theme.title.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text('Tap to select media', style: theme.caption),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Headline field
        Text('Headline', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.text.withValues(alpha: 0.08)),
          ),
          child: Text(
            'Summer Collection — Up to 50% Off',
            style: theme.body.copyWith(color: theme.text),
          ),
        ),

        const SizedBox(height: 16),

        // Description field
        Text('Description', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.text.withValues(alpha: 0.08)),
          ),
          child: Text(
            'Discover our new summer collection with styles for every occasion. Limited time only.',
            style: theme.body.copyWith(color: theme.text),
            maxLines: 3,
          ),
        ),

        const SizedBox(height: 16),

        // CTA text
        Text('Call to Action', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: ['Shop Now', 'Learn More', 'Sign Up', 'Watch'].map((cta) {
            final isSelected = cta == 'Shop Now';
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primary : theme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? null
                      : Border.all(color: theme.text.withValues(alpha: 0.1)),
                ),
                child: Text(
                  cta,
                  style: theme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : theme.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Preview
        Text('Preview', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Container(
          decoration: theme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
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
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.textTertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Sponsored',
                            style: theme.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Brand',
                          style: theme.title.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Summer Collection — Up to 50% Off',
                      style: theme.title.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover our new summer collection with styles for every occasion.',
                      style: theme.caption,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Shop Now',
                          style: theme.button.copyWith(fontSize: 13),
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
        _NextButton(
          theme: theme,
          label: 'Continue',
          enabled: true,
          onTap: _nextStep,
        ),
      ],
    );
  }

  // ── Step 4: Budget & schedule ─────────────────────────────────────────────

  Widget _buildBudgetStep(ProtoTheme theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Budget & Schedule', style: theme.headline.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          'Set your spending limits and timeline',
          style: theme.body.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 20),

        // Budget type
        Text('Budget Type', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                theme: theme,
                label: 'Daily Budget',
                isSelected: _selectedBudgetType == 0,
                onTap: () => setState(() => _selectedBudgetType = 0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ToggleChip(
                theme: theme,
                label: 'Lifetime Budget',
                isSelected: _selectedBudgetType == 1,
                onTap: () => setState(() => _selectedBudgetType = 1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Budget amount
        Text(
          _selectedBudgetType == 0 ? 'Daily Amount' : 'Total Amount',
          style: theme.title.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.text.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Text(
                '£',
                style: theme.headline.copyWith(
                  fontSize: 20,
                  color: theme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedBudgetType == 0 ? '10.00' : '100.00',
                style: theme.headline.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text('per day', style: theme.caption),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Text(
          _selectedBudgetType == 0
              ? 'Estimated 1,200–3,400 impressions per day'
              : 'Estimated 12,000–34,000 total impressions',
          style: theme.caption.copyWith(color: theme.primary),
        ),

        const SizedBox(height: 24),

        // Bid type
        Text('Bid Strategy', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                theme: theme,
                label: 'CPM',
                subtitle: 'Per 1K views',
                isSelected: _selectedBidType == 0,
                onTap: () => setState(() => _selectedBidType = 0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ToggleChip(
                theme: theme,
                label: 'CPC',
                subtitle: 'Per click',
                isSelected: _selectedBidType == 1,
                onTap: () => setState(() => _selectedBidType = 1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Schedule
        Text('Schedule', style: theme.title.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DateField(theme: theme, label: 'Start', value: 'Today'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateField(theme: theme, label: 'End', value: '14 days'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Cost summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              _SummaryRow(theme: theme, label: 'Budget', value: '£100.00'),
              const SizedBox(height: 6),
              _SummaryRow(theme: theme, label: 'Duration', value: '14 days'),
              const SizedBox(height: 6),
              _SummaryRow(
                theme: theme,
                label: 'Est. impressions',
                value: '12K–34K',
              ),
              Divider(height: 16, color: theme.primary.withValues(alpha: 0.15)),
              _SummaryRow(
                theme: theme,
                label: 'Est. cost per result',
                value: _selectedBidType == 0
                    ? '£2.94–£8.33 CPM'
                    : '£0.15–£0.42 CPC',
                bold: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _NextButton(
          theme: theme,
          label: 'Review Campaign',
          enabled: true,
          onTap: _nextStep,
        ),
      ],
    );
  }

  // ── Step 5: Review & confirm ──────────────────────────────────────────────

  Widget _buildReviewStep(ProtoTheme theme) {
    final typeName = _selectedType >= 0
        ? _campaignTypes[_selectedType].$1
        : 'Not selected';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Review Campaign', style: theme.headline.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          'Check your details before proceeding',
          style: theme.body.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 20),

        _ReviewSection(theme: theme, title: 'Campaign Type', value: typeName),
        _ReviewSection(
          theme: theme,
          title: 'Target Modules',
          value: _selectedModules
              .map((m) {
                switch (m) {
                  case 'video_making':
                    return 'Video';
                  case 'social_stumble':
                    return 'Social';
                  case 'buy_sell':
                    return 'Shop';
                  case 'dating':
                    return 'Dating';
                  default:
                    return m;
                }
              })
              .join(', '),
        ),
        _ReviewSection(
          theme: theme,
          title: 'Age Range',
          value: '${_ageMin.round()}–${_ageMax.round()}+',
        ),
        _ReviewSection(
          theme: theme,
          title: 'Location',
          value: 'United Kingdom',
        ),
        _ReviewSection(
          theme: theme,
          title: 'Budget',
          value: _selectedBudgetType == 0 ? '£10.00/day' : '£100.00 total',
        ),
        _ReviewSection(
          theme: theme,
          title: 'Bid Strategy',
          value: _selectedBidType == 0
              ? 'CPM (per 1K views)'
              : 'CPC (per click)',
        ),
        _ReviewSection(
          theme: theme,
          title: 'Schedule',
          value: 'Today – 14 days',
        ),

        const SizedBox(height: 16),

        // Info notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Payment is collected via our web portal to keep costs low. You\'ll complete checkout in your browser.',
                  style: theme.caption.copyWith(
                    fontSize: 12,
                    color: theme.text,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _NextButton(
          theme: theme,
          label: 'Complete on Web',
          icon: Icons.open_in_new_rounded,
          enabled: true,
          onTap: _nextStep,
        ),
      ],
    );
  }

  // ── Step 6: Web payment preview ───────────────────────────────────────────

  Widget _buildWebPreviewStep(ProtoTheme theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // "Web Portal Preview" label
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'WEB PORTAL PREVIEW',
              style: theme.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text('Checkout', style: theme.headline.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text('advertise.kuwboo.com', style: theme.caption),
        const SizedBox(height: 20),

        // Campaign summary card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: theme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campaign Summary',
                style: theme.title.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 10),
              _CheckoutRow(
                theme: theme,
                label: 'Summer Collection Launch',
                value: '',
              ),
              _CheckoutRow(
                theme: theme,
                label: 'Product Spotlight · 14 days',
                value: '',
              ),
              Divider(height: 16, color: theme.text.withValues(alpha: 0.06)),
              _CheckoutRow(theme: theme, label: 'Subtotal', value: '£100.00'),
              _CheckoutRow(theme: theme, label: 'VAT (20%)', value: '£20.00'),
              Divider(height: 16, color: theme.text.withValues(alpha: 0.06)),
              _CheckoutRow(
                theme: theme,
                label: 'Total',
                value: '£120.00',
                bold: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stripe-style payment form
        Container(
          padding: const EdgeInsets.all(14),
          decoration: theme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment', style: theme.title.copyWith(fontSize: 14)),
              const SizedBox(height: 12),

              // Card number
              _MockInputField(
                theme: theme,
                label: 'Card number',
                value: '4242 4242 4242 4242',
                icon: Icons.credit_card_rounded,
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _MockInputField(
                      theme: theme,
                      label: 'Expiry',
                      value: '12/27',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MockInputField(
                      theme: theme,
                      label: 'CVC',
                      value: '•••',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _MockInputField(
                theme: theme,
                label: 'Name on card',
                value: 'Alex Chen',
              ),

              const SizedBox(height: 14),

              // Stripe badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 12,
                    color: theme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Powered by Stripe',
                    style: theme.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Pay button
        ProtoPressButton(
          onTap: () {
            ProtoToast.show(
              context,
              Icons.check_circle_rounded,
              'Campaign submitted!',
            );
            // Pop back to hub after a brief delay
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                final state = PrototypeStateProvider.of(context);
                state.pop(); // Back to hub
              }
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Pay £120.00',
                style: theme.button.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
        Center(
          child: Text(
            'This is a preview. No payment will be taken.',
            style: theme.caption.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _CreateCampaignBar extends StatelessWidget {
  final ProtoTheme theme;
  final VoidCallback onBack;
  const _CreateCampaignBar({required this.theme, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 14, left: 8, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.text.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.background,
                shape: BoxShape.circle,
              ),
              child: Icon(theme.icons.arrowBack, size: 16, color: theme.text),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Create Campaign',
              style: theme.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final ProtoTheme theme;
  final int currentStep;
  final int totalSteps;
  const _StepIndicator({
    required this.theme,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isCompleted = i < currentStep;
          final isCurrent = i == currentStep;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: isCompleted
                    ? theme.primary
                    : isCurrent
                    ? theme.primary.withValues(alpha: 0.5)
                    : theme.text.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final IconData? icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NextButton({
    required this.theme,
    required this.label,
    this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProtoPressButton(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? theme.primary : theme.text.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.button.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : theme.textTertiary,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(
                icon,
                size: 16,
                color: enabled ? Colors.white : theme.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  const _ToggleChip({
    required this.theme,
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.1)
              : theme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.primary
                : theme.text.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.title.copyWith(
                fontSize: 14,
                color: isSelected ? theme.primary : theme.text,
              ),
            ),
            if (subtitle != null)
              Text(subtitle!, style: theme.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final String value;
  const _DateField({
    required this.theme,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.text.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.caption.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                value,
                style: theme.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: theme.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({
    required this.theme,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold
              ? theme.title.copyWith(fontSize: 13)
              : theme.body.copyWith(fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: theme.text,
            fontFamily: theme.displayFont,
          ),
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final ProtoTheme theme;
  final String title;
  final String value;
  const _ReviewSection({
    required this.theme,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: theme.caption.copyWith(fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final String value;
  final bool bold;
  const _CheckoutRow({
    required this.theme,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: bold
                ? theme.title.copyWith(fontSize: 13)
                : theme.body.copyWith(fontSize: 13),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: theme.text,
                fontFamily: theme.displayFont,
              ),
            ),
        ],
      ),
    );
  }
}

class _MockInputField extends StatelessWidget {
  final ProtoTheme theme;
  final String label;
  final String value;
  final IconData? icon;
  const _MockInputField({
    required this.theme,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.text.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.caption.copyWith(fontSize: 9)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(value, style: theme.body.copyWith(fontSize: 14)),
              ),
              if (icon != null) Icon(icon, size: 18, color: theme.textTertiary),
            ],
          ),
        ],
      ),
    );
  }
}
