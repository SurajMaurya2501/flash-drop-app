import 'package:flash_drop_app/core/luxury_theme.dart';
import 'package:flash_drop_app/features/flash_drop/data/repositories/flash_drop_repository.dart';
import 'package:flash_drop_app/features/flash_drop/domain/use_cases/flash_drop_usecases.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_bloc.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/blocs/flash_drop_bloc/flash_drop_event.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/screens/flash_drop_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LuxuryFlashDropApp extends StatelessWidget {
  const LuxuryFlashDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
      theme: buildLuxuryTheme(),
      home: BlocProvider(
        create: (_) => FlashDropBloc(
          flashDropUsecases: FlashDropUsecases(FlashDropRepository()),
        )..add(FetchHistoryData()),
        child: const FlashDropMainScreen(),
      ),
    );
  }
}
