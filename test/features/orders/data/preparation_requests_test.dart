import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/network/orders_api.dart';
import 'package:teybatseller/features/orders/data/models/order_model.dart';

void main() {
  late OrdersApi api;
  late List<RequestOptions> requests;

  setUp(() {
    requests = [];
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request);
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 200,
              data: {
                'id': '42',
                'items': <dynamic>[],
                'created_at': '2026-09-16T12:00:00Z',
              },
            ),
          );
        },
      ),
    );
    api = OrdersApi(dio);
  });

  test(
    'accept sends preparation duration and never a derived legacy delay',
    () async {
      await api.acceptOrder('42', preparationTimeMinutes: 15);
      expect(requests.first.data, {'preparation_time_minutes': 15});
      expect(requests.last.method, 'GET');
    },
  );

  test('older server acceptance retains the legacy request', () async {
    await api.acceptOrder('42', driverDispatchDelayMinutes: 15);
    expect(requests.first.data, {'driver_dispatch_delay_minutes': 15});
  });

  test(
    'zero-minute preparation reschedule stays a reschedule and is not retried',
    () async {
      await api.driverDispatch(
        '42',
        action: DriverDispatchAction.reschedule,
        preparationTimeMinutes: 0,
      );
      expect(requests.first.data, {
        'action': 'RESCHEDULE',
        'preparation_time_minutes': 0,
      });
      expect(requests.first.extra['disableRetry'], isTrue);
    },
  );

  test('request now leaves preparation timing out of the request', () async {
    await api.driverDispatch('42', action: DriverDispatchAction.requestNow);
    expect(requests.first.data, {'action': 'REQUEST_NOW'});
  });

  test('conflicting timing fields fail before any request', () async {
    await expectLater(
      api.acceptOrder(
        '42',
        preparationTimeMinutes: 15,
        driverDispatchDelayMinutes: 10,
      ),
      throwsArgumentError,
    );
    expect(requests, isEmpty);
  });

  test('request now cannot silently discard a preparation edit', () async {
    await expectLater(
      api.driverDispatch(
        '42',
        action: DriverDispatchAction.requestNow,
        preparationTimeMinutes: 0,
      ),
      throwsArgumentError,
    );
    expect(requests, isEmpty);
  });
}
