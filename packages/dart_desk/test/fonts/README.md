# Test Fonts (Phase 4a — deferred)

Drop these TTF files here from Google Fonts before running goldens locally.
The `flutter_test_config.dart` auto-registers any `.ttf`/`.otf` in this
directory, so goldens will render with real typefaces once these files are
present.

## Required files

These font faces are used by `AuraEnums` headline/body designations:

### Headline faces
- `NotoSerif-Regular.ttf`
- `NotoSerif-Bold.ttf`
- `PlayfairDisplay-Regular.ttf`
- `PlayfairDisplay-Bold.ttf`
- `CormorantGaramond-Regular.ttf`
- `CormorantGaramond-Bold.ttf`
- `DMSerifDisplay-Regular.ttf`

### Body faces
- `Manrope-Regular.ttf`
- `Manrope-Bold.ttf`
- `Inter-Regular.ttf`
- `Inter-Bold.ttf`
- `DMSans-Regular.ttf`
- `DMSans-Bold.ttf`

## Source

Download from https://fonts.google.com — search each family name and
download the "Variable" or individual weight TTF files.

**Phase 4a deferred font binary commit** — goldens committed without real
fonts will render with Ahem/fallback and must be regenerated once the
fonts are added.
