/// Cloudinary configuration for image uploads
library;

class CloudinaryConfig {
  CloudinaryConfig._();

  // Cloudinary credentials
  static const String cloudName = 'djkufgvvm';
  static const String apiKey = '355424166538455';
  static const String uploadPreset = 'typetogo';

  // API endpoints
  static const String uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  // Upload settings
  static const int maxRetries = 1;
}
