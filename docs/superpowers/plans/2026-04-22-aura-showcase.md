# Aura Showcase Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the dart_desk example app as a 5-screen "Aura Gastronomy" consumer app showcase, backed by six CMS configs that together exercise every Dart Desk field type.

**Architecture:** Six `@DeskModel` documents (one per screen + a `BrandTheme` singleton) live in `examples/data_models/`. Flutter preview widgets live in `examples/example_app/lib/screens/` and consume their config as pure functions. A shared `widgets/aura/` folder ports the common JSX atoms (MobileFrame, TabBar, Photo, AuraButton, wordmark, icon button). Default values seed from the Claude Design JSX — real Unsplash URLs, real copy — so the previews look polished with zero CMS editing.

**Tech Stack:** Flutter, `dart_desk` annotations, `dart_mappable`, `build_runner` code generation, `shadcn_ui`. Workspace managed by `melos`.

**Spec:** `docs/superpowers/specs/2026-04-22-aura-showcase-design.md`
**Design source:** `~/Downloads/dart desk showcase/` (JSX files + brand tokens)

---

## File Map

### Data models — `examples/data_models/lib/`

**Delete:**
- `src/configs/menu_item.dart` + `.desk.dart` + `.mapper.dart`
- `src/configs/promotion_campaign.dart` + generated
- `src/configs/restaurant_profile.dart` + generated
- `src/seed/seed_data.dart`

**Rewrite:**
- `src/configs/brand_theme.dart` (+ generated)
- `example_data.dart` (exports)

**Create:**
- `src/seed/aura_assets.dart` — Unsplash URL map
- `src/seed/aura_copy.dart` — canonical copy strings
- `src/seed/aura_enums.dart` — dropdown option lists
- `src/shared/cta_action.dart`
- `src/shared/store_callout.dart`
- `src/shared/featured_dish.dart`
- `src/shared/kiosk_product.dart`
- `src/shared/order_line.dart`
- `src/shared/chef_profile.dart`
- `src/shared/curated_dish.dart`
- `src/shared/menu_item_entry.dart`
- `src/shared/store_hours_entry.dart`
- `src/shared/loyalty_tier.dart`
- `src/shared/coupon.dart`
- `src/configs/home_config.dart`
- `src/configs/kiosk_config.dart`
- `src/configs/chef_config.dart`
- `src/configs/menu_config.dart`
- `src/configs/rewards_config.dart`

### Example app — `examples/example_app/lib/`

**Delete:**
- `screens/menu_item_screen.dart`
- `screens/promotion_campaign_screen.dart`
- `screens/restaurant_profile_screen.dart`

**Rewrite:**
- `screens/brand_theme_screen.dart`

**Create:**
- `widgets/aura/aura_tokens.dart`
- `widgets/aura/aura_theme.dart`
- `widgets/aura/photo.dart`
- `widgets/aura/aura_button.dart`
- `widgets/aura/aura_wordmark.dart`
- `widgets/aura/aura_icon_button.dart`
- `widgets/aura/mobile_frame.dart`
- `widgets/aura/tablet_frame.dart`
- `widgets/aura/aura_tab_bar.dart`
- `screens/home_screen.dart`
- `screens/kiosk_screen.dart`
- `screens/chef_screen.dart`
- `screens/menu_screen.dart`
- `screens/rewards_screen.dart`

### CMS app — `examples/desk_app/lib/`

**Modify:**
- `document_types.dart` — register 6 doc types
- `main.dart` — nav entries

---

## Global Commands

Run from `dart_desk/` repo root unless stated otherwise.

- Codegen (after any `@DeskModel` or `@MappableClass` change):
  ```bash
  cd examples/data_models && dart run build_runner build --delete-conflicting-outputs
  ```
- Analyze workspace: `melos run analyze`
- Run example app tests: `cd examples/example_app && flutter test`

---

## Phase 0 — Clean slate

### Task 0.1: Delete legacy data models and screens

**Files:**
- Delete: `examples/data_models/lib/src/configs/menu_item.dart`, `menu_item.desk.dart`, `menu_item.mapper.dart`
- Delete: `examples/data_models/lib/src/configs/promotion_campaign.dart` + generated
- Delete: `examples/data_models/lib/src/configs/restaurant_profile.dart` + generated
- Delete: `examples/data_models/lib/src/seed/seed_data.dart`
- Delete: `examples/example_app/lib/screens/menu_item_screen.dart`
- Delete: `examples/example_app/lib/screens/promotion_campaign_screen.dart`
- Delete: `examples/example_app/lib/screens/restaurant_profile_screen.dart`

- [ ] **Step 1: Delete files**

```bash
cd examples/data_models/lib/src/configs && rm menu_item.dart menu_item.desk.dart menu_item.mapper.dart promotion_campaign.dart promotion_campaign.desk.dart promotion_campaign.mapper.dart restaurant_profile.dart restaurant_profile.desk.dart restaurant_profile.mapper.dart
cd ../../../../.. && rm examples/data_models/lib/src/seed/seed_data.dart
rm examples/example_app/lib/screens/menu_item_screen.dart examples/example_app/lib/screens/promotion_campaign_screen.dart examples/example_app/lib/screens/restaurant_profile_screen.dart
```

- [ ] **Step 2: Stub `example_data.dart` to only export what still exists**

Overwrite `examples/data_models/lib/example_data.dart` with:

```dart
library;

export 'src/configs/desk_content.dart';
// Re-added incrementally as configs land:
// export 'src/configs/brand_theme.dart' hide BrandThemeColorMapper;
```

- [ ] **Step 3: Stub `document_types.dart` and `main.dart`**

