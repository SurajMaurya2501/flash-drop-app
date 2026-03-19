import 'dart:convert';
import 'dart:isolate';
import 'package:flash_drop_app/features/flash_drop/data/data_source/mock_historical_bids_payload_source.dart';
import 'package:flash_drop_app/features/flash_drop/data/data_source/mock_live_stream_datasource.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';
import 'package:flash_drop_app/features/flash_drop/domain/repositories/flash_drop_repository_interface.dart';

class FlashDropRepository implements FlashDropRepositoryInterface {
  final mockStreamData = MockLiveStreamDataSource();
  Future<List<HistoricalBidPoint>>? _historicalDataFuture;

  @override
  Future<List<HistoricalBidPoint>> getHistoricalData() async {
    _historicalDataFuture ??= Isolate.run(() async {
      final data = await MockHistoricalBidsPayloadSource()
          .fetchMassivePayload();
      return _parseHistoricalBidData(payload: data);
    });
    return _historicalDataFuture!;
  }

  @override
  Stream<FlashDropEntity> streamLiveFlashDropData() {
    return mockStreamData.connectLiveQuoteStream();
  }
}

List<HistoricalBidPoint> _parseHistoricalBidData({required String payload}) {
  final decodeData = jsonDecode(payload);
  final bids = decodeData['bids'] as List<dynamic>;
  const chartTargetPoints = 900;
  final stride = (bids.length / chartTargetPoints).ceil().clamp(1, bids.length);

  final sampleData = <dynamic>[];
  for (int i = 0; i < bids.length; i += stride) {
    sampleData.add(bids[i]);
  }

  if (sampleData.isNotEmpty && sampleData.last != bids.last) {
    sampleData.add(bids.last);
  }

  return sampleData
      .map(
        (e) => HistoricalBidPoint(
          epochMs: int.parse(e['t'].toString()),
          price: double.parse((e['p'] ?? '0.0').toString()),
        ),
      )
      .toList(growable: false);
}
