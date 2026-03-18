import 'dart:convert';
import 'dart:isolate';
import 'package:flash_drop_app/features/flash_drop/data/data_source/mock_historical_bids_payload_source.dart';
import 'package:flash_drop_app/features/flash_drop/data/data_source/mock_live_stream_datasource.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';
import 'package:flash_drop_app/features/flash_drop/domain/repositories/flash_drop_repository_interface.dart';

class FlashDropRepository implements FlashDropRepositoryInterface {
  final mockData = MockHistoricalBidsPayloadSource();
  final mockStreamData = MockLiveStreamDataSource();

  List<HistoricalBidPoint> parseHistoricalBidData({required String payload}) {
    final decodeData = jsonDecode(payload);
    List<dynamic> bids = decodeData['bids'];
    const chartTargetPoints = 900;
    int stride = (bids.length / chartTargetPoints).ceil().clamp(1, bids.length);
    List<dynamic> sampleData = [];
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
        .toList();
  }

  @override
  Future<List<HistoricalBidPoint>> getHistoricalData() async {
    final isolateData = await Isolate.run(() async {
      final data = await mockData.fetchMassivePayload();
      return parseHistoricalBidData(payload: data);
    });
    return isolateData;
  }

  @override
  Stream<FlashDropEntity> streamLiveFlashDropData() {
    return mockStreamData.connectLiveQuoteStream().map(
      (model) => model.toEntity(),
    );
  }
}