Temporarily reduce `examples/desk_app/lib/document_types.dart` to only the `brandThemeDocumentType` block (keep `BrandTheme` wiring since we'll rewrite it). Remove imports for deleted screens. Comment out the other three document types.

Do the same for `examples/desk_app/lib/main.dart` — remove nav entries for deleted doc types.

- [ ] **Step 4: Verify compile**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && melos run analyze
```

Expected: PASS with no missing-import errors (brand_theme still compiles; we'll rewrite it in the next task).

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "Remove legacy example data models and screens"
```

---

## Phase 1 — Seed data and brand tokens

### Task 1.1: Create `aura_assets.dart`

**Files:**
- Create: `examples/data_models/lib/src/seed/aura_assets.dart`

- [ ] **Step 1: Write the file**

The URL set comes from `~/Downloads/dart desk showcase/Aura Gastronomy - standalone source.html` lines 12–33 (the `<meta name="ext-resource-dependency">` tags).

```dart
/// Unsplash image URLs used as default values across Aura Gastronomy configs.
/// Keyed by the same asset id used in the JSX `IMG` map.
class AuraAssets {
  static const heroDusk    = 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1600&h=1100&fit=crop&crop=entropy';
  static const heroPlating = 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=1400&h=1000&fit=crop';
  static const heroTable   = 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=1600&h=1100&fit=crop';
  static const heroRoom    = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1600&h=1200&fit=crop';
  static const dish1  = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900&h=900&fit=crop';
  static const dish2  = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=900&h=900&fit=crop';
  static const dish3  = 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=900&h=900&fit=crop';
  static const dish4  = 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=900&h=900&fit=crop';
  static const dish5  = 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=900&h=900&fit=crop';
  static const dish6  = 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=900&h=900&fit=crop';
  static const dish7  = 'https://images.unsplash.com/photo-1432139509613-5c4255815697?w=900&h=900&fit=crop';
  static const dish8  = 'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=900&h=900&fit=crop';
  static const dish9  = 'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=900&h=900&fit=crop';
  static const dish10 = 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=900&h=900&fit=crop';
  static const dish11 = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=900&h=900&fit=crop';
  static const dish12 = 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=900&h=900&fit=crop';
  static const chef    = 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=800&h=1000&fit=crop';
  static const chefAlt = 'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=700&h=700&fit=crop';
  static const herbs   = 'https://images.unsplash.com/photo-1466637574441-749b8f19452f?w=800&h=600&fit=crop';
  static const wine    = 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800&h=600&fit=crop';
  static const bread   = 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&h=600&fit=crop';
  static const citrus  = 'https://images.unsplash.com/photo-1557800636-894a64c1696f?w=800&h=600&fit=crop';
}

/// Build an [ImageReference] from a seed URL.
/// Uses the `dart_desk` package's ImageReference; imported at call sites.
/// Keep this file dependency-free so it can be imported anywhere.
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/seed/aura_assets.dart
git commit -m "Add Aura Gastronomy asset URL seed"
```

### Task 1.2: Create `aura_enums.dart`

**Files:**
- Create: `examples/data_models/lib/src/seed/aura_enums.dart`

- [ ] **Step 1: Write the file**

```dart
/// Shared dropdown/multi-dropdown option lists for Aura configs.

const headlineFonts = ['Noto Serif', 'Playfair Display', 'Cormorant Garamond', 'DM Serif Display'];
const bodyFonts = ['Manrope', 'Inter', 'DM Sans'];

/// Featured dish tags — single-select dropdown on HomeConfig.featuredDishes.
const featuredDishTags = ['New', "Chef's Pick", 'Seasonal', 'Vegan'];

/// Kiosk product category — single-select dropdown on KioskConfig.gridProducts.
const kioskCategories = ['Signature', 'Starter', 'Drink', 'Sweet'];

/// Menu categories — multi-select on MenuConfig.
const menuCategories = ['Starters', 'Mains', 'Sides', 'Desserts', 'Drinks'];

/// Menu filter tags — multi-select on MenuConfig and per-item.
const menuFilterTags = ['Vegan', 'Gluten-free', "Chef's Pick", 'Seasonal', 'Spicy'];

/// Days of the week for store hours dropdown.
const daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// CTA button style.
const ctaStyles = ['solid', 'ghost'];

/// Coupon category tags — multi-select on RewardsConfig.coupons.
const couponTags = ['Food', 'Drinks', 'Dessert', 'Birthday'];
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/seed/aura_enums.dart
git commit -m "Add Aura dropdown option lists"
```

### Task 1.3: Create `aura_copy.dart`

**Files:**
- Create: `examples/data_models/lib/src/seed/aura_copy.dart`

- [ ] **Step 1: Write the file**

All copy strings lifted from `home.jsx`, `chef.jsx`, `kiosk.jsx`, `menu.jsx`, `rewards.jsx`. Kept in one place so `defaultValue` constructors read clean.

```dart
/// Canonical Aura copy — lifted from the JSX designs.
class AuraCopy {
  // Home
  static const homeEyebrow = 'Spring Menu · N° 4';
  static const homeHeadline = 'A table\nfor the\nlong evening.';
  static const homeLocation = 'Tribeca';
  static const homeGreeting = 'Evening, Jules';
  static const homeFeaturedTitle = 'Featured by the kitchen';
  static const homeStoreName = 'Aura Tribeca';
  static const homeStoreHours = 'Open till 11:30pm';
  static const homeStoreDistance = '0.4 mi away';

  // Kiosk
  static const kioskBannerHeadline = 'Spring, plated.';
  static const kioskBannerSubtitle =
      'Four weeks of new pasta, shellfish, and spring vegetables from the kitchen of Marco Vespucci.';
  static const kioskPromoBadge = 'Spring Menu';
  static const kioskTableLabel = 'Table 12';
  static const kioskFooter =
      'Your server will confirm every order. Prices include tax; gratuity added for parties of six or more.';

  // Chef
  static const chefHeadline = "Three dishes\nI'd put on\nevery table.";
  static const chefPullQuote =
      'The best meals are the ones that feel like they happened to you, not for you.';
  static const chefName = 'Marco Vespucci';
  static const chefRole = 'Head Chef · Aura Tribeca';
  static const chefRefresh = 'a curation refreshed every Thursday';

  // Rewards
  static const rewardsProgram = 'Aura Circle';
  static const rewardsTerms = 'https://aura.example/terms';
}
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/seed/aura_copy.dart
git commit -m "Add Aura canonical copy strings"
```

---

## Phase 2 — Rewrite BrandTheme

### Task 2.1: Rewrite `brand_theme.dart`

**Files:**
- Modify: `examples/data_models/lib/src/configs/brand_theme.dart`
- Modify: `examples/data_models/lib/example_data.dart`

- [ ] **Step 1: Rewrite `brand_theme.dart`**

Replace the entire file. The spec's four colors (`primaryColor`, `surfaceColor`, `accentColor`, `inkColor`) replace the old `primaryColor`/`secondaryColor`/`accentColor`. `themeMode` is removed. `logo` stays.

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/aura_enums.dart';
import 'desk_content.dart';

part 'brand_theme.desk.dart';
part 'brand_theme.mapper.dart';

@DeskModel(
  title: 'Brand Theme',
  description: 'Colors and typography shared across every Aura screen.',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'brandTheme',
  includeCustomMappers: [BrandThemeColorMapper(), ImageReferenceMapper()],
)
class BrandTheme extends DeskContent
    with BrandThemeMappable, Serializable<BrandTheme> {
  @DeskString(description: 'Theme name', option: DeskStringOption())
  final String name;

  @DeskColor(
    description: 'Primary — buttons, accents, dark surfaces',
    option: DeskColorOption(),
  )
  final Color primaryColor;

  @DeskColor(
    description: 'Surface — page backgrounds',
    option: DeskColorOption(),
  )
  final Color surfaceColor;

  @DeskColor(
    description: 'Accent — prices, tags, warm highlights',
    option: DeskColorOption(),
  )
  final Color accentColor;

  @DeskColor(
    description: 'Ink — body text and headlines',
    option: DeskColorOption(),
  )
  final Color inkColor;

  @DeskDropdown<String>(
    description: 'Headline font',
    option: HeadlineFontDropdownOption(),
  )
  final String headlineFont;

  @DeskDropdown<String>(
    description: 'Body font',
    option: BodyFontDropdownOption(),
  )
  final String bodyFont;

  @DeskNumber(
    description: 'Corner radius in px',
    option: DeskNumberOption(min: 0, max: 24),
  )
  final num cornerRadius;

  @DeskImage(
    description: 'Logo (square)',
    option: DeskImageOption(hotspot: false),
  )
  final ImageReference? logo;

  const BrandTheme({
    required this.name,
    required this.primaryColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.inkColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    this.logo,
  });

  static BrandTheme defaultValue = const BrandTheme(
    name: 'Aura Gastronomy',
    primaryColor: Color(0xFF496455),
    surfaceColor: Color(0xFFF6F1E7),
    accentColor: Color(0xFFC67A4A),
    inkColor: Color(0xFF1E1B14),
    headlineFont: 'Noto Serif',
    bodyFont: 'Manrope',
    cornerRadius: 16,
    logo: null,
  );
}

class BrandThemeColorMapper extends SimpleMapper<Color> {
  const BrandThemeColorMapper();

  @override
  Color decode(Object value) {
    if (value is String) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    throw Exception('Cannot decode Color from $value');
  }

  @override
  Object? encode(Color self) =>
      '#${self.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

class HeadlineFontDropdownOption extends DeskDropdownOption<String> {
  const HeadlineFontDropdownOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'Noto Serif';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final f in headlineFonts) DropdownOption(value: f, label: f),
      ];
  @override
  String? get placeholder => 'Headline font';
}

class BodyFontDropdownOption extends DeskDropdownOption<String> {
  const BodyFontDropdownOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'Manrope';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final f in bodyFonts) DropdownOption(value: f, label: f),
      ];
  @override
  String? get placeholder => 'Body font';
}
```

- [ ] **Step 2: Delete old generated files**

```bash
rm examples/data_models/lib/src/configs/brand_theme.desk.dart examples/data_models/lib/src/configs/brand_theme.mapper.dart
```

- [ ] **Step 3: Update `example_data.dart`**

```dart
library;

export 'src/configs/desk_content.dart';
export 'src/configs/brand_theme.dart' hide BrandThemeColorMapper;
export 'src/seed/aura_assets.dart';
export 'src/seed/aura_enums.dart';
export 'src/seed/aura_copy.dart';
```

- [ ] **Step 4: Run codegen**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs
```

Expected: generates `brand_theme.desk.dart` and `brand_theme.mapper.dart`. No errors.

- [ ] **Step 5: Analyze**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && melos run analyze
```

Expected: PASS. The `brand_theme_screen.dart` will fail because it references the deleted `themeMode` and `secondaryColor`. Fix that next.

- [ ] **Step 6: Temporarily stub `brand_theme_screen.dart`**

Replace the body of `examples/example_app/lib/screens/brand_theme_screen.dart` with:

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

class BrandThemeScreen extends StatelessWidget {
  const BrandThemeScreen({super.key, required this.config});
  final BrandTheme config;

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Brand Theme preview — rebuild in Task 8.1'));
}
```

- [ ] **Step 7: Analyze again, commit**

```bash
melos run analyze
git add -A && git commit -m "Rewrite BrandTheme config for Aura palette"
```

---

## Phase 3 — Nested shared types

These nested types are used by multiple configs and must exist before the configs that reference them compile. Each task: define the class, run codegen, commit.

### Task 3.1: `CtaAction`

**Files:**
- Create: `examples/data_models/lib/src/shared/cta_action.dart`

- [ ] **Step 1: Write the file**

```dart
import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'cta_action.desk.dart';
part 'cta_action.mapper.dart';

@MappableClass()
@DeskModel(title: 'Call-to-action', description: 'Button label + style')
class CtaAction with CtaActionMappable implements Serializable<CtaAction> {
  @DeskString(description: 'Button label', option: DeskStringOption())
  final String label;

  @DeskDropdown<String>(
    description: 'Visual style',
    option: CtaStyleDropdownOption(),
  )
  final String style;

  const CtaAction({required this.label, required this.style});

  static CtaAction defaultValue = const CtaAction(label: 'Order now', style: 'solid');

  static CtaAction $fromMap(Map<String, dynamic> map) => CtaActionMapper.fromMap(map);
}

class CtaStyleDropdownOption extends DeskDropdownOption<String> {
  const CtaStyleDropdownOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'solid';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final s in ctaStyles) DropdownOption(value: s, label: s),
      ];
  @override
  String? get placeholder => 'Style';
}
```

- [ ] **Step 2: Codegen + commit**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && git add -A && git commit -m "Add CtaAction shared type"
```

### Task 3.2: `StoreCallout`

**Files:**
- Create: `examples/data_models/lib/src/shared/store_callout.dart`

- [ ] **Step 1: Write the file**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'store_callout.desk.dart';
part 'store_callout.mapper.dart';

@MappableClass()
@DeskModel(title: 'Store callout', description: 'Venue card on the home screen')
class StoreCallout with StoreCalloutMappable implements Serializable<StoreCallout> {
  @DeskString(description: 'Venue name', option: DeskStringOption())
  final String venueName;

  @DeskString(description: 'Hours label', option: DeskStringOption())
  final String hoursLabel;

  @DeskString(description: 'Distance label', option: DeskStringOption())
  final String distanceLabel;

  @DeskString(description: 'Directions button label', option: DeskStringOption())
  final String directionsLabel;

  const StoreCallout({
    required this.venueName,
    required this.hoursLabel,
    required this.distanceLabel,
    required this.directionsLabel,
  });

  static StoreCallout defaultValue = const StoreCallout(
    venueName: 'Aura Tribeca',
    hoursLabel: 'Open till 11:30pm',
    distanceLabel: '0.4 mi away',
    directionsLabel: 'Directions',
  );

  static StoreCallout $fromMap(Map<String, dynamic> map) => StoreCalloutMapper.fromMap(map);
}
```

- [ ] **Step 2: Codegen + commit**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && git add -A && git commit -m "Add StoreCallout shared type"
```

### Task 3.3: `FeaturedDish`

**Files:**
- Create: `examples/data_models/lib/src/shared/featured_dish.dart`

- [ ] **Step 1: Write the file**

```dart
import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'featured_dish.desk.dart';
part 'featured_dish.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Featured dish', description: 'Home screen carousel item')
class FeaturedDish with FeaturedDishMappable implements Serializable<FeaturedDish> {
  @DeskString(description: 'Dish name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Price', option: DeskNumberOption(min: 0))
  final num price;

  @DeskDropdown<String>(description: 'Tag', option: FeaturedDishTagOption())
  final String tag;

  @DeskImage(description: 'Photo', option: DeskImageOption(hotspot: true))
  final ImageReference? image;

