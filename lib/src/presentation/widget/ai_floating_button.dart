import 'package:flutter/material.dart';
import 'package:smart_restaurant_finder/core/services/ai_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AIFloatingButton extends StatefulWidget {
  const AIFloatingButton({super.key});

  @override
  State<AIFloatingButton> createState() => _AIFloatingButtonState();
}

class _AIFloatingButtonState extends State<AIFloatingButton> {
  bool _isLoading = false;

  // Filter states
  String? _selectedMood;
  String? _selectedBudget;
  String? _selectedCuisine;
  String? _selectedNoiseLevel;
  String? _selectedLocation;
  String? _specialRequirements;

  Future<void> _showFilterDialog(BuildContext context) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tell me what you\'re looking for...',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterSection(
                    context,
                    title: '🎭 What\'s your mood?',
                    options: ['Casual', 'Romantic', 'Business', 'Family', 'Celebration', 'Quick Bite'],
                    selected: _selectedMood,
                    onChanged: (value) => setState(() => _selectedMood = value),
                  ),
                  _buildFilterSection(
                    context,
                    title: '💰 Budget range?',
                    options: ['Budget-friendly', 'Moderate', 'Fine Dining', 'No limit'],
                    selected: _selectedBudget,
                    onChanged: (value) => setState(() => _selectedBudget = value),
                  ),
                  _buildFilterSection(
                    context,
                    title: '🍽️ Cuisine preference?',
                    options: ['Local Zimbabwean', 'International', 'Asian', 'European', 'American', 'Fusion', 'Any'],
                    selected: _selectedCuisine,
                    onChanged: (value) => setState(() => _selectedCuisine = value),
                  ),
                  _buildFilterSection(
                    context,
                    title: '🔊 Noise preference?',
                    options: ['Quiet', 'Moderate', 'Lively', 'Any'],
                    selected: _selectedNoiseLevel,
                    onChanged: (value) => setState(() => _selectedNoiseLevel = value),
                  ),
                  _buildFilterSection(
                    context,
                    title: '📍 Area in Harare?',
                    options: ['City Center', 'Avondale', 'Borrowdale', 'Sam Levy\'s', 'Anywhere'],
                    selected: _selectedLocation,
                    onChanged: (value) => setState(() => _selectedLocation = value),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: '📋 Any special requirements?',
                      hintText: 'e.g., vegetarian, outdoor seating, wifi...',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => _specialRequirements = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: theme.textTheme.bodyMedium),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _getRecommendations(context);
                },
                child: const Text('Find My Spot!'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, {
        required String title,
        required List<String> options,
        required String? selected,
        required Function(String?) onChanged,
      }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return FilterChip(
              label: Text(option, style: theme.textTheme.bodyMedium),
              selected: isSelected,
              onSelected: (bool selected) {
                onChanged(selected ? option : null);
              },
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              selectedColor: Colors.orange.shade200,
              checkmarkColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.orange, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  Future<void> _getRecommendations(BuildContext context) async {
    setState(() => _isLoading = true);

    final recommendations = await SimpleAIService.getRestaurantRecommendations(
      mood: _selectedMood,
      budget: _selectedBudget,
      cuisine: _selectedCuisine,
      noiseLevel: _selectedNoiseLevel,
      location: _selectedLocation,
      specialRequirements: _specialRequirements,
    );

    setState(() => _isLoading = false);

    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Text('Your Harare Matches', style: theme.textTheme.titleMedium),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(recommendations, style: theme.textTheme.bodyMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay!'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFilterDialog(context);
            },
            child: const Text('Adjust Filters'),
          ),
          TextButton(
            onPressed: () async {
              final String phoneNumber = "+263714024267";
              final String message = Uri.encodeComponent(
                  "Hello, I'm having trouble with the AI restaurant guide. Can you recommend places in Harare?"
              );
              final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber?text=$message");

              if (await canLaunchUrl(whatsappUri)) {
                await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Reach us on WhatsApp'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : () => _showFilterDialog(context),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      icon: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Icon(Icons.auto_awesome),
      label: _isLoading
          ? Text('Finding matches...',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary))
          : Text('AI Restaurant Guide',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
    );
  }
}
