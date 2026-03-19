# Flash Drop App

Luxury-themed Flutter demo that simulates a limited-inventory flash drop with:

- historical bid data parsing on a background isolate,
- live quote updates on a periodic stream,
- BLoC-driven UI state transitions,
- and a hold-to-secure purchase interaction.

## Highlights

- Real-time quote simulation every 800 ms with bounded price movement and inventory decay.
- Large historical payload generation (50,000 points), then downsampling for chart rendering.
- Isolate-based JSON parse/downsample flow to protect main-thread rendering.
- Purchase lifecycle states: idle -> verifying -> success.
- Custom dark luxury visual style and charting widgets.

## Tech Stack

- Flutter (Material 3)
- Dart SDK `^3.11.1`
- `flutter_bloc` for state orchestration
- `equatable` for state comparison

## Architecture

The project uses a feature-first layout with a clean split across presentation, domain, and data:

- presentation: screens, widgets, BLoC events/state/logic
- domain: entities, repository interface, use cases
- data: repository implementation and mock data sources

Key flow:

1. App starts and dispatches `FetchHistoryData`.
2. Repository loads and parses historical payload in `Isolate.run`.
3. BLoC emits loading -> success and subscribes to live stream updates.
4. Live updates append chart points and refresh inventory/price UI.
5. User hold action triggers verification and emits purchase success.

## Project Structure

```text
lib/
	app/
		flash_drop_app.dart
	core/
		luxury_theme.dart
	features/
		flash_drop/
			data/
				data_source/
				repositories/
			domain/
				entities/
				repositories/
				use_cases/
			presentation/
				blocs/
				screens/
				widgets/
```

## Prerequisites

- Flutter SDK installed and available on PATH
- A configured device/emulator for your target platform

Validate your setup:

```bash
flutter doctor
```

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

## Testing

Run all tests:

```bash
flutter test
```

## Build

Android release APK (split per ABI):

```bash
flutter build apk --release --split-per-abi
```

Expected output directory:

- `build/app/outputs/flutter-apk/`

Typical generated artifacts:

- `app-armeabi-v7a-release.apk`
- `app-arm64-v8a-release.apk`
- `app-x86_64-release.apk`

## Data and Environment Notes

- This project currently uses local mock sources only (no backend integration).
- Historical bids are generated in-memory and parsed from JSON payload text.
- Live market and inventory values are simulated with deterministic random seeds.

## Performance Notes

- Historical parse/downsample work is offloaded to a background isolate.
- Parsed history future is cached to avoid repeated heavy processing.
- Live chart points are capped (220 live points) to keep render/update cost bounded.

## Useful Commands

```bash
flutter analyze
flutter run
flutter build apk --release --split-per-abi
```