  const FeaturedDish({required this.name, required this.price, required this.tag, this.image});

  static FeaturedDish defaultValue = const FeaturedDish(name: 'Charred Brassicas', price: 16, tag: 'New');

  static FeaturedDish $fromMap(Map<String, dynamic> map) => FeaturedDishMapper.fromMap(map);
}

class FeaturedDishTagOption extends DeskDropdownOption<String> {
  const FeaturedDishTagOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'New';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final t in featuredDishTags) DropdownOption(value: t, label: t),
      ];
  @override
  String? get placeholder => 'Tag';
}
```

- [ ] **Step 2: Codegen + commit**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && git add -A && git commit -m "Add FeaturedDish shared type"
```

### Task 3.4: `KioskProduct` + `OrderLine`

**Files:**
- Create: `examples/data_models/lib/src/shared/kiosk_product.dart`
- Create: `examples/data_models/lib/src/shared/order_line.dart`

- [ ] **Step 1: Write `kiosk_product.dart`**

```dart
import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'kiosk_product.desk.dart';
part 'kiosk_product.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Kiosk product', description: 'Tile in the kiosk grid')
class KioskProduct with KioskProductMappable implements Serializable<KioskProduct> {
  @DeskString(description: 'Name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Price', option: DeskNumberOption(min: 0))
  final num price;

  @DeskImage(description: 'Photo', option: DeskImageOption(hotspot: true))
  final ImageReference? image;

  @DeskDropdown<String>(description: 'Category', option: KioskCategoryOption())
  final String category;

  const KioskProduct({required this.name, required this.price, this.image, required this.category});

  static KioskProduct defaultValue = const KioskProduct(name: 'Orecchiette', price: 24, category: 'Signature');

  static KioskProduct $fromMap(Map<String, dynamic> map) => KioskProductMapper.fromMap(map);
}

class KioskCategoryOption extends DeskDropdownOption<String> {
  const KioskCategoryOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'Signature';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final c in kioskCategories) DropdownOption(value: c, label: c),
      ];
  @override
  String? get placeholder => 'Category';
}
```

- [ ] **Step 2: Write `order_line.dart`**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'order_line.desk.dart';
part 'order_line.mapper.dart';

@MappableClass()
@DeskModel(title: 'Order line', description: 'Single line in the kiosk order sidebar')
class OrderLine with OrderLineMappable implements Serializable<OrderLine> {
  @DeskString(description: 'Item name', option: DeskStringOption())
  final String itemName;

  @DeskNumber(description: 'Qty', option: DeskNumberOption(min: 1))
  final num qty;

  @DeskNumber(description: 'Unit price', option: DeskNumberOption(min: 0))
  final num price;

  const OrderLine({required this.itemName, required this.qty, required this.price});

  static OrderLine defaultValue = const OrderLine(itemName: 'Olive Oil Cake', qty: 1, price: 11);

  static OrderLine $fromMap(Map<String, dynamic> map) => OrderLineMapper.fromMap(map);
}
```

- [ ] **Step 3: Codegen + commit**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && git add -A && git commit -m "Add KioskProduct and OrderLine shared types"
```

### Task 3.5: `ChefProfile` + `CuratedDish`

**Files:**
- Create: `examples/data_models/lib/src/shared/chef_profile.dart`
- Create: `examples/data_models/lib/src/shared/curated_dish.dart`

- [ ] **Step 1: Write `chef_profile.dart`**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'chef_profile.desk.dart';
part 'chef_profile.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Chef profile', description: 'Head chef bio block')
class ChefProfile with ChefProfileMappable implements Serializable<ChefProfile> {
  @DeskString(description: 'Name', option: DeskStringOption())
  final String name;

  @DeskString(description: 'Role', option: DeskStringOption())
  final String role;

  @DeskImage(description: 'Portrait', option: DeskImageOption(hotspot: true))
  final ImageReference? portrait;

  @DeskText(description: 'Bio', option: DeskTextOption())
  final String bio;

  const ChefProfile({required this.name, required this.role, this.portrait, required this.bio});

  static ChefProfile defaultValue = const ChefProfile(
    name: 'Marco Vespucci',
    role: 'Head Chef · Aura Tribeca',
    bio: 'Twelve years between Milan and Brooklyn. Cooks seasonally, apologizes rarely.',
  );

  static ChefProfile $fromMap(Map<String, dynamic> map) => ChefProfileMapper.fromMap(map);
}
```

- [ ] **Step 2: Write `curated_dish.dart`**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'curated_dish.desk.dart';
part 'curated_dish.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Curated dish', description: 'Entry in the Chef\'s Choice list')
class CuratedDish with CuratedDishMappable implements Serializable<CuratedDish> {
  @DeskString(description: 'Order number (e.g. "01")', option: DeskStringOption())
  final String numberLabel;

  @DeskString(description: 'Dish name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Price', option: DeskNumberOption(min: 0))
  final num price;

  @DeskImage(description: 'Photo', option: DeskImageOption(hotspot: true))
  final ImageReference? image;

  @DeskBlock(option: DeskBlockOption())
  final Object? description;

  const CuratedDish({
    required this.numberLabel,
    required this.name,
    required this.price,
    this.image,
    this.description,
  });

  static CuratedDish defaultValue = const CuratedDish(numberLabel: '01', name: 'Pea Tendril Agnolotti', price: 26);

  static CuratedDish $fromMap(Map<String, dynamic> map) => CuratedDishMapper.fromMap(map);
}
```

- [ ] **Step 3: Codegen + commit**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && git add -A && git commit -m "Add ChefProfile and CuratedDish shared types"
```

### Task 3.6: `MenuItemEntry` + `StoreHoursEntry`

**Files:**
- Create: `examples/data_models/lib/src/shared/menu_item_entry.dart`
- Create: `examples/data_models/lib/src/shared/store_hours_entry.dart`

- [ ] **Step 1: Write `menu_item_entry.dart`**

```dart
import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'menu_item_entry.desk.dart';
part 'menu_item_entry.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Menu item', description: 'Row in the menu browse list')
class MenuItemEntry with MenuItemEntryMappable implements Serializable<MenuItemEntry> {
  @DeskString(description: 'Name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Price', option: DeskNumberOption(min: 0))
  final num price;

  @DeskText(description: 'Short description', option: DeskTextOption())
  final String shortDescription;

  @DeskImage(description: 'Photo', option: DeskImageOption(hotspot: true))
  final ImageReference? image;

  @DeskMultiDropdown<String>(description: 'Tags', option: MenuItemTagsOption())
  final List<String> tags;

  @DeskCheckbox(description: 'Available', option: DeskCheckboxOption(label: 'Available'))
  final bool isAvailable;

  const MenuItemEntry({
    required this.name,
    required this.price,
    required this.shortDescription,
    this.image,
    required this.tags,
    required this.isAvailable,
  });

  static MenuItemEntry defaultValue = const MenuItemEntry(
    name: 'Orecchiette \'Nduja',
    price: 24,
    shortDescription: 'House-made orecchiette, spicy \'nduja, pecorino.',
    tags: ["Chef's Pick"],
    isAvailable: true,
  );

  static MenuItemEntry $fromMap(Map<String, dynamic> map) => MenuItemEntryMapper.fromMap(map);
}

class MenuItemTagsOption extends DeskMultiDropdownOption<String> {
  const MenuItemTagsOption({super.hidden});
  @override
  List<String>? get defaultValues => const [];
  @override
  int? get maxSelected => null;
  @override
  int? get minSelected => null;
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final t in menuFilterTags) DropdownOption(value: t, label: t),
      ];
  @override
  String? get placeholder => 'Tags';
}
```

- [ ] **Step 2: Write `store_hours_entry.dart`**

```dart
import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'store_hours_entry.desk.dart';
part 'store_hours_entry.mapper.dart';

@MappableClass()
@DeskModel(title: 'Store hours entry', description: 'Open/close times for a single day')
class StoreHoursEntry with StoreHoursEntryMappable implements Serializable<StoreHoursEntry> {
  @DeskDropdown<String>(description: 'Day', option: DayOfWeekOption())
  final String day;

  @DeskString(description: 'Open (HH:mm)', option: DeskStringOption())
  final String openTime;

  @DeskString(description: 'Close (HH:mm)', option: DeskStringOption())
  final String closeTime;

  const StoreHoursEntry({required this.day, required this.openTime, required this.closeTime});

  static StoreHoursEntry defaultValue = const StoreHoursEntry(day: 'Mon', openTime: '17:00', closeTime: '23:00');

  static StoreHoursEntry $fromMap(Map<String, dynamic> map) => StoreHoursEntryMapper.fromMap(map);
}

class DayOfWeekOption extends DeskDropdownOption<String> {
  const DayOfWeekOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'Mon';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final d in daysOfWeek) DropdownOption(value: d, label: d),
      ];
  @override
  String? get placeholder => 'Day';
}
```

- [ ] **Step 3: Codegen + commit**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && git add -A && git commit -m "Add MenuItemEntry and StoreHoursEntry shared types"
```

### Task 3.7: `LoyaltyTier` + `Coupon`

**Files:**
- Create: `examples/data_models/lib/src/shared/loyalty_tier.dart`
- Create: `examples/data_models/lib/src/shared/coupon.dart`

- [ ] **Step 1: Write `loyalty_tier.dart`**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../configs/brand_theme.dart' show BrandThemeColorMapper;

part 'loyalty_tier.desk.dart';
part 'loyalty_tier.mapper.dart';

@MappableClass(includeCustomMappers: [BrandThemeColorMapper()])
@DeskModel(title: 'Loyalty tier', description: 'A tier in the rewards program')
class LoyaltyTier with LoyaltyTierMappable implements Serializable<LoyaltyTier> {
  @DeskString(description: 'Tier name', option: DeskStringOption())
  final String name;

  @DeskNumber(description: 'Points threshold', option: DeskNumberOption(min: 0))
  final num threshold;

  @DeskColor(description: 'Tier color', option: DeskColorOption())
  final Color tierColor;

  @DeskBlock(option: DeskBlockOption())
  final Object? perks;

  const LoyaltyTier({
    required this.name,
    required this.threshold,
    required this.tierColor,
    this.perks,
  });

