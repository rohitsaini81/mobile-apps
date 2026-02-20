# NetMirror

Netflix-like Flutter UI that fetches movie data from TMDB.

## Features

- home feed sections (discover, trending, popular, upcoming)
- hero banner
- movie search
- title preview/details flow

## Configuration

This app requires a TMDB API key passed at runtime.

## Run

```bash
flutter pub get
flutter run --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

## Build

```bash
flutter build apk --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

## Validate

```bash
flutter analyze
flutter test
```
