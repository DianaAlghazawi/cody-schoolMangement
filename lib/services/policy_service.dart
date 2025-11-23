import 'package:shared_preferences/shared_preferences.dart';

class PolicyService {
  static const String _privacyPolicyAcceptedKey = 'privacy_policy_accepted';
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _policyVersionKey = 'policy_version';
  static const String _currentPolicyVersion = '1.0';

  /// Check if user has accepted privacy policy and terms
  static Future<bool> hasAcceptedPolicies() async {
    final prefs = await SharedPreferences.getInstance();
    final privacyAccepted = prefs.getBool(_privacyPolicyAcceptedKey) ?? false;
    final termsAccepted = prefs.getBool(_termsAcceptedKey) ?? false;
    final savedVersion = prefs.getString(_policyVersionKey);

    // If policies were accepted with an older version, require re-acceptance
    if (savedVersion != _currentPolicyVersion) {
      return false;
    }

    return privacyAccepted && termsAccepted;
  }

  /// Accept privacy policy and terms of service
  static Future<void> acceptPolicies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyPolicyAcceptedKey, true);
    await prefs.setBool(_termsAcceptedKey, true);
    await prefs.setString(_policyVersionKey, _currentPolicyVersion);
  }

  /// Reset policy acceptance (for testing or if policies change)
  static Future<void> resetPolicyAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privacyPolicyAcceptedKey);
    await prefs.remove(_termsAcceptedKey);
    await prefs.remove(_policyVersionKey);
  }

  /// Get current policy version
  static String get currentVersion => _currentPolicyVersion;
}
