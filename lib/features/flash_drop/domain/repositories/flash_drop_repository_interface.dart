import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';

abstract class FlashDropRepositoryInterface {
  Future<List<HistoricalBidPoint>> getHistoricalData();
  Stream<FlashDropEntity> streamLiveFlashDropData();
}
