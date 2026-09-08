# FitTrack

FitTrack is a fitness and workout tracking application developed as an individual university project using Flutter and Dart.

## Features

- User profile with personal information
- Exercise catalog
- Exercise search and filtering
- Create and delete workouts
- Add exercises to workouts
- Active workout tracking
- Record weight and repetitions for each set
- Mark completed sets
- Workout history
- Personal records (PRs)
- Daily workout statistics
- Daily training volume chart
- Average training volume per workout
- Local data persistence using SQLite
- Exercise data integration through a REST API

## Technologies

- **Flutter** - application framework
- **Dart** - programming language
- **SQLite** - local database
- **Provider** - state management
- **REST API** - exercise data
- **HTTP** - API communication
- **fl_chart** - statistics and charts
- **sqflite / sqflite_common_ffi** - SQLite integration

## Architecture

The project is organized into separate layers to keep the application logic, data access and user interface independent from each other.

```text
lib/
├── main.dart
├── models/
│   ├── exercise.dart
│   ├── workout.dart
│   └── workout_set.dart
├── screens/
│   ├── home/
│   ├── workouts/
│   ├── exercises/
│   ├── statistics/
│   └── profile/
├── widgets/
├── services/
│   ├── database_service.dart
│   └── exercise_api_service.dart
├── repositories/
│   ├── exercise_repository.dart
│   └── workout_repository.dart
└── providers/
    ├── exercise_provider.dart
    └── workout_provider.dart
```


## Data Storage

FitTrack uses a local SQLite database for persistent application data.

The database stores:

- User profile information
- Exercises
- Workouts
- Exercises belonging to workouts
- Workout sets
- Weight, repetitions and completion status

The data remains available after restarting the application.

## REST API

Exercise information can be loaded from an external REST API. The API integration is separated into its own service and repository so that external data access does not directly depend on the user interface.

The application also contains a local exercise catalog, allowing the core application to continue functioning with locally stored exercise data.

## Statistics

FitTrack provides a statistics dashboard based on recorded workout data.

The dashboard includes:

- Number of workouts
- Number of sets
- Daily training volume
- Average volume per workout
- All-time training volume
- Personal records

Daily training volume is calculated from the recorded sets using:

```text
volume = weight × repetitions
```

The statistics chart displays the training volume for the most recent days and uses actual calendar dates on the chart.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Windows desktop support enabled in Flutter

### Installation

Clone the repository:

```bash
git clone https://github.com/ivantf2/FinTrack.git
cd fittrack
```

Install the project dependencies:

```bash
flutter pub get
```

Run the application on Windows:

```bash
flutter run -d windows
```

## Project Structure

The main application code is located in the `lib` directory.

The project intentionally separates UI components, state management, data models and data access to make the code easier to maintain and extend.
