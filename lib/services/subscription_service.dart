import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'device_id.dart';

class SubscriptionService {
  final _dio = Dio();

  Future<void> registerDevice() async {
    final id = await DeviceId.get();
    try {
      await _dio.post(
        '${html.window.location.origin}/api/user',
        data: {'device_id': id},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> restorePurchase() async {
    final id = await DeviceId.get();
    try {
      final response = await _dio.post(
        '${html.window.location.origin}/api/restore-purchase',
        data: {'device_id': id},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isPremium() async {
    final id = await DeviceId.get();
    try {
      final response = await _dio.post(
        '${html.window.location.origin}/api/subscription/check',
        data: {'device_id': id},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data['is_premium'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> launchPayment({String plan = 'monthly'}) async {
    final id = await DeviceId.get();
    final response = await _dio.post(
      '${html.window.location.origin}/api/subscribe',
      data: {'device_id': id, 'plan': plan},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    final data = response.data['data'] as String;
    final signature = response.data['signature'] as String;

    // POST form to LiqPay hosted checkout (opens in new tab)
    final form = html.FormElement()
      ..method = 'POST'
      ..action = 'https://www.liqpay.ua/api/3/checkout'
      ..target = '_blank';

    form.append(html.InputElement()
      ..type = 'hidden'
      ..name = 'data'
      ..value = data);

    form.append(html.InputElement()
      ..type = 'hidden'
      ..name = 'signature'
      ..value = signature);

    html.document.body?.append(form);
    form.submit();
    form.remove();
  }
}