  static LoyaltyTier defaultValue = const LoyaltyTier(
    name: 'Cedar',
    threshold: 0,
    tierColor: Color(0xFF6B4E2E),
  );

  static LoyaltyTier $fromMap(Map<String, dynamic> map) => LoyaltyTierMapper.fromMap(map);
}
```

- [ ] **Step 2: Write `coupon.dart`**

```dart
import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'coupon.desk.dart';
part 'coupon.mapper.dart';

@MappableClass(includeCustomMappers: [ImageReferenceMapper()])
@DeskModel(title: 'Coupon', description: 'Reward redeemable by the guest')
class Coupon with CouponMappable implements Serializable<Coupon> {
  @DeskString(description: 'Title', option: DeskStringOption())
  final String title;

  @DeskString(description: 'Code', option: DeskStringOption())
  final String code;

  @DeskNumber(description: 'Discount %', option: DeskNumberOption(min: 0, max: 100))
  final num discountPercent;

  @DeskDateTime(description: 'Expires at', option: DeskDateTimeOption())
  final DateTime expiresAt;

  @DeskImage(description: 'Artwork', option: DeskImageOption(hotspot: false))
  final ImageReference? image;

  @DeskMultiDropdown<String>(description: 'Tags', option: CouponTagsOption())
  final List<String> tags;

  const Coupon({
    required this.title,
    required this.code,
    required this.discountPercent,
    required this.expiresAt,
    this.image,
    required this.tags,
  });

  static Coupon defaultValue = Coupon(
    title: 'House wine by the glass',
    code: 'AURA-WINE',
    discountPercent: 100,
    expiresAt: DateTime(2026, 6, 30),
    tags: const ['Drinks'],
  );

  static Coupon $fromMap(Map<String, dynamic> map) => CouponMapper.fromMap(map);
}

class CouponTagsOption extends DeskMultiDropdownOption<String> {
  const CouponTagsOption({super.hidden});
  @override
  List<String>? get defaultValues => const [];
  @override
  int? get maxSelected => null;
  @override
  int? get minSelected => null;
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final t in couponTags) DropdownOption(value: t, label: t),
      ];
  @override
  String? get placeholder => 'Tags';
}
```

- [ ] **Step 3: Codegen + commit**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && git add -A && git commit -m "Add LoyaltyTier and Coupon shared types"
```

---

## Phase 4 — Screen configs

Each config registers its discriminator so the CMS app can round-trip JSON through `DeskContentMapper`. Each config has a rich `defaultValue` seeded from the JSX so the preview looks good with no CMS edits.

### Task 4.1: `HomeConfig`

**Files:**
- Create: `examples/data_models/lib/src/configs/home_config.dart`
- Modify: `examples/data_models/lib/example_data.dart`

- [ ] **Step 1: Write `home_config.dart`**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_copy.dart';
import '../shared/cta_action.dart';
import '../shared/featured_dish.dart';
import '../shared/store_callout.dart';
import 'desk_content.dart';

part 'home_config.desk.dart';
part 'home_config.mapper.dart';

@DeskModel(title: 'Home screen', description: 'Mobile home — hero, welcome, featured carousel, store card')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'homeConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class HomeConfig extends DeskContent with HomeConfigMappable, Serializable<HomeConfig> {
  @DeskImage(description: 'Hero image', option: DeskImageOption(hotspot: true))
  final ImageReference? heroImage;

  @DeskString(description: 'Hero eyebrow', option: DeskStringOption())
  final String heroEyebrow;

  @DeskText(description: 'Hero headline', option: DeskTextOption())
  final String heroHeadline;

  @DeskObject(description: 'Primary CTA')
  final CtaAction primaryCta;

  @DeskObject(description: 'Secondary CTA')
  final CtaAction secondaryCta;

  @DeskString(description: 'Location pill', option: DeskStringOption())
  final String locationLabel;

  @DeskString(description: 'Welcome greeting', option: DeskStringOption())
  final String welcomeGreeting;

  @DeskString(description: 'Featured section title', option: DeskStringOption())
  final String featuredSectionTitle;

  @DeskArray<FeaturedDish>(description: 'Featured dishes')
  final List<FeaturedDish> featuredDishes;

  @DeskObject(description: 'Store callout')
  final StoreCallout storeCallout;

  const HomeConfig({
    this.heroImage,
    required this.heroEyebrow,
    required this.heroHeadline,
    required this.primaryCta,
    required this.secondaryCta,
    required this.locationLabel,
    required this.welcomeGreeting,
    required this.featuredSectionTitle,
    required this.featuredDishes,
    required this.storeCallout,
  });

  static HomeConfig defaultValue = HomeConfig(
    heroImage: const ImageReference.external(AuraAssets.heroTable),
    heroEyebrow: AuraCopy.homeEyebrow,
    heroHeadline: AuraCopy.homeHeadline,
    primaryCta: const CtaAction(label: 'Order now', style: 'solid'),
    secondaryCta: const CtaAction(label: 'Reserve table', style: 'ghost'),
    locationLabel: AuraCopy.homeLocation,
    welcomeGreeting: AuraCopy.homeGreeting,
    featuredSectionTitle: AuraCopy.homeFeaturedTitle,
    featuredDishes: const [
      FeaturedDish(name: 'Charred Brassicas',   price: 16, tag: 'New',         image: ImageReference.external(AuraAssets.dish6)),
      FeaturedDish(name: "Orecchiette 'Nduja", price: 24, tag: "Chef's Pick", image: ImageReference.external(AuraAssets.dish7)),
      FeaturedDish(name: 'Olive Oil Cake',      price: 11, tag: 'Seasonal',    image: ImageReference.external(AuraAssets.dish5)),
      FeaturedDish(name: 'Citrus & Fennel',     price: 15, tag: 'Vegan',       image: ImageReference.external(AuraAssets.citrus)),
    ],
    storeCallout: StoreCallout.defaultValue,
  );
}
```

- [ ] **Step 2: Export + codegen**

Append to `example_data.dart`:
```dart
export 'src/configs/home_config.dart';
export 'src/shared/cta_action.dart';
export 'src/shared/featured_dish.dart';
export 'src/shared/store_callout.dart';
```

Run codegen:
```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && melos run analyze && git add -A && git commit -m "Add HomeConfig model"
```

### Task 4.2: `KioskConfig`

**Files:**
- Create: `examples/data_models/lib/src/configs/kiosk_config.dart`
- Modify: `examples/data_models/lib/example_data.dart`

- [ ] **Step 1: Write `kiosk_config.dart`**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_copy.dart';
import '../shared/kiosk_product.dart';
import '../shared/order_line.dart';
import 'desk_content.dart';

part 'kiosk_config.desk.dart';
part 'kiosk_config.mapper.dart';

@DeskModel(title: 'Kiosk screen', description: 'Tablet landscape in-store terminal')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'kioskConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class KioskConfig extends DeskContent with KioskConfigMappable, Serializable<KioskConfig> {
  @DeskImage(description: 'Banner image', option: DeskImageOption(hotspot: true))
  final ImageReference? bannerImage;

  @DeskString(description: 'Banner headline', option: DeskStringOption())
  final String bannerHeadline;

  @DeskText(description: 'Banner subtitle', option: DeskTextOption())
  final String bannerSubtitle;

  @DeskString(description: 'Promo badge', option: DeskStringOption())
  final String promoBadge;

  @DeskArray<KioskProduct>(description: 'Grid products')
  final List<KioskProduct> gridProducts;

  @DeskString(description: 'Table label', option: DeskStringOption())
  final String sidebarTableLabel;

  @DeskArray<OrderLine>(description: 'Sample order lines')
  final List<OrderLine> sidebarSampleOrder;

  @DeskText(description: 'Footer note', option: DeskTextOption())
  final String footerNote;

  const KioskConfig({
    this.bannerImage,
    required this.bannerHeadline,
    required this.bannerSubtitle,
    required this.promoBadge,
    required this.gridProducts,
    required this.sidebarTableLabel,
    required this.sidebarSampleOrder,
    required this.footerNote,
  });

  static KioskConfig defaultValue = KioskConfig(
    bannerImage: const ImageReference.external(AuraAssets.heroPlating),
    bannerHeadline: AuraCopy.kioskBannerHeadline,
    bannerSubtitle: AuraCopy.kioskBannerSubtitle,
    promoBadge: AuraCopy.kioskPromoBadge,
    gridProducts: const [
      KioskProduct(name: 'Signature Pasta',    price: 26, image: ImageReference.external(AuraAssets.dish10), category: 'Signature'),
      KioskProduct(name: 'Spring Crudo',       price: 21, image: ImageReference.external(AuraAssets.dish2),  category: 'Starter'),
      KioskProduct(name: 'Natural Wine Flight', price: 28, image: ImageReference.external(AuraAssets.wine),   category: 'Drink'),
      KioskProduct(name: 'Olive Oil Cake',     price: 11, image: ImageReference.external(AuraAssets.dish5),  category: 'Sweet'),
      KioskProduct(name: 'Charred Brassicas',  price: 16, image: ImageReference.external(AuraAssets.dish6),  category: 'Signature'),
      KioskProduct(name: 'Citrus & Fennel',    price: 15, image: ImageReference.external(AuraAssets.citrus), category: 'Starter'),
    ],
    sidebarTableLabel: AuraCopy.kioskTableLabel,
    sidebarSampleOrder: const [
      OrderLine(itemName: 'Signature Pasta',    qty: 2, price: 26),
      OrderLine(itemName: 'Natural Wine Flight', qty: 1, price: 28),
      OrderLine(itemName: 'Olive Oil Cake',     qty: 1, price: 11),
    ],
    footerNote: AuraCopy.kioskFooter,
  );
}
```

- [ ] **Step 2: Export + codegen + analyze + commit**

