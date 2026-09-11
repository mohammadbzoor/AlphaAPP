import 'package:shared_preferences/shared_preferences.dart';

class RatingService {
  static const String _featureUsageKey = 'feature_usage_count';
  static const String _hasRatedKey = 'has_rated';
  static const String _lastRatingPromptKey = 'last_rating_prompt';
  static const String _sessionFeaturesKey = 'session_features';

  // Track feature usage in current session
  static Set<String> _sessionFeatures = {};

  /// Track when a user uses a feature
  static Future<void> trackFeatureUsage(String featureName) async {
    _sessionFeatures.add(featureName);
    print('📊 RatingService: Tracked feature "$featureName"');
    print('📊 RatingService: Session features: $_sessionFeatures');

    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_featureUsageKey) ?? 0;
    await prefs.setInt(_featureUsageKey, currentCount + 1);

    // Store current session features
    await prefs.setStringList(_sessionFeaturesKey, _sessionFeatures.toList());
    print('📊 RatingService: Total feature usage count: ${currentCount + 1}');
  }

  /// Check if user should see rating prompt
  static Future<bool> shouldShowRatingPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    // Don't show if user has already rated
    final hasRated = prefs.getBool(_hasRatedKey) ?? false;
    print('📋 RatingService: Has rated: $hasRated');
    if (hasRated) {
      print('❌ RatingService: User already rated, not showing prompt');
      return false;
    }

    // Check if user has used exactly one feature in this session
    final sessionFeatures = prefs.getStringList(_sessionFeaturesKey) ?? [];
    print(
        '📋 RatingService: Session features: $sessionFeatures (count: ${sessionFeatures.length})');
    if (sessionFeatures.length != 1) {
      print('❌ RatingService: Not exactly 1 feature used, not showing prompt');
      return false;
    }

    // Check if we haven't prompted recently (avoid spam)
    final lastPrompt = prefs.getInt(_lastRatingPromptKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const dayInMs = 24 * 60 * 60 * 1000; // 24 hours

    print(
        '📋 RatingService: Last prompt: $lastPrompt, Now: $now, Diff: ${now - lastPrompt}ms');
    if (now - lastPrompt < dayInMs) {
      print('❌ RatingService: Prompted too recently, not showing prompt');
      return false;
    }

    print('✅ RatingService: All conditions met, should show rating prompt');
    return true;
  }

  /// Mark that user has been prompted for rating
  static Future<void> markRatingPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _lastRatingPromptKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Mark that user has submitted a rating
  static Future<void> markUserRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
  }

  /// Clear session data (call when user starts a new session)
  static Future<void> clearSession() async {
    _sessionFeatures.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionFeaturesKey);
  }

  /// Reset rating data (for testing purposes)
  static Future<void> resetRatingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasRatedKey);
    await prefs.remove(_lastRatingPromptKey);
    await prefs.remove(_sessionFeaturesKey);
    _sessionFeatures.clear();
  }
}
