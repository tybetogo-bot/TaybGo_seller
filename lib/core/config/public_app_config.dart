/// Runtime configuration returned by the anonymous public config endpoint.
class PublicAppConfig {
  const PublicAppConfig({
    required this.otpEnabledRoles,
    required this.passwordOnlyRoles,
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.forceUpdate,
    required this.updateUrl,
    required this.privacyUrl,
    required this.termsUrl,
    required this.supportUrl,
  });

  final List<String> otpEnabledRoles;
  final List<String> passwordOnlyRoles;
  final String latestVersion;
  final String minSupportedVersion;
  final bool forceUpdate;
  final String? updateUrl;
  final String privacyUrl;
  final String termsUrl;
  final String supportUrl;

  factory PublicAppConfig.fromJson(Map<String, dynamic> json) {
    return PublicAppConfig(
      otpEnabledRoles: _stringList(json['auth.otp_enabled_roles']),
      passwordOnlyRoles: _stringList(json['auth.password_only_roles']),
      latestVersion: _requiredString(json, 'app.latest_version'),
      minSupportedVersion: _requiredString(json, 'app.min_supported_version'),
      forceUpdate: json['app.force_update'] == true,
      updateUrl: _nullableString(json['app.update_url']),
      privacyUrl: _requiredString(json, 'legal.privacy_url'),
      termsUrl: _requiredString(json, 'legal.terms_url'),
      supportUrl: _requiredString(json, 'legal.support_url'),
    );
  }

  bool usesOtpFor(String role) =>
      otpEnabledRoles.contains(role) && !passwordOnlyRoles.contains(role);

  bool usesPasswordFor(String role) => passwordOnlyRoles.contains(role);

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = _nullableString(json[key]);
    if (value == null) {
      throw FormatException('Missing or invalid public config value: $key');
    }
    return value;
  }

  static String? _nullableString(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
