# CalcNote

A CalcNote-inspired notepad calculator built with Flutter.

## Features

- write calculations like notes (multi-line editor)
- instant line-by-line results
- variables (example: `total = 12*5 + shipping`)
- line references via `$<line_number>`
- scientific functions (`sin`, `cos`, `tan`, `sqrt`, `log`, `ln`, `abs`)
- two-page calculator keypad
- desktop keyboard editing with visible cursor
- shortcuts:
  - `Ctrl/Cmd + Enter`: evaluate current line and append result
  - `Esc`: clear current line
  - `Alt + Left/Right`: move cursor by word
- foldable slide sidebar menu:
  - New, Open, Save, Save as, Help, Quit

## Tech

- Flutter (Material 3)
- `file_selector` for Open/Save dialogs

## Run

```bash
flutter pub get
flutter run
```

## Validate

```bash
flutter analyze
flutter test
```
