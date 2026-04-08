import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Form to create a new product listing, with optional auction fields.
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _minIncrementController = TextEditingController();

  String _condition = 'NEW';
  bool _isAuction = false;
  bool _isSubmitting = false;
  DateTime? _auctionStart;
  DateTime? _auctionEnd;

  static const _conditions = {
    'NEW': 'New',
    'LIKE_NEW': 'Like New',
    'GOOD': 'Good',
    'FAIR': 'Fair',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _startPriceController.dispose();
    _minIncrementController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(Duration(days: isStart ? 1 : 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null || !mounted) return;

    final dateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _auctionStart = dateTime;
      } else {
        _auctionEnd = dateTime;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // TODO: call MarketplaceApi.createProduct() and optionally createAuction()
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing created successfully')),
    );
    context.pop();
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Select';
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Listing')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo placeholder
            GestureDetector(
              onTap: () {
                // TODO: image picker
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Photos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title required' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Description required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (\u00a3)',
                border: OutlineInputBorder(),
                prefixText: '\u00a3 ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price required';
                final parsed = double.tryParse(v);
                if (parsed == null || parsed <= 0) return 'Invalid price';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: _conditions.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _condition = v);
              },
            ),
            const SizedBox(height: 20),

            // Auction toggle
            SwitchListTile(
              title: const Text('List as Auction'),
              subtitle: const Text('Let buyers bid on this item'),
              value: _isAuction,
              onChanged: (v) => setState(() => _isAuction = v),
              contentPadding: EdgeInsets.zero,
            ),

            if (_isAuction) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _startPriceController,
                decoration: const InputDecoration(
                  labelText: 'Starting Price (\u00a3)',
                  border: OutlineInputBorder(),
                  prefixText: '\u00a3 ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                validator: _isAuction
                    ? (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Starting price required';
                        }
                        return null;
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minIncrementController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Bid Increment (\u00a3)',
                  border: OutlineInputBorder(),
                  prefixText: '\u00a3 ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                validator: _isAuction
                    ? (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Increment required';
                        }
                        return null;
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auction Start'),
                subtitle: Text(_formatDateTime(_auctionStart)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Auction End'),
                subtitle: Text(_formatDateTime(_auctionEnd)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: false),
              ),
            ],
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isAuction ? 'Create Auction' : 'List Item'),
            ),
          ],
        ),
      ),
    );
  }
}
