# Aura Gastronomy Showcase

Rebuild of the dart_desk example app as a business-friendly consumer app showcase for the Dart Desk landing page. Replaces the current domain-model-driven example (MenuItem / PromotionCampaign / RestaurantProfile / BrandTheme) with five screen-specific CMS configs plus a singleton brand theme.

Designs come from Claude Design output at `~/Downloads/dart desk showcase/` — JSX screen files for Kiosk (tablet), Home, Chef's Choice, Menu, and Rewards, all branded "Aura Gastronomy" (deep green `#496455`, Noto Serif headlines, Manrope body, cream surfaces).

## Goals

- Produce screens polished enough to anchor the Dart Desk marketing page.
- Exercise every Dart Desk field type at least once across the config set.
- Keep one CMS document per screen, so the "edit left, preview right" story is clear.
- Drive all brand styling through a single editable `BrandTheme` singleton.

## Non-goals

- No backend/upload pipeline. Images default to external Unsplash URLs lifted from the JSX.
- No interactivity (ordering, cart, auth). Screens are presentation only.
- No rebuild of the "Hero landing composite" — that is a marketing artifact, not an app screen.

## Reference Files

- `Downloads/dart desk showcase/screens/home.jsx` — mobile home with hero + featured carousel + store card
- `Downloads/dart desk showcase/screens/kiosk.jsx` — tablet kiosk with banner, 3-panel grid, order sidebar
- `Downloads/dart desk showcase/screens/chef.jsx` — mobile chef's choice with pull-quote + curated list
- `Downloads/dart desk showcase/screens/menu.jsx` — mobile menu browse with tabs and filter chips
- `Downloads/dart desk showcase/screens/rewards.jsx` — mobile loyalty card + coupon stack
- `Downloads/dart desk showcase/screens/frame.jsx` — mobile frame + shared widgets (Photo, AuraButton, TabBar, wordmark)
- `Downloads/dart desk showcase/brand-standalone.jsx` — brand tokens (AURA.*), font stacks, shared IMG map

## Design Decisions

- **One document per screen.** Each screen is backed by exactly one `@DeskModel` document. No cross-document references for content lists — products live inline as arrays of objects.
- **BrandTheme is a singleton.** Every screen reads it and rebuilds when it changes, simulating a live theme update from the CMS.
- **Images use `ImageReference.external(url)` defaults.** The Unsplash URLs already in the JSX are preserved as seed data. A real deployment would swap for uploaded assets.
- **Field variety beats DRYness.** Where a field could reasonably be either a `String` or a `block`, or a `List<String>` vs a multi-dropdown, we pick whichever is still unused — to land full coverage across the config set.
- **Delete, don't deprecate.** The existing MenuItem / PromotionCampaign / RestaurantProfile models and their preview screens are removed. This is a greenfield showcase.

---

## Data Models

All models extend `DeskContent` and use `@MappableClass` with `discriminatorValue` plus `includeCustomMappers: [ImageReferenceMapper(), ColorMapper()]` where relevant.

### `BrandTheme` (singleton)

Drives colors and typography for all screens.

| Field | Type | Annotation |
|---|---|---|
| `name` | `String` | `@DeskString` |
| `primaryColor` | `Color` | `@DeskColor` |
| `surfaceColor` | `Color` | `@DeskColor` |
| `accentColor` | `Color` | `@DeskColor` |
| `inkColor` | `Color` | `@DeskColor` |
| `headlineFont` | `String` | `@DeskDropdown` (Noto Serif, Playfair Display, Cormorant Garamond, DM Serif Display) |
| `bodyFont` | `String` | `@DeskDropdown` (Manrope, Inter, DM Sans) |
| `cornerRadius` | `num` | `@DeskNumber(min: 0, max: 24)` |
| `logo` | `ImageReference?` | `@DeskImage` |

Defaults: Aura Gastronomy palette (green `#496455`, cream `#F6F1E7`, clay `#C67A4A`, ink `#1E1B14`, Noto Serif + Manrope, radius 16).

### `HomeConfig`

Mobile home screen.

