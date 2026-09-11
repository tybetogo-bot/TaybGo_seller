import '../../../../core/errors/failures.dart';
import '../../../../core/i18n/i18n.dart';

/// Returns a translated, user-safe explanation for a menu-item delete failure.
///
/// Backend details are intentionally not shown verbatim because they may be
/// returned in English even when the seller is using another language.
String menuDeleteFailureMessage(Failure? failure) {
  switch (failure?.statusCode) {
    case 409:
      return 'menu.deleteItemBlockedMessage'.tr;
    case 404:
      return 'menu.deleteItemNotFoundMessage'.tr;
    case 401:
    case 403:
      return 'menu.deleteItemPermissionMessage'.tr;
    case 408:
      return 'errors.timeout'.tr;
    default:
      if (failure is NetworkFailure) {
        return 'errors.network'.tr;
      }
      return 'errors.itemDeleteFailed'.tr;
  }
}

String menuDeleteFailureTitle(Failure? failure) {
  switch (failure?.statusCode) {
    case 409:
      return 'menu.deleteItemBlockedTitle'.tr;
    case 404:
      return 'menu.deleteItemNotFoundTitle'.tr;
    case 401:
    case 403:
      return 'menu.deleteItemPermissionTitle'.tr;
    default:
      return 'errors.itemDeleteFailedTitle'.tr;
  }
}

bool isMenuDeleteWarning(Failure? failure) => failure?.statusCode == 409;
