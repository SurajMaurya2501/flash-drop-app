# Architecture Notes

This app follows a feature-first structure with a lightweight clean-architecture style split (presentation -> domain -> data).

## State management choices

I used BLoC for screen-level state because this flow has a few moving parts that need coordination:

- initial historical data load,
- live stream updates,
- and purchase lifecycle states.

In this setup, the UI stays mostly declarative and dumb, while the orchestration logic lives in one place.

- `FlashDropBloc` owns the business flow.
- `FlashDropEvent` describes user/system intents.
- `FlashDropState` (with `Equatable`) is the single source of truth for rendering.

This keeps widget code simple and makes behavior easier to test and reason about over time.

## Isolate communication approach

Historical payload parsing is intentionally pushed off the main thread using `Isolate.run` inside the repository.

- The heavy JSON decode + downsampling work happens in a background isolate.
- The parsed result is returned as a `Future<List<HistoricalBidPoint>>`.
- The future is cached (`_historicalDataFuture`) so repeated requests do not spawn extra isolates.

I chose `Isolate.run` over compute because it simplifies the implementation by allowing the use of closures, making it easier to pass arguments without the 'single-parameter' restriction while effectively preventing UI jank during heavy processing..

For live updates, a normal Dart `Stream` is enough (no isolate needed) since each tick is tiny and periodic.

## Folder structure

Top-level app layout:

- `lib/app`: app wiring (theme, root `MaterialApp`, root `BlocProvider`).
- `lib/core`: shared cross-feature code (theme and common utilities).
- `lib/features/flash_drop`: feature module.

Inside `features/flash_drop`:

- `presentation/`: screens, widgets, and BLoC state management.
- `domain/`: entities, repository contracts, and use cases.
- `data/`: repository implementation and mock data sources.

This separation keeps dependencies one-directional:

- presentation depends on domain,
- data depends on domain,
- domain stays framework-light and reusable.