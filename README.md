# Mobile Apps Workspace

This repository contains multiple Flutter apps.

## Projects

### 1. calc_note
CalcNote-style notepad calculator with:
- live per-line results
- variable assignments and expression evaluation
- desktop keyboard support and shortcuts
- foldable left sidebar (New, Open, Save, Save as, Help, Quit)

Path: `calc_note/`

### 2. netmirror
Netflix-style movie browsing UI powered by TMDB API.

Path: `netmirror/`

### 3. whatsapp_saver
Status saver app for WhatsApp / WhatsApp Business statuses.

Path: `whatsapp_saver/`

## Common setup

Use Flutter stable and run per project:

```bash
cd <project_folder>
flutter pub get
flutter run
```

For static checks:

```bash
flutter analyze
flutter test
```
