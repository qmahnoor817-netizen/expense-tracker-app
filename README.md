# Expense Tracker App

A Flutter mobile application to track daily income and expenses with local storage.

## Core Features
- **Add/Edit/Delete Transactions**: Full CRUD operations with Hive local database
- **Income vs Expense Tracking**: Toggle between income and expense entries
- **Category-wise Tracking**: Food, Transport, Bills, Shopping, Others
- **Charts & Analytics**: Visualize spending by category using FL Chart
- **Date Filtering**: Filter transactions by date range
- **Offline First**: All data stored locally on device using Hive. No internet required
- **Date & Currency Formatting**: Clean display using `intl` package

## Tech Stack & Packages Used

| Package | Purpose |
| --- | --- |
| `hive: ^2.2.3` | Lightweight NoSQL database for local storage |
| `hive_flutter: ^1.1.0` | Hive integration with Flutter |
| `path_provider: ^2.1.3` | Get device directories to store Hive box |
| `intl: ^0.19.0` | Date and currency formatting |
| `fl_chart: ^0.66.0` | Pie charts for expense analytics |
| `cupertino_icons: ^1.0.8` | iOS style icons |

## Architecture & State Management
- **Architecture**: MVVM (Model-View-ViewModel) pattern
    - **Model**: `TransactionModel` with Hive annotations for local storage
    - **View**: Screens like `home_screen.dart`, `add_screen.dart`, `chart_screen.dart`
    - **ViewModel**: State classes handle business logic and Hive box operations
- **State Management**: `setState` for UI updates + `ValueListenableBuilder` to listen to Hive box changes for real-time UI.

## Local Storage Solutions
- **Hive Database**: Primary storage. All transactions stored locally in Hive boxes. Fast and works offline.
- **Path Provider**: Used to get application documents directory for Hive initialization.
- **No Cloud Database**: App is 100% offline. Data persists on device only.
- **Build Runner + Hive Generator**: Used to generate `transaction_model.g.dart` for Hive TypeAdapter.

