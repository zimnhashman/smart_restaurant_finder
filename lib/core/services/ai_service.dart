import 'package:firebase_ai/firebase_ai.dart';

class SimpleAIService {
  static final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
  );

  static Future<String> getRestaurantRecommendations({
    String? mood,
    String? budget,
    String? cuisine,
    String? noiseLevel,
    String? location,
    String? specialRequirements,
  }) async {
    try {
      final prompt = '''
      You are a restaurant recommendation AI for Harare, Zimbabwe.
      Based on the user's preferences, recommend 3 restaurants in Harare and provide match scores.
      
      User Preferences:
      ${mood != null ? "🎭 Mood: $mood" : ""}
      ${budget != null ? "💰 Budget: $budget" : ""}
      ${cuisine != null ? "🍽️ Cuisine: $cuisine" : ""}
      ${noiseLevel != null ? "🔊 Noise Level: $noiseLevel" : ""}
      ${location != null ? "📍 Location: $location" : ""}
      ${specialRequirements != null ? "📋 Special Requirements: $specialRequirements" : ""}
      
      Consider popular Harare restaurants like: Nandos, Papachinos, The Bistro, Gava's Restaurant, 
      Victoria 22, Sam Levy's Village eateries, Avondale restaurants, Borrowdale food places.
      
      Format your response EXACTLY like this:
      
      🏆 **AI Restaurant Recommendations for Harare**
      
      ⭐ **Top Match** ⭐
      🏅 **Match Score: 95%**
      **1. [Restaurant Name]**
      💰 *Budget:* [Budget range]
      🎭 *Vibe:* [Mood/atmosphere]
      🍽️ *Cuisine:* [Food type]
      🔊 *Noise:* [Noise level]
      📍 *Location:* [Area in Harare]
      💡 *Why it matches:* [Brief explanation of why it fits preferences]
      
      🥈 **Great Alternative**
      🏅 **Match Score: 85%**
      **2. [Restaurant Name]**
      💰 *Budget:* [Budget range]
      🎭 *Vibe:* [Mood/atmosphere]
      🍽️ *Cuisine:* [Food type]
      🔊 *Noise:* [Noise level]
      📍 *Location:* [Area in Harare]
      💡 *Why it matches:* [Brief explanation]
      
      🥉 **Good Option**
      🏅 **Match Score: 75%**
      **3. [Restaurant Name]**
      💰 *Budget:* [Budget range]
      🎭 *Vibe:* [Mood/atmosphere]
      🍽️ *Cuisine:* [Food type]
      🔊 *Noise:* [Noise level]
      📍 *Location:* [Area in Harare]
      💡 *Why it matches:* [Brief explanation]
      
      💭 *Based on your preferences in Harare, these spots should be perfect!*
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Let me find the perfect Harare restaurant for you!';
    } catch (e) {
      // Just return a message. The UI will decide to show a WhatsApp button.
      return 'I\'m having trouble connecting. Please try again or tap the WhatsApp button to reach us!';
    }
  }
}
