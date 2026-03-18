import 'dart:async';
import 'dart:math';

import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';

class MockLiveStreamDataSource {
  Stream<FlashDropEntity> connectLiveQuoteStream() {
    final random = Random(99);
    double livePrice = 1635.4;
    int inventory = 187;

    return Stream<FlashDropEntity>.periodic(const Duration(milliseconds: 800), (
      _,
    ) {
      final swing = (random.nextDouble() - 0.5) * 21.0;
      livePrice = (livePrice + swing).clamp(980.0, 2890.0);
      final dropOff = random.nextInt(4);
      inventory = max(0, inventory - dropOff);
      return FlashDropEntity(
        currentPrice: double.parse(livePrice.toStringAsFixed(2)),
        remainingInventory: inventory,
        tickEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
    }).asBroadcastStream();
  }
}
