# Backend API Integration - Authentication

## Overview
The authentication system is now fully configured and ready to connect to your backend API.

## ✅ What's Been Set Up

### 1. **Core Network Infrastructure**
- **API Client** ([lib/core/network/api_client.dart](lib/core/network/api_client.dart))
  - Dio instance configured with base URL from `AppConfig`
  - Automatic timeout handling (30 seconds)
  - Pretty logging in development mode

- **Interceptors**
  - **Auth Interceptor**: Automatically adds Bearer token to all requests
  - **Error Interceptor**: Converts API errors to user-friendly messages
  - **Token Refresh**: Ready for automatic token refresh on 401 errors

### 2. **Error Handling**
- **Custom Exceptions** ([lib/core/errors/exceptions.dart](lib/core/errors/exceptions.dart))
  - `ApiException` - Base exception
  - `UnauthorizedException` - 401 errors
  - `ValidationException` - 422 errors with field validation
  - `NetworkException` - Connection issues
  - `ServerException` - 500+ errors

- **Failure Classes** ([lib/core/errors/failures.dart](lib/core/errors/failures.dart))
  - Clean separation of concerns
  - Used in the application layer

### 3. **Authentication Data Layer**

#### API Service ([lib/core/network/auth_api.dart](lib/core/network/auth_api.dart))
```dart
@RestApi()
abstract class AuthApi {
  Future<OtpResponse> requestOtp(@Body() OtpRequest request);
  Future<AuthResponse> verifyOtp(@Body() OtpVerification verification);
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);
  Future<void> logout();
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(@Body() Map<String, dynamic> data);
}
```

#### Data Source ([lib/features/auth/data/datasources/](lib/features/auth/data/datasources/))
- Interface-based design for testability
- Remote implementation using Retrofit

#### Repository ([lib/features/auth/data/repositories/auth_repository.dart](lib/features/auth/data/repositories/auth_repository.dart))
- Clean error handling with Result pattern
- Automatic token storage
- User data caching in SharedPreferences

### 4. **State Management**
- **AuthNotifier** now uses real repository instead of mocks
- Proper error propagation to UI
- OTP flow with verification ID support

### 5. **Dependency Injection**
All providers configured in [lib/core/providers/providers.dart](lib/core/providers/providers.dart):
```dart
sharedPreferencesProvider → dioProvider → authApiProvider → 
authDataSourceProvider → authRepositoryProvider → authProvider
```

## 📋 Backend Requirements

### Expected API Endpoints

#### 1. **Request OTP**
```http
POST /auth/verify-otp
Content-Type: application/json

{
  "phoneNumber": "512345678",
  "countryCode": "+966"
}

Response:
{
  "success": true,
  "message": "OTP sent successfully",
  "expiresInSeconds": 60,
  "verificationId": "optional-id-for-verification"
}
```

#### 2. **Verify OTP / Login**
```http
POST /auth/login
Content-Type: application/json

{
  "phoneNumber": "512345678",
  "countryCode": "+966",
  "otp": "123456",
  "verificationId": "optional-id"
}

Response:
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "refresh_token_here",
  "expiresIn": 3600,
  "user": {
    "id": "user_123",
    "phoneNumber": "512345678",
    "countryCode": "+966",
    "email": "vendor@example.com",
    "name": "Restaurant Owner",
    "restaurantId": "rest_123",
    "restaurantName": "My Restaurant",
    "role": "vendor",
    "profileImageUrl": "https://...",
    "isVerified": true,
    "createdAt": "2025-01-01T00:00:00Z",
    "lastLoginAt": "2025-01-13T00:00:00Z"
  }
}
```

#### 3. **Refresh Token**
```http
POST /auth/refresh
Content-Type: application/json
Authorization: Bearer {old_token}

{
  "refreshToken": "refresh_token_here"
}

Response: Same as login response
```

#### 4. **Logout**
```http
POST /auth/logout
Authorization: Bearer {access_token}

Response: 200 OK
```

#### 5. **Get Profile**
```http
GET /user/profile
Authorization: Bearer {access_token}

Response: User object (same structure as in login)
```

#### 6. **Update Profile**
```http
PUT /user/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "Updated Name",
  "email": "new@email.com"
}

Response: Updated user object
```

## 🔧 Configuration

### API Base URL
Update in [lib/core/config/app_config.dart](lib/core/config/app_config.dart):
```dart
static const String baseUrl = 'https://api.tybetogo.com/v1';
static const String stagingUrl = 'https://staging-api.tybetogo.com/v1';
```

### Environment Selection
Use build flags:
```bash
# Development (uses staging URL)
flutter run

# Staging
flutter run --dart-define=ENV=staging

# Production
flutter run --dart-define=ENV=production
```

## 🧪 Testing the Integration

### 1. Test OTP Request
```dart
final authNotifier = ref.read(authProvider.notifier);
await authNotifier.requestOtp(
  phoneNumber: '512345678',
  countryCode: '+966',
);
```

### 2. Test OTP Verification
```dart
await authNotifier.verifyOtp('123456');
```

### 3. Check Auth State
```dart
ref.listen(authProvider, (previous, next) {
  if (next is AuthAuthenticated) {
    print('Logged in: ${next.user.name}');
  } else if (next is AuthError) {
    print('Error: ${next.message}');
  }
});
```

## 🔒 Security Features

1. **Automatic Token Injection**: All authenticated requests include Bearer token
2. **Token Storage**: Secure storage in SharedPreferences
3. **Auto Token Refresh**: Infrastructure ready (needs implementation)
4. **Logout Cleanup**: Removes all auth data from storage

## 📝 Error Handling

Errors are automatically caught and converted to user-friendly messages:
- Network errors → "No internet connection"
- Timeout errors → "Connection timeout"
- 401 errors → Custom message from backend
- 422 validation errors → Field-specific errors
- 500+ errors → "Server error. Please try again later"

## 🚀 Next Steps

1. **Update API Base URL** to your actual backend URL
2. **Test with Real Backend**: Run the app and test login flow
3. **Implement Token Refresh Logic** in `AuthInterceptor`
4. **Add Firebase/Analytics** tracking for auth events
5. **Handle Edge Cases**:
   - Network connectivity checking
   - Offline mode
   - Session expiration handling

## 🛠️ Advanced Customization

### Custom Error Messages
Modify [lib/core/network/interceptors/error_interceptor.dart](lib/core/network/interceptors/error_interceptor.dart)

### Adding Request Headers
Modify [lib/core/network/api_client.dart](lib/core/network/api_client.dart)

### Change Token Storage
Modify [lib/features/auth/data/repositories/auth_repository.dart](lib/features/auth/data/repositories/auth_repository.dart) to use Hive or secure_storage

## ⚠️ Important Notes

1. **Token Refresh**: The infrastructure is ready but automatic refresh on 401 needs to be implemented in `AuthInterceptor`
2. **Error Messages**: Backend should return consistent error format:
   ```json
   {
     "message": "User-friendly error message",
     "errors": { // For validation errors only
       "fieldName": ["Error 1", "Error 2"]
     }
   }
   ```
3. **API Versioning**: Currently using `/v1` - update if your backend uses different versioning

## 📚 Architecture

```
UI Layer (Screens/Widgets)
    ↓
Application Layer (AuthNotifier + State)
    ↓
Repository Layer (AuthRepository)
    ↓
Data Source Layer (AuthRemoteDataSource)
    ↓
API Layer (Retrofit AuthApi)
    ↓
Network Layer (Dio + Interceptors)
    ↓
Backend API
```

---

Everything is ready! Just update the base URL and start testing with your backend. 🎉
