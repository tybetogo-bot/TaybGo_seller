import 'dart:js_interop';

@JS('clearSellerNotifications')
external JSPromise<JSAny?> _clearSellerNotifications();

Future<void> clearWebNotifications() async {
  await _clearSellerNotifications().toDart;
}
