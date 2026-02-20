# NetMirror

Flutter app showing movie data from TMDB using the same API style/endpoints as `vegamovies`.

## Run

Provide your TMDB key via `--dart-define`:

```bash
flutter run --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

For release builds:

```bash
flutter build apk --dart-define=TMDB_API_KEY=your_tmdb_api_key
```