| Field | Type | Annotation |
|---|---|---|
| `heroImage` | `ImageReference?` | `@DeskImage(hotspot: true)` |
| `heroEyebrow` | `String` | `@DeskString` — "Spring Menu · N° 4" |
| `heroHeadline` | `String` | `@DeskText` — multi-line italic title |
| `primaryCta` | `CtaAction` | `@DeskObject` (label string + style dropdown: solid/ghost) |
| `secondaryCta` | `CtaAction` | `@DeskObject` |
| `locationLabel` | `String` | `@DeskString` — "Tribeca" pill |
| `welcomeGreeting` | `String` | `@DeskString` — "Evening, Jules" |
| `featuredSectionTitle` | `String` | `@DeskString` |
| `featuredDishes` | `List<FeaturedDish>` | `@DeskArray<FeaturedDish>` |
| `storeCallout` | `StoreCallout` | `@DeskObject` |

Nested `FeaturedDish`: `name` (string), `price` (number), `tag` (dropdown: New, Chef's Pick, Seasonal, Vegan), `image` (image).

Nested `StoreCallout`: `venueName` (string), `hoursLabel` (string — "Open till 11:30pm"), `distanceLabel` (string — "0.4 mi away"), `directionsLabel` (string).

Nested `CtaAction`: `label` (string), `style` (dropdown: solid, ghost).

### `KioskConfig`

Tablet landscape in-store terminal.

| Field | Type | Annotation |
|---|---|---|
| `bannerImage` | `ImageReference?` | `@DeskImage` |
| `bannerHeadline` | `String` | `@DeskString` |
| `bannerSubtitle` | `String` | `@DeskText` |
| `promoBadge` | `String` | `@DeskString` |
| `gridProducts` | `List<KioskProduct>` | `@DeskArray<KioskProduct>` |
| `sidebarTableLabel` | `String` | `@DeskString` — "Table 12" |
| `sidebarSampleOrder` | `List<OrderLine>` | `@DeskArray<OrderLine>` |
| `footerNote` | `String` | `@DeskText` |

Nested `KioskProduct`: `name`, `price` (number), `image`, `category` (dropdown: Signature, Starter, Drink, Sweet).

Nested `OrderLine`: `itemName` (string), `qty` (number), `price` (number).

### `ChefConfig`

Mobile chef's choice / upsell.

| Field | Type | Annotation |
|---|---|---|
| `headline` | `String` | `@DeskText` — italic multi-line |
| `intro` | `Object?` | `@DeskBlock` — rich text |
| `chef` | `ChefProfile` | `@DeskObject` |
| `pullQuote` | `String` | `@DeskText` |
| `curatedDishes` | `List<CuratedDish>` | `@DeskArray<CuratedDish>` |
| `refreshCadence` | `String` | `@DeskString` — "Refreshed every Thursday" |
| `publishFrom` | `DateTime` | `@DeskDate` |

Nested `ChefProfile`: `name` (string), `role` (string), `portrait` (image), `bio` (text).

Nested `CuratedDish`: `numberLabel` (string — "01"), `name`, `price` (number), `image`, `description` (block — rich text).

### `MenuConfig`

Mobile menu browse.

| Field | Type | Annotation |
|---|---|---|
| `categories` | `List<String>` | `@DeskMultiDropdown<String>` (Starters, Mains, Sides, Desserts, Drinks) |
| `filterTags` | `List<String>` | `@DeskMultiDropdown<String>` (Vegan, Gluten-free, Chef's Pick, Seasonal, Spicy) |
| `items` | `List<MenuItemEntry>` | `@DeskArray<MenuItemEntry>` |
| `location` | `GeoPoint?` | `@DeskGeoPointFieldConfig` — for "find nearest" |
| `storeHours` | `List<StoreHoursEntry>` | `@DeskArray<StoreHoursEntry>` |

Nested `MenuItemEntry`: `name`, `price` (number), `shortDescription` (text), `image`, `tags` (multi-dropdown — same options as `filterTags`), `isAvailable` (boolean checkbox).

Nested `StoreHoursEntry`: `day` (dropdown: Mon–Sun), `openTime` (string "17:00"), `closeTime` (string "23:30").

### `RewardsConfig`

Mobile loyalty program.

| Field | Type | Annotation |
|---|---|---|
| `programName` | `String` | `@DeskString` |
| `tiers` | `List<LoyaltyTier>` | `@DeskArray<LoyaltyTier>` |
| `currentUserPoints` | `num` | `@DeskNumber` — demo state |
| `coupons` | `List<Coupon>` | `@DeskArray<Coupon>` |
| `termsUrl` | `String` | `@DeskUrl` |
| `fineprint` | `Object?` | `@DeskBlock` |

Nested `LoyaltyTier`: `name` (string), `threshold` (number), `tierColor` (color), `perks` (block).

Nested `Coupon`: `title` (string), `code` (string), `discountPercent` (number), `expiresAt` (datetime), `image`, `tags` (multi-dropdown: Food, Drinks, Dessert, Birthday).

---

## Field Coverage Matrix

| Field type | Used in |
|---|---|
| `@DeskString` | all |
| `@DeskText` | Home, Kiosk, Chef |
| `@DeskNumber` | BrandTheme, Home, Kiosk, Chef, Rewards |
| `@DeskBoolean` / `@DeskCheckbox` | Menu |
| `@DeskDate` | Chef |
| `@DeskDateTime` | Rewards |
| `@DeskUrl` | Rewards |
| `@DeskColor` | BrandTheme, Rewards |
| `@DeskImage` | BrandTheme, Home, Kiosk, Chef, Menu, Rewards |
| `@DeskDropdown` | BrandTheme, Home, Kiosk, Menu |
| `@DeskMultiDropdown` | Menu, Rewards |
| `@DeskBlock` | Chef, Rewards |
| `@DeskArray` | Home, Kiosk, Chef, Menu, Rewards |
| `@DeskObject` | Home, Kiosk, Chef, Rewards |
| `@DeskGeoPointFieldConfig` | Menu |

Every field type lands at least once.

---

## Flutter Screen Architecture

### Theme propagation

A helper `AuraTheme.wrap(brandTheme, child: ...)` builds a Material 3 `ThemeData` from `BrandTheme` and injects an `AuraTokens` inherited widget with editorial-only tokens not expressible in Material (creamWarm `#EFE8D8`, clay accent, inkSoft mute, line hairline). Screens call `AuraTokens.of(context)` for these.

Each screen wraps itself so that previewing a screen in isolation still reads from the current `BrandTheme` document.

### Screen composition

Each screen widget is a pure function of `(Config config, BrandTheme theme)`:

```dart
class HomeScreen extends StatelessWidget {
  final HomeConfig config;
  const HomeScreen({required this.config});

  @override
  Widget build(BuildContext context) {
    return AuraTheme.wrap(
      context.read<BrandTheme>(),
      child: MobileFrame(child: _HomeBody(config: config)),
    );
  }
}
```

No internal state. Re-renders purely on config change.

### Shared widgets

Ported from `frame.jsx`, living in `examples/example_app/lib/widgets/aura/`:

- `MobileFrame` — iOS-style rounded device frame with status bar and notch cutout (matches 390 × 844 artboard)
- `TabletFrame` — landscape 1194 × 834 (for Kiosk)
- `TabBar` — bottom nav with 4 items (Home, Menu, Rewards, Profile)
- `Photo` — `Image.network` wrapper with rounded corners, aspect control, and optional overlay child
- `AuraButton` — rounded pill button in dark / ghost / solid variants
- `AuraWordmark` — the italic "Aura" logotype in serif
- `AuraIconButton` — circular outlined icon button used for back/save/share

Each screen file stays under ~300 lines by delegating to these shared widgets.

### Integration into the CMS app

`examples/desk_app/lib/document_types.dart` registers six document types: `BrandTheme`, `HomeConfig`, `KioskConfig`, `ChefConfig`, `MenuConfig`, `RewardsConfig`. `main.dart` lists them in the navigation with icons.

The existing CMS wiring (`DeskDocumentRegistry`, preview plumbing) is reused as-is.

---

## File Map

### Data models (`examples/data_models/lib/src/`)

Create:
- `configs/home_config.dart` (+ `.desk.dart`, `.mapper.dart`)
- `configs/kiosk_config.dart` (+ generated)
- `configs/chef_config.dart` (+ generated)
- `configs/menu_config.dart` (+ generated)
- `configs/rewards_config.dart` (+ generated)
- `shared/featured_dish.dart`, `kiosk_product.dart`, `order_line.dart`, `chef_profile.dart`, `curated_dish.dart`, `menu_item_entry.dart`, `store_hours_entry.dart`, `loyalty_tier.dart`, `coupon.dart`, `cta_action.dart`, `store_callout.dart` (+ mappers)
- `seed/aura_assets.dart` — Unsplash URL map keyed by asset id (heroTable, dish1…dish12, chef, chefAlt, herbs, wine, bread, citrus)
- `seed/aura_copy.dart` — headline/subtitle strings lifted from the JSX

Rewrite:
- `configs/brand_theme.dart` — update defaults to Aura palette, add `inkColor`

Delete:
- `configs/menu_item.dart` (+ generated)
- `configs/promotion_campaign.dart` (+ generated)
- `configs/restaurant_profile.dart` (+ generated)
- `seed/seed_data.dart` — replaced by `aura_assets.dart` + `aura_copy.dart`

Modify:
- `lib/example_data.dart` — update exports

### Preview screens (`examples/example_app/lib/`)

Create:
- `screens/home_screen.dart`
- `screens/kiosk_screen.dart`
- `screens/chef_screen.dart`
- `screens/menu_screen.dart`
- `screens/rewards_screen.dart`
- `widgets/aura/aura_theme.dart`
- `widgets/aura/aura_tokens.dart`
- `widgets/aura/aura_button.dart`
- `widgets/aura/aura_wordmark.dart`
- `widgets/aura/aura_icon_button.dart`
- `widgets/aura/photo.dart`
- `widgets/aura/mobile_frame.dart`
- `widgets/aura/tablet_frame.dart`
- `widgets/aura/tab_bar.dart`

Rewrite:
- `screens/brand_theme_screen.dart` — show all theme tokens applied across mini previews of the other 5 screens

Delete:
- `screens/menu_item_screen.dart`
- `screens/promotion_campaign_screen.dart`
- `screens/restaurant_profile_screen.dart`

### CMS app (`examples/desk_app/lib/`)

Modify:
- `document_types.dart` — register 6 doc types
- `main.dart` — nav entries with icons

---

## Seed Data

All default values are seeded from the JSX:

- **Brand palette:** `#496455` / `#F6F1E7` / `#C67A4A` / `#1E1B14`, Noto Serif + Manrope, radius 16.
- **Images:** Unsplash URLs from `brand-standalone.jsx` (IMG map: heroTable, heroPlating, heroRoom, dish1–12, chef, chefAlt, herbs, wine, bread, citrus).
- **Copy:** "A table for the long evening.", "Spring Menu · N° 4", "Three dishes I'd put on every table.", "The best meals are the ones that feel like they happened to you, not for you." — Marco Vespucci, Head Chef, etc.
- **Dishes:** Charred Brassicas $16, Orecchiette 'Nduja $24, Olive Oil Cake $11, Citrus & Fennel $15, Pea Tendril Agnolotti $26, Whole Branzino $38, etc. — full list from home.jsx / chef.jsx / menu.jsx.

---

## Testing

- Each screen gets a widget test that renders it with its `defaultValue` config and verifies no exceptions + golden snapshot at the artboard dimensions (390 × 844 or 1194 × 834).
- Brand theme propagation test: swap `BrandTheme.primaryColor`, verify all five screens re-render with the new color.
- Code generation smoke test: `dart run build_runner build` produces all `.desk.dart` and `.mapper.dart` files without errors.

---

## Risks

- **Large surface area.** 6 configs + 11 nested types + 5 screens + 8 shared widgets. Mitigation: ship in clear task batches (field types → configs → shared widgets → screens one at a time), run codegen after each config.
- **Pixel fidelity vs JSX.** Flutter layout won't be byte-identical to CSS. Target: visually indistinguishable at the artboard dimensions; not a 1:1 pixel port.
- **External image dependency.** Unsplash URLs can 404. Mitigation: keep the URL list in `aura_assets.dart` and document that a production deployment swaps these for uploaded assets.
