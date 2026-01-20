import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item_model.freezed.dart';

/// Helper function to parse ingredients from API response
/// Handles both string (comma-separated) and array formats
List<String> _parseIngredients(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return List<String>.from(value);
  }
  if (value is String && value.isNotEmpty) {
    return value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
  return [];
}

/// Customization type for menu items
enum CustomizationType {
  @JsonValue('addition')
  addition,
  @JsonValue('removal')
  removal,
}

/// Customization option for a menu item
@freezed
sealed class CustomizationOption with _$CustomizationOption {
  const factory CustomizationOption({
    required String id,
    required String name,
    required CustomizationType type,
    @Default(0.0) double priceModifier,
    @Default(true) bool isAvailable,
  }) = _CustomizationOption;

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] == 'removal'
          ? CustomizationType.removal
          : CustomizationType.addition,
      priceModifier:
          double.tryParse(
            (json['price_modifier'] ?? json['priceModifier'] ?? '0').toString(),
          ) ??
          0.0,
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
    );
  }
}

/// Category model for menu organization
@freezed
sealed class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    String? nameAr,
    String? nameDe,
    String? nameFr,
    String? imageUrl,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      nameDe: json['name_de'] as String?,
      nameFr: json['name_fr'] as String?,
      imageUrl: (json['image'] ?? json['image_url'] ?? json['imageUrl']) as String?,
      sortOrder: (json['sort_order'] ?? json['sortOrder'] ?? 0) as int,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }
}

/// Extension for CategoryModel to get localized name
extension CategoryModelExtension on CategoryModel {
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return nameAr ?? name;
      case 'de':
        return nameDe ?? name;
      case 'fr':
        return nameFr ?? name;
      default:
        return name;
    }
  }
}

/// Main menu item model
@freezed
sealed class MenuItemModel with _$MenuItemModel {
  const factory MenuItemModel({
    required String id,
    required String name,
    required double price,
    String? imageUrl,
    String? description,
    required String categoryId,
    @Default([]) List<String> ingredients,
    @Default([]) List<CustomizationOption> customizations,
    @Default(true) bool isAvailable,
    @Default(0) int preparationTime,
    String? nameAr,
    String? nameDe,
    String? nameFr,
    String? descriptionAr,
    String? descriptionDe,
    String? descriptionFr,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MenuItemModel;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: (json['image'] ?? json['image_url'] ?? json['imageUrl']) as String?,
      description: json['description'] as String?,
      categoryId:
          (json['category_id'] ?? json['categoryId'] ?? json['category'])
              ?.toString() ??
          '',
      ingredients: _parseIngredients(json['ingredients']),
      customizations:
          json['customizations'] != null && json['customizations'] is List
          ? (json['customizations'] as List)
                .map(
                  (c) =>
                      CustomizationOption.fromJson(c as Map<String, dynamic>),
                )
                .toList()
          : [],
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
      preparationTime:
          int.tryParse(
            json['preparation_time']?.toString() ??
                json['preparationTime']?.toString() ??
                '0',
          ) ??
          0,
      nameAr: json['name_ar'] as String?,
      nameDe: json['name_de'] as String?,
      nameFr: json['name_fr'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionDe: json['description_de'] as String?,
      descriptionFr: json['description_fr'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

/// Extension for MenuItemModel with utility methods
extension MenuItemModelExtension on MenuItemModel {
  /// Get localized name
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return nameAr ?? name;
      case 'de':
        return nameDe ?? name;
      case 'fr':
        return nameFr ?? name;
      default:
        return name;
    }
  }

  /// Get localized description
  String? getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return descriptionAr ?? description;
      case 'de':
        return descriptionDe ?? description;
      case 'fr':
        return descriptionFr ?? description;
      default:
        return description;
    }
  }

  /// Get additions (customizations that add ingredients)
  List<CustomizationOption> get additions => customizations
      .where((c) => c.type == CustomizationType.addition)
      .toList();

  /// Get removals (ingredients that can be removed)
  List<CustomizationOption> get removals =>
      customizations.where((c) => c.type == CustomizationType.removal).toList();

  /// Check if item has any customizations
  bool get hasCustomizations => customizations.isNotEmpty;

  /// Get formatted ingredients string
  String get ingredientsText => ingredients.join(', ');
}
