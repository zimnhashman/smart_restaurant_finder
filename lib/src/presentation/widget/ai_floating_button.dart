import 'package:flutter/material.dart';
import 'package:smart_restaurant_finder/core/services/ai_service.dart';

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
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 8),
                Text('Tell me what you\'re looking for...'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mood
                  _buildFilterSection(
                    title: '🎭 What\'s your mood?',
                    options: ['Casual', 'Romantic', 'Business', 'Family', 'Celebration', 'Quick Bite'],
                    selected: _selectedMood,
                    onChanged: (value) => setState(() => _selectedMood = value),
                  ),

                  // Budget
                  _buildFilterSection(
                    title: '💰 Budget range?',
                    options: ['Budget-friendly', 'Moderate', 'Fine Dining', 'No limit'],
                    selected: _selectedBudget,
                    onChanged: (value) => setState(() => _selectedBudget = value),
                  ),

                  // Cuisine
                  _buildFilterSection(
                    title: '🍽️ Cuisine preference?',
                    options: ['Local Zimbabwean', 'International', 'Asian', 'European', 'American', 'Fusion', 'Any'],
                    selected: _selectedCuisine,
                    onChanged: (value) => setState(() => _selectedCuisine = value),
                  ),

                  // Noise Level
                  _buildFilterSection(
                    title: '🔊 Noise preference?',
                    options: ['Quiet', 'Moderate', 'Lively', 'Any'],
                    selected: _selectedNoiseLevel,
                    onChanged: (value) => setState(() => _selectedNoiseLevel = value),
                  ),

                  // Location in Harare
                  _buildFilterSection(
                    title: '📍 Area in Harare?',
                    options: ['City Center', 'Avondale', 'Borrowdale', 'Sam Levy\'s', 'Anywhere'],
                    selected: _selectedLocation,
                    onChanged: (value) => setState(() => _selectedLocation = value),
                  ),

                  // Special Requirements
                  TextField(
                    decoration: InputDecoration(
                      labelText: '📋 Any special requirements?',
                      hintText: 'e.g., vegetarian, outdoor seating, wifi...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _specialRequirements = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _getRecommendations(context);
                },
                child: Text('Find My Spot!'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String? selected,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                onChanged(selected ? option : null);
              },
              backgroundColor: isSelected ? Colors.purple.withOpacity(0.2) : null,
              selectedColor: Colors.purple.withOpacity(0.4),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
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

    // Show results
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Your Harare Matches'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(recommendations),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Perfect!'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFilterDialog(context); // Re-open filters to adjust
            },
            child: Text('Adjust Filters'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : () => _showFilterDialog(context),
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      icon: _isLoading
          ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white
          )
      )
          : Icon(Icons.auto_awesome),
      label: _isLoading ? Text('Finding matches...') : Text('AI Restaurant Guide'),
    );
  }
}