Append to `example_data.dart`:
```dart
export 'src/configs/kiosk_config.dart';
export 'src/shared/kiosk_product.dart';
export 'src/shared/order_line.dart';
```

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && melos run analyze && git add -A && git commit -m "Add KioskConfig model"
```

### Task 4.3: `ChefConfig`

**Files:**
- Create: `examples/data_models/lib/src/configs/chef_config.dart`
- Modify: `examples/data_models/lib/example_data.dart`

- [ ] **Step 1: Write `chef_config.dart`**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_copy.dart';
import '../shared/chef_profile.dart';
import '../shared/curated_dish.dart';
import 'desk_content.dart';

part 'chef_config.desk.dart';
part 'chef_config.mapper.dart';

@DeskModel(title: "Chef's Choice", description: 'Mobile upsell — curated list + pull-quote')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'chefConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class ChefConfig extends DeskContent with ChefConfigMappable, Serializable<ChefConfig> {
  @DeskText(description: 'Headline', option: DeskTextOption())
  final String headline;

  @DeskBlock(option: DeskBlockOption())
  final Object? intro;

  @DeskObject(description: 'Chef profile')
  final ChefProfile chef;

  @DeskText(description: 'Pull quote', option: DeskTextOption())
  final String pullQuote;

  @DeskArray<CuratedDish>(description: 'Curated dishes')
  final List<CuratedDish> curatedDishes;

  @DeskString(description: 'Refresh cadence label', option: DeskStringOption())
  final String refreshCadence;

  @DeskDate(description: 'Published from', option: DeskDateOption())
  final DateTime publishFrom;

  const ChefConfig({
    required this.headline,
    this.intro,
    required this.chef,
    required this.pullQuote,
    required this.curatedDishes,
    required this.refreshCadence,
    required this.publishFrom,
  });

  static ChefConfig defaultValue = ChefConfig(
    headline: AuraCopy.chefHeadline,
    chef: ChefProfile(
      name: AuraCopy.chefName,
      role: AuraCopy.chefRole,
      portrait: const ImageReference.external(AuraAssets.chefAlt),
      bio: ChefProfile.defaultValue.bio,
    ),
    pullQuote: AuraCopy.chefPullQuote,
    curatedDishes: const [
      CuratedDish(numberLabel: '01', name: 'Pea Tendril Agnolotti', price: 26, image: ImageReference.external(AuraAssets.dish10)),
      CuratedDish(numberLabel: '02', name: 'Whole Branzino',        price: 38, image: ImageReference.external(AuraAssets.dish11)),
      CuratedDish(numberLabel: '03', name: 'Olive Oil Cake',        price: 11, image: ImageReference.external(AuraAssets.dish5)),
    ],
    refreshCadence: AuraCopy.chefRefresh,
    publishFrom: DateTime(2026, 4, 15),
  );
}
```

- [ ] **Step 2: Export + codegen + analyze + commit**

Append to `example_data.dart`:
```dart
export 'src/configs/chef_config.dart';
export 'src/shared/chef_profile.dart';
export 'src/shared/curated_dish.dart';
```

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && melos run analyze && git add -A && git commit -m "Add ChefConfig model"
```

### Task 4.4: `MenuConfig`

**Files:**
- Create: `examples/data_models/lib/src/configs/menu_config.dart`
- Modify: `examples/data_models/lib/example_data.dart`

- [ ] **Step 1: Write `menu_config.dart`**

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_enums.dart';
import '../shared/menu_item_entry.dart';
import '../shared/store_hours_entry.dart';
import 'desk_content.dart';

part 'menu_config.desk.dart';
part 'menu_config.mapper.dart';

@DeskModel(title: 'Menu screen', description: 'Mobile menu browse with categories, filters, hours, location')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'menuConfig',
  includeCustomMappers: [ImageReferenceMapper()],
)
class MenuConfig extends DeskContent with MenuConfigMappable, Serializable<MenuConfig> {
  @DeskMultiDropdown<String>(description: 'Categories shown as tabs', option: MenuCategoriesOption())
  final List<String> categories;

  @DeskMultiDropdown<String>(description: 'Filter chip set', option: MenuFilterTagsOption())
  final List<String> filterTags;

  @DeskArray<MenuItemEntry>(description: 'Menu items')
  final List<MenuItemEntry> items;

  @DeskGeoPointFieldConfig(description: 'Store location')
  final GeoPoint? location;

  @DeskArray<StoreHoursEntry>(description: 'Weekly hours')
  final List<StoreHoursEntry> storeHours;

  const MenuConfig({
    required this.categories,
    required this.filterTags,
    required this.items,
    this.location,
    required this.storeHours,
  });

  static MenuConfig defaultValue = const MenuConfig(
    categories: ['Starters', 'Mains', 'Desserts', 'Drinks'],
    filterTags: ['Vegan', 'Gluten-free', "Chef's Pick"],
    items: [
      MenuItemEntry(name: 'Citrus & Fennel',       price: 15, shortDescription: 'Blood orange, fennel pollen, olive oil.', image: ImageReference.external(AuraAssets.citrus), tags: ['Vegan'], isAvailable: true),
      MenuItemEntry(name: "Orecchiette 'Nduja",    price: 24, shortDescription: "House pasta, spicy 'nduja, pecorino.",     image: ImageReference.external(AuraAssets.dish7),   tags: ["Chef's Pick"], isAvailable: true),
      MenuItemEntry(name: 'Pea Tendril Agnolotti', price: 26, shortDescription: "Sheep's milk, brown butter, lemon.",       image: ImageReference.external(AuraAssets.dish10),  tags: ['Seasonal'], isAvailable: true),
      MenuItemEntry(name: 'Whole Branzino',        price: 38, shortDescription: 'Salt-baked, green almond, fennel pollen.', image: ImageReference.external(AuraAssets.dish11),  tags: ['Gluten-free'], isAvailable: false),
      MenuItemEntry(name: 'Olive Oil Cake',        price: 11, shortDescription: 'Meyer lemon curd, candied pistachio.',     image: ImageReference.external(AuraAssets.dish5),   tags: ['Vegan'], isAvailable: true),
    ],
    location: GeoPoint(latitude: 40.7193, longitude: -74.0067),
    storeHours: [
      StoreHoursEntry(day: 'Mon', openTime: '17:00', closeTime: '23:00'),
      StoreHoursEntry(day: 'Tue', openTime: '17:00', closeTime: '23:00'),
      StoreHoursEntry(day: 'Wed', openTime: '17:00', closeTime: '23:30'),
      StoreHoursEntry(day: 'Thu', openTime: '17:00', closeTime: '23:30'),
      StoreHoursEntry(day: 'Fri', openTime: '17:00', closeTime: '00:30'),
      StoreHoursEntry(day: 'Sat', openTime: '12:00', closeTime: '00:30'),
      StoreHoursEntry(day: 'Sun', openTime: '12:00', closeTime: '22:00'),
    ],
  );
}

class MenuCategoriesOption extends DeskMultiDropdownOption<String> {
  const MenuCategoriesOption({super.hidden});
  @override
  List<String>? get defaultValues => const [];
  @override
  int? get maxSelected => null;
  @override
  int? get minSelected => 1;
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final c in menuCategories) DropdownOption(value: c, label: c),
      ];
  @override
  String? get placeholder => 'Categories';
}

class MenuFilterTagsOption extends DeskMultiDropdownOption<String> {
  const MenuFilterTagsOption({super.hidden});
  @override
  List<String>? get defaultValues => const [];
  @override
  int? get maxSelected => null;
  @override
  int? get minSelected => null;
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final t in menuFilterTags) DropdownOption(value: t, label: t),
      ];
  @override
  String? get placeholder => 'Filter tags';
}
```

- [ ] **Step 2: Export + codegen + analyze + commit**

Append to `example_data.dart`:
```dart
export 'src/configs/menu_config.dart';
export 'src/shared/menu_item_entry.dart';
export 'src/shared/store_hours_entry.dart';
```

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && melos run analyze && git add -A && git commit -m "Add MenuConfig model"
```

### Task 4.5: `RewardsConfig`

**Files:**
- Create: `examples/data_models/lib/src/configs/rewards_config.dart`
- Modify: `examples/data_models/lib/example_data.dart`

- [ ] **Step 1: Write `rewards_config.dart`**

```dart
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/aura_assets.dart';
import '../seed/aura_copy.dart';
import '../shared/coupon.dart';
import '../shared/loyalty_tier.dart';
import 'brand_theme.dart' show BrandThemeColorMapper;
import 'desk_content.dart';

part 'rewards_config.desk.dart';
part 'rewards_config.mapper.dart';

@DeskModel(title: 'Rewards screen', description: 'Mobile loyalty card + coupons')
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'rewardsConfig',
  includeCustomMappers: [ImageReferenceMapper(), BrandThemeColorMapper()],
)
class RewardsConfig extends DeskContent with RewardsConfigMappable, Serializable<RewardsConfig> {
  @DeskString(description: 'Program name', option: DeskStringOption())
  final String programName;

  @DeskArray<LoyaltyTier>(description: 'Tiers')
  final List<LoyaltyTier> tiers;

  @DeskNumber(description: 'Current user points (demo)', option: DeskNumberOption(min: 0))
  final num currentUserPoints;

  @DeskArray<Coupon>(description: 'Available coupons')
  final List<Coupon> coupons;

  @DeskUrl(description: 'Terms URL', option: DeskUrlOption())
  final String termsUrl;

  @DeskBlock(option: DeskBlockOption())
  final Object? fineprint;

  const RewardsConfig({
    required this.programName,
    required this.tiers,
    required this.currentUserPoints,
    required this.coupons,
    required this.termsUrl,
    this.fineprint,
  });

  static RewardsConfig defaultValue = RewardsConfig(
    programName: AuraCopy.rewardsProgram,
    tiers: const [
      LoyaltyTier(name: 'Cedar',   threshold: 0,    tierColor: Color(0xFF6B4E2E)),
      LoyaltyTier(name: 'Oakwood', threshold: 500,  tierColor: Color(0xFF496455)),
      LoyaltyTier(name: 'Aurelia', threshold: 1500, tierColor: Color(0xFFC67A4A)),
    ],
    currentUserPoints: 412,
    coupons: [
      Coupon(
        title: 'House wine by the glass',
        code: 'AURA-WINE',
        discountPercent: 100,
        expiresAt: DateTime(2026, 6, 30),
        image: const ImageReference.external(AuraAssets.wine),
        tags: const ['Drinks'],
      ),
      Coupon(
        title: 'Olive oil cake on the house',
        code: 'AURA-CAKE',
        discountPercent: 100,
        expiresAt: DateTime(2026, 5, 31),
        image: const ImageReference.external(AuraAssets.dish5),
        tags: const ['Dessert'],
      ),
      Coupon(
        title: 'Birthday prix fixe',
        code: 'AURA-BDAY',
        discountPercent: 25,
        expiresAt: DateTime(2026, 12, 31),
        image: const ImageReference.external(AuraAssets.heroDusk),
        tags: const ['Birthday', 'Food'],
      ),
    ],
    termsUrl: AuraCopy.rewardsTerms,
  );
}
```

- [ ] **Step 2: Export + codegen + analyze + commit**

Append to `example_data.dart`:
```dart
export 'src/configs/rewards_config.dart';
export 'src/shared/coupon.dart';
export 'src/shared/loyalty_tier.dart';
```

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs && cd ../.. && melos run analyze && git add -A && git commit -m "Add RewardsConfig model"
```

