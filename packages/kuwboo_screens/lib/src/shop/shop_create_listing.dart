import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuwboo_shell/kuwboo_shell.dart';

import 'shop_providers.dart';

class ShopCreateListing extends ConsumerStatefulWidget {
  const ShopCreateListing({super.key});

  @override
  ConsumerState<ShopCreateListing> createState() =>
      _ShopCreateListingState();
}

class _ShopCreateListingState extends ConsumerState<ShopCreateListing> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _condition = 'Good';
  int _photoCount = 0;
  bool _isSubmitting = false;
  String? _error;

  static const _conditions = ['New', 'Like New', 'Good', 'Fair'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  int? _priceToCents(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'[£\$€,\s]'), '');
    if (cleaned.isEmpty) return null;
    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed <= 0) return null;
    return (parsed * 100).round();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final priceCents = _priceToCents(_priceController.text);
    final theme = ProtoTheme.of(context);

    if (title.isEmpty) {
      setState(() => _error = 'Title is required');
      return;
    }
    if (description.isEmpty) {
      setState(() => _error = 'Description is required');
      return;
    }
    if (priceCents == null) {
      setState(() => _error = 'Enter a valid price');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref.read(marketplaceApiProvider).createProduct(
            title: title,
            description: description,
            priceCents: priceCents,
            condition: _condition,
          );
      if (!mounted) return;
      // Refresh browse + deals so the new listing shows up on return.
      ref.invalidate(shopBrowseProvider);
      ref.invalidate(shopDealsProvider);
      ProtoToast.show(
        context,
        theme.icons.checkCircle,
        'Listing published!',
      );
      PrototypeStateProvider.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'Could not publish listing';
      });
      ProtoToast.show(
        context,
        Icons.error_outline,
        'Could not publish listing',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = PrototypeStateProvider.of(context);
    final theme = ProtoTheme.of(context);

    return Container(
      color: theme.surface,
      child: Column(
        children: [
          ProtoSubBar(
            title: 'New Listing',
            actions: [
              ProtoPressButton(
                onTap: _isSubmitting
                    ? () {}
                    : () async {
                        final confirmed = await ProtoConfirmDialog.show(
                          context,
                          title: 'Publish Listing',
                          message: 'Post this item to the marketplace?',
                        );
                        if (!confirmed || !mounted) return;
                        await _submit();
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isSubmitting
                        ? theme.primary.withValues(alpha: 0.5)
                        : theme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'List',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.errorColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.errorColor,
                      ),
                    ),
                  ),
                ProtoPressButton(
                  onTap: () {
                    setState(() => _photoCount =
                        (_photoCount + 1).clamp(0, 10));
                    ProtoToast.show(
                      context,
                      theme.icons.addPhoto,
                      'Photo $_photoCount added',
                    );
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: theme.text.withValues(alpha: 0.1)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _photoCount > 0
                                ? theme.icons.photoLibrary
                                : theme.icons.addPhoto,
                            size: 32,
                            color: _photoCount > 0
                                ? theme.primary
                                : theme.textTertiary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _photoCount > 0
                                ? '$_photoCount photo${_photoCount == 1 ? '' : 's'} added (tap to add more)'
                                : 'Add Photos (up to 10)',
                            style: theme.caption.copyWith(
                              color:
                                  _photoCount > 0 ? theme.primary : null,
                              fontWeight:
                                  _photoCount > 0 ? FontWeight.w600 : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _TextFormField(
                  label: 'Title',
                  hint: 'What are you selling?',
                  controller: _titleController,
                ),
                _TextFormField(
                  label: 'Description',
                  hint: 'Describe your item...',
                  controller: _descriptionController,
                  multiline: true,
                ),
                _TextFormField(
                  label: 'Price',
                  hint: '£0.00',
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _ConditionPicker(
                  options: _conditions,
                  selected: _condition,
                  onChanged: (v) => setState(() => _condition = v),
                  theme: theme,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : () => state.pop(),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool multiline;
  final TextInputType? keyboardType;

  const _TextFormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.multiline = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.title.copyWith(fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: multiline ? 4 : 1,
            keyboardType: keyboardType ??
                (multiline ? TextInputType.multiline : TextInputType.text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.body.copyWith(color: theme.textTertiary),
              filled: true,
              fillColor: theme.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: theme.text.withValues(alpha: 0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: theme.text.withValues(alpha: 0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionPicker extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final ProtoTheme theme;

  const _ConditionPicker({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Condition', style: theme.title.copyWith(fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isActive = opt == selected;
              return GestureDetector(
                onTap: () => onChanged(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? theme.primary : theme.background,
                    borderRadius: BorderRadius.circular(20),
                    border: isActive
                        ? null
                        : Border.all(
                            color: theme.text.withValues(alpha: 0.1),
                          ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : theme.textSecondary,
                    ),
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
