import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';
import 'package:flash_drop_app/features/flash_drop/domain/repositories/flash_drop_repository_interface.dart';

class FlashDropUsecases {
  final FlashDropRepositoryInterface _repo;
  const FlashDropUsecases(this._repo);

  Future<List<HistoricalBidPoint>> getFlashDropHistoricalData() {
    return _repo.getHistoricalData();
  }

  Stream<FlashDropEntity> getFlashDropStreamData() {
    return _repo.streamLiveFlashDropData();
  }
}
