import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_bloc.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_event.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_state.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/hold_to_secure_button.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/inventory_pill.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/luxury_live_chart.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/luxury_price_ticker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlashDropMainScreen extends StatelessWidget {
  const FlashDropMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF0A0D12),
              Color(0xFF111A26),
              Color(0xFF090C12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<FlashDropBloc, FlashDropState>(
            builder: (context, state) {
              if (state.status == FlashDropStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFE4C685),
                    ),
                  ),
                );
              } else if (state.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                );
              }

              final activeQuote = state.flashDropEntity;
              final fallbackPrice = (state.historyData ?? []).isNotEmpty
                  ? state.historyData?.last.price
                  : 0.0;
              final currentPrice = activeQuote?.currentPrice ?? fallbackPrice;
              final previousPrice = (state.liveSeries).length > 1
                  ? (state.liveSeries)[(state.liveSeries).length - 2].price
                  : fallbackPrice;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed(<Widget>[
                        Text(
                          'Prime Drop',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Flash allotment closes when inventory reaches zero.',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: const Color(0xFFC2CBD9)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: <Widget>[
                            RepaintBoundary(
                              child: LuxuryPriceTicker(
                                price: currentPrice ?? 0.0,
                                previousPrice: previousPrice,
                              ),
                            ),
                            const Spacer(),
                            InventoryPill(
                              inventory: activeQuote?.remainingInventory ?? 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 300,
                          child: LuxuryLiveChart(
                            historicalSeries: state.historyData ?? [],
                            liveSeries: state.liveSeries,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          'Limited release note',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(color: const Color(0xFFE2BF86)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Each secure action reserves one serialized piece while our inventory verifier confirms your slot in real time.',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                height: 1.45,
                                color: const Color(0xFFC4CDDD),
                              ),
                        ),
                        const SizedBox(height: 28),
                        HoldToSecureButton(
                          purchaseStatus: state.purchaseStatus,
                          enabled: state.canSecureItem,
                          onHoldCompleted: () {
                            context.read<FlashDropBloc>().add(
                              LuxuryPurchaseRequested(),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
