import 'dart:math';

class MockHistoricalBidsPayloadSource {
  Future<String> fetchMassivePayload() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final random = Random(17);
    final List<String> lines = <String>[];
    double value = 1580;
    final startEpochMs = DateTime.now()
        .subtract(const Duration(days: 6))
        .millisecondsSinceEpoch;

    for (int i = 0; i < 50000; i++) {
      final drift = (random.nextDouble() - 0.48) * 3.4;
      value = (value + drift).clamp(940.0, 2690.0);
      final epochMs = startEpochMs + (i * 5000);
      lines.add('{"t":$epochMs,"p":${value.toStringAsFixed(2)}}');
    }

    return '{"bids":[${lines.join(',')}]}';
  }
}
