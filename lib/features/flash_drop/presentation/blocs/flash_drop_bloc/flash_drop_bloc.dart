import 'dart:async';
import 'package:flash_drop_app/features/flash_drop/domain/entities/flash_drop_entity.dart';
import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';
import 'package:flash_drop_app/features/flash_drop/domain/use_cases/flash_drop_usecases.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_event.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlashDropBloc extends Bloc<FlashDropEvent, FlashDropState> {
  final FlashDropUsecases flashDropUsecases;
  StreamSubscription<FlashDropEntity>? _liveSubscription;

  FlashDropBloc({required this.flashDropUsecases})
    : super(FlashDropState.initial()) {
    on<FetchHistoryData>(_onFetchHistoryData);
    on<FetchLiveData>(_onFetchLiveData);
    on<LuxuryPurchaseRequested>(_onPurchaseRequested);
    on<LuxuryPurchaseVerificationCompleted>(_onPurchaseVerificationCompleted);
  }

  FutureOr<void> _onFetchHistoryData(
    FetchHistoryData event,
    Emitter<FlashDropState> emit,
  ) async {
    if (state.status == FlashDropStatus.loading || state.historyData != null) {
      return;
    }

    bool isSoldOut = false;

    try {
      emit(state.copyWith(status: FlashDropStatus.loading));
      final historyData = await flashDropUsecases.getFlashDropHistoricalData();
      emit(
        state.copyWith(status: FlashDropStatus.success, history: historyData),
      );
      _liveSubscription?.cancel();
      _liveSubscription = flashDropUsecases.getFlashDropStreamData().listen((
        event,
      ) {
        if (!isSoldOut) {
          isSoldOut = event.remainingInventory == 0;
          add(FetchLiveData(flashDropEntity: event));
        } else {
          _liveSubscription!.pause();
        }
      });
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashDropStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onFetchLiveData(FetchLiveData event, Emitter<FlashDropState> emit) {
    final livePoints = <HistoricalBidPoint>[
      ...state.liveSeries,
      HistoricalBidPoint(
        epochMs: event.flashDropEntity.tickEpochMs,
        price: event.flashDropEntity.currentPrice,
      ),
    ];

    final cappedLivePoints = livePoints.length > 220
        ? livePoints.sublist(livePoints.length - 220)
        : livePoints;

    emit(
      state.copyWith(
        flashDropEntity: event.flashDropEntity,
        liveData: cappedLivePoints,
      ),
    );
  }

  Future<void> _onPurchaseRequested(
    LuxuryPurchaseRequested event,
    Emitter<FlashDropState> emit,
  ) async {
    if (!state.canSecureItem) {
      return;
    }

    emit(state.copyWith(purchaseStatus: PurchaseLifecycleStatus.verifying));

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    add(LuxuryPurchaseVerificationCompleted());
  }

  void _onPurchaseVerificationCompleted(
    LuxuryPurchaseVerificationCompleted event,
    Emitter<FlashDropState> emit,
  ) {
    emit(state.copyWith(purchaseStatus: PurchaseLifecycleStatus.success));
  }

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    return super.close();
  }
}
