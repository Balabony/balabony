import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_service.dart';

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, bool>(SubscriptionNotifier.new);

class SubscriptionNotifier extends AsyncNotifier<bool> {
  late final _service = SubscriptionService();

  @override
  Future<bool> build() => _service.isPremium();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.isPremium);
  }
}
