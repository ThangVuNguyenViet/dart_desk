# data_models — Showcase Schemas + Fixtures

This package houses the example document types used by the dart_desk showcase apps and tests. It serves two roles:
1. **Showcase content** for the example apps (consumed via `<Type>Fixtures.showcase()`).
2. **Feature coverage** — every dart_desk input widget / field annotation has at least one (Type, field) below.

## Layers

- `src/primitives/` — raw constants (image URLs, copy strings, enum option lists).
- `src/shared/` — leaf document type definitions (KioskProduct, ChefProfile, …).
- `src/configs/` — top-level configs that aggregate shared types (BrandTheme, HomeConfig, …).
- `src/fixtures/` — `<Type>Fixtures` factories. Today every type has `.showcase()`. Phase 4 will add edge-case variants (`.empty()`, `.allFieldsPopulated()`, `.longStrings()`, …).

## Field coverage

| Annotation | Exercised by (Type.field) |
|---|---|
| `@DeskString` | `BrandTheme.name`, `KioskProduct.name`, … (28 uses) |
| `@DeskText` | `ChefProfile.bio`, … (7 uses) |
| `@DeskNumber` | `KioskProduct.price`, … (10 uses) |
| `@DeskBoolean` | `RewardsConfig.enabled` (1 use) |
| `@DeskCheckbox` | `MenuItemEntry.available` (1 use) |
| `@DeskImage` | `HomeConfig.heroImage`, … (9 uses) |
| `@DeskFile` | `BrandTheme.brandGuidelinesPdf` (1 use) |
| `@DeskUrl` | `RewardsConfig.termsUrl` (1 use) |
| `@DeskColor` | `BrandTheme.primaryColor`, … (5 uses) |
| `@DeskDate` | `ChefConfig.publishedFrom` (1 use) |
| `@DeskDateTime` | `Coupon.expiresAt` (1 use) |
| `@DeskArray` | `HomeConfig.featuredDishes`, … (8 uses) |
| `@DeskObject` | `HomeConfig.primaryCta`, … (4 uses) |
| `@DeskBlock` | `LoyaltyTier.description`, … (4 uses) |
| `@DeskDropdown` | `BrandTheme.headlineFont`, … (6 uses) |
| `@DeskMultiDropdown` | `MenuItemEntry.tags`, … (4 uses) |
| `@DeskGeopoint` | `MenuConfig.coordinates` (1 use) |

Re-run `grep -rh "@Desk\w\+" lib/src/ | grep -oE "@Desk\w+" | sort | uniq -c` to refresh counts.
