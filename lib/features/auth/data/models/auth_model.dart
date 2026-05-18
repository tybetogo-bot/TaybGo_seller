/// Auth models for API requests and responses
/// Simple data classes without code generation for better compatibility
library;

import '../../../../core/config/constants.dart';

// ============================================================================
// OTP Request Models
// ============================================================================

/// OTP request model - POST /api/auth/otp/request/
class OtpRequest {
  final String phone;
  final String targetRole;

  const OtpRequest({required this.phone, this.targetRole = UserRoles.seller});

  Map<String, dynamic> toJson() => {'phone': phone, 'target_role': targetRole};
}

/// OTP request response
class OtpRequestResponse {
  final String detail;
  final String? otp; // Only returned in dev/test environments

  const OtpRequestResponse({required this.detail, this.otp});

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      detail: json['detail'] as String,
      otp: json['otp'] as String?,
    );
  }
}

// ============================================================================
// OTP Verify Models
// ============================================================================

/// OTP verify request model - POST /api/auth/otp/verify/
class OtpVerifyRequest {
  final String phone;
  final String code;
  final String targetRole;

  const OtpVerifyRequest({
    required this.phone,
    required this.code,
    this.targetRole = UserRoles.seller,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'code': code,
    'target_role': targetRole,
  };
}

/// OTP verify response - returns JWT tokens
class OtpVerifyResponse {
  final String access;
  final String refresh;

  const OtpVerifyResponse({required this.access, required this.refresh});

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }
}

// ============================================================================
// Token Refresh Models
// ============================================================================

/// Token refresh request model - POST /api/auth/token/refresh/
class TokenRefreshRequest {
  final String refresh;

  const TokenRefreshRequest({required this.refresh});

  Map<String, dynamic> toJson() => {'refresh': refresh};
}

/// Token refresh response
class TokenRefreshResponse {
  final String access;
  final String refresh;

  const TokenRefreshResponse({required this.access, required this.refresh});

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }
}

// ============================================================================
// Token Verify Models
// ============================================================================

/// Token verify request model - POST /api/auth/token/verify/
class TokenVerifyRequest {
  final String token;

  const TokenVerifyRequest({required this.token});

  Map<String, dynamic> toJson() => {'token': token};
}

// ============================================================================
// Token Blacklist Models (Logout)
// ============================================================================

/// Token blacklist request model - POST /api/auth/token/blacklist/
class TokenBlacklistRequest {
  final String refresh;

  const TokenBlacklistRequest({required this.refresh});

  Map<String, dynamic> toJson() => {'refresh': refresh};
}

// ============================================================================
// Local Auth Storage Models
// ============================================================================

/// Auth tokens model for local storage
class AuthTokens {
  final String access;
  final String refresh;
  final DateTime? expiresAt;

  const AuthTokens({
    required this.access,
    required this.refresh,
    this.expiresAt,
  });

  /// Check if token is expired
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Check if token needs refresh (expires within 5 minutes)
  bool get needsRefresh {
    if (expiresAt == null) return false;
    final threshold = DateTime.now().add(const Duration(minutes: 5));
    return expiresAt!.isBefore(threshold);
  }

  Map<String, dynamic> toJson() => {
    'access': access,
    'refresh': refresh,
    'expiresAt': expiresAt?.toIso8601String(),
  };

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  AuthTokens copyWith({String? access, String? refresh, DateTime? expiresAt}) {
    return AuthTokens(
      access: access ?? this.access,
      refresh: refresh ?? this.refresh,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