---

## Phase 5 — Shared Aura widgets

Ported from `~/Downloads/dart desk showcase/screens/frame.jsx` and `brand-standalone.jsx`. These are the atoms used by every screen. Keep each file focused and under ~150 lines.

### Task 5.1: `aura_tokens.dart`

**Files:**
- Create: `examples/example_app/lib/widgets/aura/aura_tokens.dart`

- [ ] **Step 1: Write the file**

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

/// Editorial tokens not expressible in Material 3 — soft tones used in the
/// Aura JSX that `ThemeData` alone can't carry.
///
/// Computed from [BrandTheme]. Call `AuraTokens.of(context)` inside any
/// subtree wrapped by [AuraTheme.wrap].
class AuraTokens extends InheritedWidget {
  final Color creamWarm;   // surface-1 / card
  final Color inkSoft;     // muted body text
  final Color mute;        // tertiary text
  final Color line;        // hairline border
  final Color greenDark;   // dark surface (chef quote card)

  const AuraTokens({
    super.key,
    required super.child,
    required this.creamWarm,
    required this.inkSoft,
    required this.mute,
    required this.line,
    required this.greenDark,
  });

  static AuraTokens of(BuildContext context) {
    final t = context.dependOnInheritedWidgetOfExactType<AuraTokens>();
    assert(t != null, 'AuraTokens.of() called outside an AuraTheme.wrap');
    return t!;
  }

  @override
  bool updateShouldNotify(AuraTokens old) =>
      creamWarm != old.creamWarm ||
      inkSoft != old.inkSoft ||
      mute != old.mute ||
      line != old.line ||
      greenDark != old.greenDark;
}
```

- [ ] **Step 2: Commit**

```bash
git add -A && git commit -m "Add AuraTokens inherited widget"
```

### Task 5.2: `aura_theme.dart`

**Files:**
- Create: `examples/example_app/lib/widgets/aura/aura_theme.dart`

- [ ] **Step 1: Write the file**

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

import 'aura_tokens.dart';

/// Wrap screens in the Aura Material theme + [AuraTokens].
class AuraTheme {
  /// Build a Material 3 [ThemeData] from [theme].
  static ThemeData dataFor(BrandTheme theme) {
    final scheme = ColorScheme.fromSeed(
      seedColor: theme.primaryColor,
      primary: theme.primaryColor,
      surface: theme.surfaceColor,
      onSurface: theme.inkColor,
      secondary: theme.accentColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: theme.surfaceColor,
      textTheme: _textTheme(theme),
    );
  }

  static TextTheme _textTheme(BrandTheme theme) {
    return TextTheme(
      displayLarge:  TextStyle(fontFamily: theme.headlineFont, color: theme.inkColor, fontStyle: FontStyle.italic),
      headlineLarge: TextStyle(fontFamily: theme.headlineFont, color: theme.inkColor, fontStyle: FontStyle.italic),
      headlineMedium:TextStyle(fontFamily: theme.headlineFont, color: theme.inkColor, fontStyle: FontStyle.italic),
      titleLarge:    TextStyle(fontFamily: theme.headlineFont, color: theme.inkColor, fontStyle: FontStyle.italic),
      bodyLarge:     TextStyle(fontFamily: theme.bodyFont, color: theme.inkColor),
      bodyMedium:    TextStyle(fontFamily: theme.bodyFont, color: theme.inkColor),
      labelLarge:    TextStyle(fontFamily: theme.bodyFont, color: theme.inkColor, fontWeight: FontWeight.w600),
    );
  }

  /// Wrap a subtree in both the [Theme] and [AuraTokens].
  static Widget wrap(BrandTheme theme, {required Widget child}) {
    return Theme(
      data: dataFor(theme),
      child: AuraTokens(
        creamWarm: _shift(theme.surfaceColor, -0.04),
        inkSoft:   _shift(theme.inkColor, 0.25),
        mute:      _shift(theme.inkColor, 0.45),
        line:      theme.inkColor.withOpacity(0.10),
        greenDark: _shift(theme.primaryColor, -0.12),
        child: child,
      ),
    );
  }

  static Color _shift(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add -A && git commit -m "Add AuraTheme wrapper"
```

### Task 5.3: `photo.dart`

**Files:**
- Create: `examples/example_app/lib/widgets/aura/photo.dart`

- [ ] **Step 1: Write the file**

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

/// Image with rounded corners, `BoxFit.cover`, and an optional overlay.
/// Accepts a [dart_desk] [ImageReference] or a fallback URL.
class Photo extends StatelessWidget {
  final ImageReference? reference;
  final String? fallbackUrl;
  final double? width;
  final double? height;
  final double radius;
  final Widget? overlay;

  const Photo({
    super.key,
    this.reference,
    this.fallbackUrl,
    this.width,
    this.height,
    this.radius = 14,
    this.overlay,
  });

  String? get _url {
    final ref = reference;
    if (ref == null) return fallbackUrl;
    return ref.map(
      external: (e) => e.url,
      asset: (a) => a.assetUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = _url;
    final child = url == null
        ? Container(color: const Color(0xFFECE3D0))
        : Image.network(url, fit: BoxFit.cover, width: width, height: height);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(fit: StackFit.passthrough, children: [
        SizedBox(width: width, height: height, child: child),
        if (overlay != null) Positioned.fill(child: overlay!),
      ]),
    );
  }
}
```

> **Note:** `ImageReference.map(external:, asset:)` matches the `dart_desk` API. If the actual method names differ, use the package's accessor for the URL — check `packages/dart_desk/lib/src/image_reference.dart`. The goal is: return `url` for external refs, `assetUrl` (or equivalent) for uploaded refs.

- [ ] **Step 2: Commit**

```bash
git add -A && git commit -m "Add Photo widget"
```

### Task 5.4: `aura_button.dart` + `aura_wordmark.dart` + `aura_icon_button.dart`

**Files:**
- Create: `examples/example_app/lib/widgets/aura/aura_button.dart`
- Create: `examples/example_app/lib/widgets/aura/aura_wordmark.dart`
- Create: `examples/example_app/lib/widgets/aura/aura_icon_button.dart`

- [ ] **Step 1: `aura_button.dart`**

```dart
import 'package:flutter/material.dart';

enum AuraButtonStyle { solid, dark, ghost }

class AuraButton extends StatelessWidget {
  final String label;
  final AuraButtonStyle style;
  final VoidCallback? onPressed;
  final bool showArrow;

  const AuraButton({
    super.key,
    required this.label,
    this.style = AuraButtonStyle.solid,
    this.onPressed,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, border) = switch (style) {
      AuraButtonStyle.solid => (scheme.primary, scheme.surface, null),
      AuraButtonStyle.dark  => (scheme.surface, scheme.onSurface, null),
      AuraButtonStyle.ghost => (Colors.transparent, scheme.surface, Border.all(color: scheme.surface.withOpacity(0.45))),
    };
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: border?.top ?? BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: TextStyle(color: fg, fontSize: 14.5, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
            if (showArrow) ...[
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward, size: 14, color: fg),
            ],
          ]),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `aura_wordmark.dart`**

```dart
import 'package:flutter/material.dart';

class AuraWordmark extends StatelessWidget {
  final Color color;
  final double size;
  final bool showSub;

  const AuraWordmark({
    super.key,
    required this.color,
    this.size = 18,
    this.showSub = true,
  });

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.titleLarge?.fontFamily;
    final body = Theme.of(context).textTheme.bodyMedium?.fontFamily;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Aura',
          style: TextStyle(
            fontFamily: headline, color: color, fontSize: size,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, letterSpacing: 0.4, height: 1,
          ),
        ),
        if (showSub) ...[
          const SizedBox(height: 3),
          Text('GASTRONOMY',
            style: TextStyle(
              fontFamily: body, color: color.withOpacity(0.7), fontSize: size * 0.42,
              fontWeight: FontWeight.w600, letterSpacing: 2, height: 1,
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 3: `aura_icon_button.dart`**

```dart
import 'package:flutter/material.dart';

import 'aura_tokens.dart';

class AuraIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const AuraIconButton({super.key, required this.icon, this.onPressed, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final tokens = AuraTokens.of(context);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size / 2),
        side: BorderSide(color: tokens.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onPressed ?? () {},
        child: SizedBox(
          width: size, height: size,
          child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "Add AuraButton, AuraWordmark, AuraIconButton"
```

### Task 5.5: `mobile_frame.dart` + `tablet_frame.dart`

**Files:**
- Create: `examples/example_app/lib/widgets/aura/mobile_frame.dart`
- Create: `examples/example_app/lib/widgets/aura/tablet_frame.dart`

Reference: `~/Downloads/dart desk showcase/screens/frame.jsx` lines 4–74 (mobile frame + status bar).

- [ ] **Step 1: `mobile_frame.dart`**

```dart
import 'package:flutter/material.dart';

/// 390×844 iOS-style phone frame — rounded corners, dynamic island,
/// status bar (9:41), home indicator. Matches the design artboard.
class MobileFrame extends StatelessWidget {
  final Widget child;
  final Color? background;
  final bool darkChrome;

  const MobileFrame({
    super.key,
    required this.child,
    this.background,
    this.darkChrome = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? scheme.surface;
    final chromeColor = darkChrome ? Colors.white : scheme.onSurface;

    return Container(
      width: 390,
      height: 844,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(48),
        boxShadow: const [
          BoxShadow(color: Color(0x2E000000), offset: Offset(0, 40), blurRadius: 80),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned.fill(child: child),
        // Dynamic island
        Positioned(
          top: 11, left: 0, right: 0,
          child: Center(
            child: Container(
              width: 126, height: 37,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
        // Status bar
        Positioned(
          top: 21, left: 34, right: 34,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('9:41', style: TextStyle(color: chromeColor, fontSize: 17, fontWeight: FontWeight.w600)),
            Row(children: [
              Icon(Icons.signal_cellular_alt, size: 14, color: chromeColor),
              const SizedBox(width: 6),
              Icon(Icons.wifi, size: 14, color: chromeColor),
              const SizedBox(width: 6),
              Icon(Icons.battery_full, size: 14, color: chromeColor),
            ]),
          ]),
        ),
        // Home indicator
        Positioned(
          bottom: 8, left: 0, right: 0,
          child: Center(
            child: Container(
              width: 139, height: 5,
              decoration: BoxDecoration(
                color: (darkChrome ? Colors.white : Colors.black).withOpacity(0.28),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
```

- [ ] **Step 2: `tablet_frame.dart`**

```dart
import 'package:flutter/material.dart';

/// 1194×834 landscape iPad-style frame for the Kiosk screen.
class TabletFrame extends StatelessWidget {
  final Widget child;
  const TabletFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 1194, height: 834,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x2E000000), offset: Offset(0, 40), blurRadius: 80),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "Add MobileFrame and TabletFrame"
```

### Task 5.6: `aura_tab_bar.dart`

**Files:**
- Create: `examples/example_app/lib/widgets/aura/aura_tab_bar.dart`

Reference: `frame.jsx` lines 77–115.

- [ ] **Step 1: Write the file**

```dart
import 'package:flutter/material.dart';

import 'aura_tokens.dart';

class AuraTabItem {
  final String id;
  final String label;
  final IconData icon;
  const AuraTabItem(this.id, this.label, this.icon);
}

class AuraTabBar extends StatelessWidget {
  final String active;
  const AuraTabBar({super.key, required this.active});

  static const items = [
    AuraTabItem('home',    'Home',    Icons.home_outlined),
    AuraTabItem('menu',    'Menu',    Icons.menu),
    AuraTabItem('rewards', 'Rewards', Icons.star_outline),
    AuraTabItem('account', 'Account', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = AuraTokens.of(context);
    return Positioned(
      left: 12, right: 12, bottom: 28,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(38),
          border: Border.all(color: scheme.onSurface.withOpacity(0.06)),
          boxShadow: const [
            BoxShadow(color: Color(0x1E1B1433), offset: Offset(0, 12), blurRadius: 30),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final it in items)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(it.icon, size: 22,
                    color: it.id == active ? scheme.onSurface : tokens.mute),
                  const SizedBox(height: 4),
                  Text(it.label, style: TextStyle(
                    fontSize: 10,
                    fontWeight: it.id == active ? FontWeight.w700 : FontWeight.w500,
                    color: it.id == active ? scheme.onSurface : tokens.mute,
                    letterSpacing: 0.3,
                  )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze, commit**

```bash
melos run analyze && git add -A && git commit -m "Add AuraTabBar"
```

---

## Phase 6 — Screens

Each screen widget is a `StatelessWidget` with two required params: its config and the `BrandTheme`. It wraps in `AuraTheme.wrap` and returns a frame containing the scrollable content. Visual fidelity target: indistinguishable from the JSX at the artboard dimensions.

**Pattern for every screen:**

```dart
class XyzScreen extends StatelessWidget {
  final XyzConfig config;
  final BrandTheme theme;
  const XyzScreen({super.key, required this.config, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AuraTheme.wrap(theme,
      child: Builder(builder: (context) => MobileFrame(child: _body(context))),
    );
  }

  Widget _body(BuildContext context) { /* layout */ }
}
```

### Task 6.1: `HomeScreen`

**Files:**
- Create: `examples/example_app/lib/screens/home_screen.dart`

Reference: `~/Downloads/dart desk showcase/screens/home.jsx` — hero (540 tall), welcome strip, featured carousel, store card, TabBar.

- [ ] **Step 1: Write `home_screen.dart`**

Build the widget following the JSX layout. Key sections, top to bottom:

1. **Hero** (`Stack`, height 540): `Photo(reference: config.heroImage)` full bleed, linear gradient overlay (top fade + bottom dark), row at top with `AuraWordmark` + pill "📍 Tribeca", bottom column with eyebrow, multi-line italic headline (fontSize 44, Noto Serif, italic, lineHeight 1.02), and a row with two `AuraButton` (solid dark + ghost).
2. **Welcome strip**: `Row` with 46×46 circular cream avatar with italic serif "J", two-line text (greeting small muted, points italic serif 17), chevron icon. Padding `EdgeInsets.fromLTRB(24, 0, 24, 22)`.
3. **Featured section header**: accent eyebrow "THIS WEEK" + italic serif title from config + "See all" link, padding `EdgeInsets.symmetric(horizontal: 24)`.
4. **Featured carousel**: horizontal scroll of 200-wide cards; each has a 240-tall `Photo` (radius 20) with tag pill overlay top-left, then dish name (italic serif 16) and price (accent color, italic serif 13). Spacing 14.
5. **Store card**: dark green container with rounded 20 radius, margin `EdgeInsets.fromLTRB(20, 26, 20, 0)`, padding 18; contains a 52 square avatar ("A" serif italic), column with venue name + "Open till 11:30pm · 0.4 mi away" muted, "Directions" pill chip.
6. **TabBar**: `AuraTabBar(active: 'home')` positioned above the scroll.

Use `SingleChildScrollView` for the body. `AuraTokens.of(context)` for `creamWarm`, `mute`, `inkSoft`, `line`. Color accents come from `Theme.of(context).colorScheme.secondary` (clay).

- [ ] **Step 2: Hook it up for analysis**

Don't wire to CMS app yet — will happen in Phase 7. For now, import in a smoke test to confirm it builds.

- [ ] **Step 3: Smoke test**

Create `examples/example_app/test/home_screen_smoke_test.dart`:

```dart
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen renders default config', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: HomeScreen(config: HomeConfig.defaultValue, theme: BrandTheme.defaultValue)),
      ),
    ));
    expect(find.text('A table\nfor the\nlong evening.'), findsOneWidget);
    expect(find.text('Order now'), findsOneWidget);
  });
}
```

Run: `cd examples/example_app && flutter test test/home_screen_smoke_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && git add -A && git commit -m "Add HomeScreen"
```

### Task 6.2: `KioskScreen`

**Files:**
- Create: `examples/example_app/lib/screens/kiosk_screen.dart`

Reference: `~/Downloads/dart desk showcase/screens/kiosk.jsx` — landscape 3-panel layout: nav rail left (64 wide), main panel (banner + 3-col product grid), order sidebar right (~360 wide).

- [ ] **Step 1: Write `kiosk_screen.dart`**

Layout (inside `TabletFrame`, `Row`):

1. **Left rail** (width 80): vertical column with `AuraWordmark` at top, icon buttons for categories (signature, drinks, sweets), a settings icon at bottom.
2. **Main panel** (flex): `Column`:
   - **Banner** (height 280, rounded 20): `Photo(reference: config.bannerImage)` with overlay — promo badge pill top-left, bottom column with `config.bannerHeadline` (italic serif, 36pt) + `config.bannerSubtitle` (14pt 70% opacity).
   - **Product grid**: `GridView` 3 columns, spacing 16, each tile has a 160-tall `Photo` top + name (italic serif 18) + price (accent 15 serif) + category label (small muted caps) + "Add" CTA chip.
3. **Right sidebar** (width 360): `Column` in primary-tinted container, header "TABLE 12" caps + "Your order" italic serif, then `config.sidebarSampleOrder` mapped to rows (name + qty × price), total row, primary CTA button "Send to kitchen", `config.footerNote` text at bottom in muted italic.

Spacing and sizes tuned for 1194×834 artboard.

- [ ] **Step 2: Smoke test**

```dart
// examples/example_app/test/kiosk_screen_smoke_test.dart
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/kiosk_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KioskScreen renders default config', (tester) async {
    tester.view.physicalSize = const Size(1194, 834);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: KioskScreen(config: KioskConfig.defaultValue, theme: BrandTheme.defaultValue))),
    ));
    expect(find.text('Spring, plated.'), findsOneWidget);
    expect(find.text('Table 12'), findsOneWidget);
  });
}
```

Run, expected PASS.

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "Add KioskScreen"
```

### Task 6.3: `ChefScreen`

**Files:**
- Create: `examples/example_app/lib/screens/chef_screen.dart`

Reference: `~/Downloads/dart desk showcase/screens/chef.jsx`.

- [ ] **Step 1: Write the widget**

Layout inside `MobileFrame` (bg = surface). Use `CustomScrollView` or a `Stack` with a sticky header:

1. **Sticky header** (abs top, 56 pad top): row with `AuraIconButton(Icons.arrow_back_ios_new)`, centered tracked caps "CHEF'S CHOICE" in primary color, `AuraIconButton(Icons.bookmark_outline)`.
2. **Title block** (padding 24): italic serif 40pt `config.headline` (respects newlines), 14pt muted description below (from `config.chef.bio`).
3. **Pull-quote card** (margin 20, dark green bg, radius 24, padding 28): huge "❝" glyph at top-left with 12% opacity cream, `config.pullQuote` italic serif 22pt cream, divider, row with 52 circle portrait `Photo(reference: config.chef.portrait)` + name italic serif 15 + role uppercase 11.5 70% opacity + a play-icon-in-circle on the right.
4. **Curated list** (`ListView` of 3 items): each a `Row` grid 118:1fr:
   - 118-wide `Photo(reference: dish.image)` height 150 radius 14 with "01" badge bottom-left.
   - Title (italic serif 19) + price (accent serif 16) aligned to baseline, description (block text rendered as plain text for now, 12.5 muted 1.5 line-height), bottom row with "Add to order" primary pill + "single serving" muted 11.
5. **Outro**: centered italic "— a curation refreshed every Thursday —" (from `config.refreshCadence`).
6. **TabBar**: `AuraTabBar(active: 'menu')`.

For the `config.description` (block field) rendering, use a helper that extracts plain text from the block JSON: if block is `null` or empty, skip; otherwise flatten text children. Keep it naive — 20 lines of helper at the bottom of the file is fine.

- [ ] **Step 2: Smoke test**

```dart
// examples/example_app/test/chef_screen_smoke_test.dart
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/chef_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChefScreen renders default config', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: ChefScreen(config: ChefConfig.defaultValue, theme: BrandTheme.defaultValue))),
    ));
    expect(find.textContaining('Three dishes'), findsOneWidget);
    expect(find.text('Marco Vespucci'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "Add ChefScreen"
```

### Task 6.4: `MenuScreen`

**Files:**
- Create: `examples/example_app/lib/screens/menu_screen.dart`

Reference: `~/Downloads/dart desk showcase/screens/menu.jsx`.

- [ ] **Step 1: Write the widget**

Inside `MobileFrame`:

1. **Top bar** (padding 24, top 56): row with search icon button, centered "Menu" italic serif title, location icon button.
2. **Category tabs**: horizontal scroll of `config.categories` strings rendered as tappable text — active one dark ink, rest muted. Underline beneath active.
3. **Filter chips**: horizontal scroll of `config.filterTags` as pill chips.
4. **Items list**: for each `MenuItemEntry`:
   - Row with 96×96 `Photo(reference: item.image)` radius 14 left.
   - Column: name italic serif 18, short description 12.5 muted 2-line clamp, price (accent serif 16) + tag chips (small pills) + if `!isAvailable` a greyed "Sold out" pill.
   - Muted opacity 0.5 on the whole row if `!isAvailable`.
5. **Footer card** (margin 20, radius 20, dark green bg, padding 18): "Visit us in Tribeca" headline + distance via `location` (display as "40.72°N, 74.01°W") + a collapsed hours preview from the first two `storeHours` entries + "Directions" pill.
6. **TabBar**: `AuraTabBar(active: 'menu')`.

- [ ] **Step 2: Smoke test** (same shape as the previous two)

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "Add MenuScreen"
```

### Task 6.5: `RewardsScreen`

**Files:**
- Create: `examples/example_app/lib/screens/rewards_screen.dart`

Reference: `~/Downloads/dart desk showcase/screens/rewards.jsx`.

- [ ] **Step 1: Write the widget**

Inside `MobileFrame`:

1. **Header** (padding 24, top 56): `AuraWordmark` small + ticker pill "{points} pts" in primary.
2. **Loyalty hero card** (margin 20, padding 24, radius 24, primary bg, cream text): `config.programName` uppercase tracked small, italic serif 40 "{points} points", then a tier progress bar — find current tier (highest whose `threshold <= currentUserPoints`) and next tier; bar width = `points / nextTier.threshold`; label "One tier to {nextTier.name}" italic serif 14.
3. **Tier list** (3 rows): for each `tier` a row with a colored swatch (`tier.tierColor`), name italic serif, `threshold` small muted. Active tier has accent ring.
4. **Coupons section header**: "YOUR COUPONS" eyebrow + italic "Use them before they go" serif.
5. **Coupon stack**: vertical list, each:
   - Container cream-warm bg, radius 18, padding 16, row.
   - Left: 60×60 `Photo(reference: coupon.image)` radius 12.
   - Middle column: title italic serif 16, `coupon.code` mono 12 muted, tag chips row, expiry "Expires {MMM d}" small.
   - Right: `{discountPercent}% off` badge in accent color.
6. **Fineprint**: block rendered as plain text 11 muted with a link "Terms" to `termsUrl`.
7. **TabBar**: `AuraTabBar(active: 'rewards')`.

- [ ] **Step 2: Smoke test** (same shape)

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "Add RewardsScreen"
```

---

## Phase 7 — CMS app integration

### Task 7.1: Register document types

**Files:**
- Modify: `examples/desk_app/lib/document_types.dart`

- [ ] **Step 1: Rewrite `document_types.dart`**

```dart
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:example_app/screens/chef_screen.dart';
import 'package:example_app/screens/home_screen.dart';
import 'package:example_app/screens/kiosk_screen.dart';
import 'package:example_app/screens/menu_screen.dart';
import 'package:example_app/screens/rewards_screen.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (data) {
    final merged = {...BrandTheme.defaultValue.toMap(), ...data};
    return BrandThemeScreen(config: BrandThemeMapper.fromMap(merged));
  },
);

final homeDocumentType = homeConfigTypeSpec.build(
  builder: (data) {
    final merged = {...HomeConfig.defaultValue.toMap(), ...data};
    return HomeScreen(
      config: HomeConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);

final kioskDocumentType = kioskConfigTypeSpec.build(
  builder: (data) {
    final merged = {...KioskConfig.defaultValue.toMap(), ...data};
    return KioskScreen(
      config: KioskConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);

final chefDocumentType = chefConfigTypeSpec.build(
  builder: (data) {
    final merged = {...ChefConfig.defaultValue.toMap(), ...data};
    return ChefScreen(
      config: ChefConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);

final menuDocumentType = menuConfigTypeSpec.build(
  builder: (data) {
    final merged = {...MenuConfig.defaultValue.toMap(), ...data};
    return MenuScreen(
      config: MenuConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);

final rewardsDocumentType = rewardsConfigTypeSpec.build(
  builder: (data) {
    final merged = {...RewardsConfig.defaultValue.toMap(), ...data};
    return RewardsScreen(
      config: RewardsConfigMapper.fromMap(merged),
      theme: BrandTheme.defaultValue,
    );
  },
);
```

> **Note on live brand theme propagation:** This wiring passes `BrandTheme.defaultValue` — not the currently-edited theme. Full reactivity (editing BrandTheme reflects on the other 5 previews) is out of scope for this plan; the current wiring matches how the existing app passes defaults. Revisit if needed.

- [ ] **Step 2: Update `main.dart`**

Register all six `*DocumentType` constants in the CMS app's navigation. Match the existing pattern in `main.dart` — add one nav entry per doc type with an appropriate icon (`home`, `tv_rounded` for kiosk, `restaurant`, `menu`, `star`, `palette` for brand theme).

- [ ] **Step 3: Analyze, run app smoke**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && melos run analyze
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "Register Aura document types in CMS app"
```

---

## Phase 8 — BrandTheme preview rebuild

### Task 8.1: Rebuild `brand_theme_screen.dart`

**Files:**
- Modify: `examples/example_app/lib/screens/brand_theme_screen.dart`

- [ ] **Step 1: Design the preview**

The BrandTheme screen becomes a "living style guide" that demonstrates the theme applied across representative mini-previews.

Layout (inside `AuraTheme.wrap(config, child: ...)`):

1. **Hero strip**: primary-colored header with `AuraWordmark(color: surface)` + small tagline "Brand Theme · live".
2. **Color palette row**: four square swatches for `primaryColor`, `surfaceColor`, `accentColor`, `inkColor` with hex labels.
3. **Typography sample**: headline italic "A table for the long evening." (48pt, headlineFont) + body "Manrope or the configured body font at 16pt regular. Quick brown fox jumps…" (16pt, bodyFont).
4. **Buttons row**: one `AuraButton.solid` + one `AuraButton.ghost` (over a primary block so ghost reads) + one `AuraButton.dark`.
5. **Card sample**: a small Photo + dish name + price in a rounded card at the configured `cornerRadius`.
6. **Logo preview**: if `config.logo` is set, render via `Photo`; else placeholder "No logo uploaded".

Keep it ~200 lines. The point is to show "this one document drives everything."

- [ ] **Step 2: Write the code**

Replace the stub `BrandThemeScreen` with the above layout. Use `AuraTheme.wrap(config, child: Builder(builder: ...))` as the outer wrapper so `AuraTokens.of(context)` works inside.

- [ ] **Step 3: Smoke test**

```dart
// examples/example_app/test/brand_theme_screen_smoke_test.dart
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BrandThemeScreen renders default config', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: BrandThemeScreen(config: BrandTheme.defaultValue))),
    ));
    expect(find.textContaining('Aura'), findsWidgets);
  });
}
```

- [ ] **Step 4: Analyze, run all tests, commit**

```bash
melos run analyze
cd examples/example_app && flutter test
cd ../.. && git add -A && git commit -m "Rebuild BrandThemeScreen as living style guide"
```

---

## Phase 9 — Final verification

### Task 9.1: End-to-end analyze + test + run

- [ ] **Step 1: Analyze workspace**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk && melos run analyze
```

Expected: PASS across all packages.

- [ ] **Step 2: Run all tests**

```bash
melos run test
```

Expected: all smoke tests PASS.

- [ ] **Step 3: Launch the CMS app**

Use the dart MCP (`mcp__dart__launch_app`) to launch `examples/desk_app/`. Navigate through each of the six document types and verify:
- BrandTheme preview renders with the palette swatches and typography sample.
- Home, Kiosk, Chef, Menu, Rewards each render their default config visually.
- No runtime errors, no red screens, no missing images.

- [ ] **Step 4: Final commit (if any tweaks)**

```bash
git add -A && git commit -m "Verify Aura showcase end-to-end" --allow-empty
```

---

## Notes for the implementer

- **Codegen is the single most common failure mode.** After every `@DeskModel` / `@MappableClass` change, run `dart run build_runner build --delete-conflicting-outputs` from `examples/data_models/`. Don't skip this step — the `.desk.dart` and `.mapper.dart` files produce the `*TypeSpec`, `*Mapper.fromMap`, and `*Mappable` mixins everything else depends on.
- **Order matters.** Shared types (Phase 3) must compile before configs (Phase 4) that reference them. Widget layer (Phase 5) must exist before screens (Phase 6). Don't jump ahead.
- **Visual fidelity is "close to the JSX," not pixel-perfect.** Flutter's text rendering and Material widgets will differ slightly from CSS. Target: a dev looking at both side-by-side would say "same app."
- **Block field rendering is naive.** For `intro`, `description`, `perks`, `fineprint`: extract plain text with a flat helper. Rich-text rendering (bold/italic/links) is out of scope.
- **If `ImageReference.external` constructor name differs**, check `packages/dart_desk/lib/src/image_reference.dart` for the correct factory (likely `.external(url)` or `.url(url)` or similar). Adjust all `defaultValue` calls accordingly.
- **Don't refactor the CMS app's navigation shell.** Just register doc types in the same pattern the existing code uses.
