# Example Showcase Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all 5 existing CMS example data models and preview screens with new ones based on 4 HTML reference designs (kiosk, hero, upsell, reward) plus a brand theme model.

**Architecture:** 5 data models with `@DeskModel` annotations + code generation, 4 seed data files for dropdown options, 5 Flutter preview widgets faithfully recreating the HTML reference designs. A prerequisite task adds `DeskMultiDropdown` annotation support to the generator since it doesn't exist yet.

**Tech Stack:** Flutter, dart_desk annotations, dart_mappable, build_runner code generation, shadcn_ui

**Spec:** `docs/superpowers/specs/2026-04-03-example-showcase-redesign-design.md`

**HTML References:** `examples/kiosk.html`, `examples/hero.html`, `examples/upsell.html`, `examples/reward.html`

---

## File Map

### Packages (dart_desk core — prerequisite)
- Create: `packages/dart_desk_annotation/lib/src/fields/complex/multi_dropdown_field_config.dart`
- Modify: `packages/dart_desk_annotation/lib/dart_desk_annotation.dart` (add export)
- Modify: `packages/dart_desk_generator/lib/src/generators/desk_field_generator.dart` (add handler)

### Data Models
- Delete: `examples/data_models/lib/src/configs/storefront_config.dart` (+ `.mapper.dart`, `.desk.dart`)
- Delete: `examples/data_models/lib/src/configs/menu_highlight.dart` (+ generated)
- Delete: `examples/data_models/lib/src/configs/promo_offer.dart` (+ generated)
- Delete: `examples/data_models/lib/src/configs/app_theme.dart` (+ generated)
- Delete: `examples/data_models/lib/src/configs/delivery_settings.dart` (+ generated)
- Create: `examples/data_models/lib/src/seed/seed_data.dart`
- Create: `examples/data_models/lib/src/configs/brand_theme.dart`
- Create: `examples/data_models/lib/src/configs/kiosk_config.dart`
- Create: `examples/data_models/lib/src/configs/hero_config.dart`
- Create: `examples/data_models/lib/src/configs/upsell_config.dart`
- Create: `examples/data_models/lib/src/configs/reward_config.dart`
- Modify: `examples/data_models/lib/example_data.dart` (update exports)

### Preview Widgets
- Delete: `examples/example_app/lib/screens/storefront_preview.dart`
- Delete: `examples/example_app/lib/screens/menu_highlight_card.dart`
- Delete: `examples/example_app/lib/screens/promo_offer_banner.dart`
- Delete: `examples/example_app/lib/screens/app_theme_preview.dart`
- Delete: `examples/example_app/lib/screens/delivery_settings_view.dart`
- Create: `examples/example_app/lib/screens/brand_theme_preview.dart`
- Create: `examples/example_app/lib/screens/kiosk_preview.dart`
- Create: `examples/example_app/lib/screens/hero_preview.dart`
- Create: `examples/example_app/lib/screens/upsell_preview.dart`
- Create: `examples/example_app/lib/screens/reward_preview.dart`

### Integration
- Modify: `examples/desk_app/lib/document_types.dart`
- Modify: `examples/desk_app/lib/main.dart`

---

### Task 1: Add DeskMultiDropdown annotation + generator support

The annotation package has `DeskMultiDropdownField` and `DeskMultiDropdownOption` but no `DeskMultiDropdown` annotation class for the code generator. The generator's `_fieldConfigs` map has no entry for it. We need both.

**Files:**
- Create: `packages/dart_desk_annotation/lib/src/fields/complex/multi_dropdown_field_config.dart`
- Modify: `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`
- Modify: `packages/dart_desk_generator/lib/src/generators/desk_field_generator.dart`

- [ ] **Step 1: Create the annotation class**

Create `packages/dart_desk_annotation/lib/src/fields/complex/multi_dropdown_field_config.dart`:

```dart
import '../base/field.dart';
import 'dropdown_field.dart';

/// Annotation to mark a `List<T>` field as a multi-select dropdown in the CMS.
///
/// Requires a [DeskMultiDropdownOption<T>] to supply the available options.
class DeskMultiDropdown<T> extends DeskFieldConfig {
  const DeskMultiDropdown({
    super.name,
    super.title,
    super.description,
    required DeskMultiDropdownOption<T> super.option,
  });

  @override
  List<Type> get supportedFieldTypes => [List<T>];
}
```

- [ ] **Step 2: Export from the annotation barrel**

In `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`, find the existing export for `dropdown_field.dart` and add the new export next to it:

```dart
export 'src/fields/complex/multi_dropdown_field_config.dart';
```

- [ ] **Step 3: Add the generator handler**

In `packages/dart_desk_generator/lib/src/generators/desk_field_generator.dart`, add a new entry to the `_fieldConfigs` map right after the `'DeskDropdown'` entry (after line 413). The pattern mirrors the existing dropdown handler:

```dart
    'DeskMultiDropdown': (
      FieldElement field,
      DartObject? config, [
      String? optionSource,
    ]) {
      final fieldName = field.name!;

      // Extract the generic type from DeskMultiDropdown<T>
      final configType = config?.type?.toString() ?? '';
      final genericTypeMatch = RegExp(
        r'DeskMultiDropdown<(.+?)>',
      ).firstMatch(configType);
      final genericType = genericTypeMatch?.group(1) ?? 'dynamic';

      return '''DeskMultiDropdownField<$genericType>(
    name: '$fieldName',
    title: '${_titleCase(fieldName)}',
    ${optionSource != null ? 'option: $optionSource,' : ''}
  )''';
    },
```

- [ ] **Step 4: Verify the generator compiles**

```bash
cd packages/dart_desk_generator && dart analyze lib/
```

Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk_annotation/lib/src/fields/complex/multi_dropdown_field_config.dart
git add packages/dart_desk_annotation/lib/dart_desk_annotation.dart
git add packages/dart_desk_generator/lib/src/generators/desk_field_generator.dart
git commit -m "feat: add DeskMultiDropdown annotation and generator support"
```

---

### Task 2: Delete old data models and preview screens

**Files:**
- Delete: all old config files and their generated files in `examples/data_models/lib/src/configs/`
- Delete: all old screen files in `examples/example_app/lib/screens/`

- [ ] **Step 1: Delete old data model files**

```bash
cd examples/data_models/lib/src/configs/
rm storefront_config.dart storefront_config.mapper.dart storefront_config.desk.dart
rm menu_highlight.dart menu_highlight.mapper.dart menu_highlight.desk.dart
rm promo_offer.dart promo_offer.mapper.dart promo_offer.desk.dart
rm app_theme.dart app_theme.mapper.dart app_theme.desk.dart
rm delivery_settings.dart delivery_settings.mapper.dart delivery_settings.desk.dart
```

- [ ] **Step 2: Delete old preview screens**

```bash
cd examples/example_app/lib/screens/
rm storefront_preview.dart menu_highlight_card.dart promo_offer_banner.dart app_theme_preview.dart delivery_settings_view.dart
```

- [ ] **Step 3: Commit**

```bash
git add -A examples/data_models/lib/src/configs/ examples/example_app/lib/screens/
git commit -m "chore: remove old example data models and preview screens"
```

---

### Task 3: Create seed data

All seed data lives in a single file for simplicity. Each seed data class is plain Dart (no annotations). Dropdown options reference these by key.

**Files:**
- Create: `examples/data_models/lib/src/seed/seed_data.dart`

- [ ] **Step 1: Create the seed data file**

Create `examples/data_models/lib/src/seed/seed_data.dart` with all product and coupon seed data. This file defines simple data classes and lookup maps used by both the dropdown options and the preview widgets.

```dart
import 'package:flutter/material.dart';

// ── Product seed data ──────────────────────────────────────────────────

class SeedProduct {
  final String key;
  final String name;
  final double price;
  final String description;
  final List<String> tags;
  final int calories;
  final String imageUrl;

  const SeedProduct({
    required this.key,
    required this.name,
    required this.price,
    required this.description,
    this.tags = const [],
    this.calories = 0,
    required this.imageUrl,
  });
}

const kioskProducts = [
  SeedProduct(
    key: 'truffle_risotto',
    name: 'Black Truffle Risotto',
    price: 34.50,
    description:
        'Arborio rice slow-cooked with forest mushrooms, finished with 24-month aged parmesan and freshly shaved Perigord truffles.',
    tags: ['Vegetarian', 'Gluten-Free'],
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC55Kc61wukj2x-5tEdMbGBbK2Ac7ybF-9uaflz3tRjCTNLINl77QVrJm5BDeOu8GNG1y2YZMaaip7_xn8meK6pNGJxWfiP60VvuqeV9CbdppwiOXQX1CtI48TUv4wufYlNHNrLp7lcBCtAA-0h5Dc8ZSi83XGDepLpYbib_MM0ug6HtR6VG8EPW0ESTZ2Xe1h74DdpA-QMt083BRjvl37D1geMPgYpn94nG7tJs0zNbBLJE2S9_96aoyY_KAKXLn9RboVgctA7eQc',
  ),
  SeedProduct(
    key: 'heritage_scallops',
    name: 'Heritage Scallops',
    price: 28.00,
    description:
        'Hand-dived Atlantic scallops, parsnip velvet, and crispy pancetta soil.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBO6ZQsbMv6ymfDux8DDzJQ8ZdaONc-5NYQuT91O2u75qxMPYFB3y-caU19vuIXWj70CilshFt8T7HBXAJmAwGnEefm9rIyUgKizvZ5lCN06TD52Yw_Y8mspwmT8cMnx0etleN5YHypMJ3ti17lwu5zC5g__4nL3I6TWwNxD6cEJMV0L5CZo7DmftrZ2dPFp7iRZIb4ytu0A671h9Tcwlk--_b8E5aLFlRJ38qGLeFcBiCAcxa2OSSHXbSuIJmV6-V7fkuPb1bX0hQ',
  ),
  SeedProduct(
    key: 'cherry_duck',
    name: 'Cherry Glazed Duck',
    price: 42.00,
    description:
        'Roasted breast, confit leg croquette, and dark cherry reduction.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAg8XhvBkUgJfr1wM7JztNsuOD1ewfd3tcqEcN54r4yKNZqkB3vZ_hAw3cvwVAn26vRvq1oOT85oD6LMrwb2Ad3vs3xkNXavc2hUENoPF_SN1yJg-9WOf7mzCF9G1q8oizLWgBcevOIByCoYBAodHZsuw_TkmqWMwFt1n8uPbcB9jfjfHqf91c4fURloN_43YzZEKSxHql1knzADMZ5HKb1tGUSvDuub0z1jlIhs0rj3fLPbsAreTs80OPwSeGyae14MUFjo-7lUfI',
  ),
  SeedProduct(
    key: 'valrhona_fondant',
    name: 'Valrhona Fondant',
    price: 16.00,
    description:
        '70% Dark chocolate, molten center, and Tahitian vanilla bean cream.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBBMLG0_CElO9XwTUIQkM-i7crsB86_ZWkdyfaEBwXNch-gDLizH2CjW80VomdcBvFn7ZKmWJTu1OVY_z9A9GZXW4FOHZd5gRPuEfLPuE1zV6f4T06PX_0InTZFwUQRG_wGFsTQPd07mcZLv6MthHosxX25wcam1tcs8FCoXUiSryAaNic1s3jDIbrFgcBIzk0ga-AQPiMUpNms0bBZeEPO5CbJEn291I65LA5xmDMYF02JT-u0djsvtRFHjOIDuDcuwfrQr2ySZL0',
  ),
];

const heroProducts = [
  SeedProduct(
    key: 'roasted_turkey',
    name: 'Roasted Turkey Platter',
    price: 84.00,
    description: 'Slow-roasted whole turkey with cranberries and rosemary.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAT40v_sLw55b4SL27WdbIGcMv-BTVIgtGUCG8gFyI1w3fh6cg1tFcGVVFJsnObLhuyaR9qs-JuYVHz8WNipg9ebgqbYx841FbxdzYdi0UoyNYK4Wagola1TONbdw67tMDWTPlJCJg5jglUaGspnWi8rPwsMpo2A0pTa-eZpAiSSnJjzzXMMgHFS_jy3-X6bEWkXkc8kesLVXKY78a2ferzojQ8eC4_YwZ3jBNkoD443TzdtkNe2PvRRJHLZA-bF6GlQ9LONN6vnEA',
  ),
  SeedProduct(
    key: 'berry_tart',
    name: 'Berry Mascarpone Tart',
    price: 12.50,
    description: 'Delicate tart with fresh raspberries and blueberries.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCk4oVPQvBD9eXfcVXuqTIcVknK1ib_lbkGTNySdCYgul9SW3feUxXgLqCMU4XZshDABYLna23CMIH2EP3s-vlOShcfp7sm6DHL1faBsDzEIWfZ1DKU_tg6n197MZ9n8K0QNDhEKJadl_U6teM45pb9dfheGn_U1MO_Sfl9p4eMiWQBcJhjLU7lpgpkEaHgPd_QWkikdlNUdhdCPpNCjOTanZi0HSy7fNMpy42cmPL_oTwzlnqlo6juJ1kowZ8jESApfGAOaptp8k8',
  ),
  SeedProduct(
    key: 'mulled_wine',
    name: 'Seasonal Mulled Wine',
    price: 14.00,
    description: 'Festive spiced wine with cinnamon and orange.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCg-plghUaaB7VtjJmWgxLtZoN8OTvWVZHS4IdVwCgtvNcfKtDGuIKqq-Gg4qEDbjkxHxucz4VjXf3kYd4Ugkf14Mbqo10PzSVtShft8nYnx4TaiZquqFTfKfZte0--Qb1Zzs-qjU-kcVlqxZ-RT13m6jGMO6fOM1tekW5LHEVOQFZiuqho7DrWVPLBwTaflvPdKq_8HImT0moBAzQ3WHPapcl-mdRS7aqA8J8bhTtv5Lt7wC_zG7JU23JOcgYQ1Rze23hQHvPShsQ',
  ),
  SeedProduct(
    key: 'glazed_ham',
    name: 'Honey Glazed Ham',
    price: 58.00,
    description: 'Honey glazed ham with cloves and grilled pineapple.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC_m-Oeg69KUjrxHeJMNaMnERp0eaL6TDDLMW-If9pq3d1qMQspy18B2XVfXRk_hn8jXccE0INqMOU0QaZGEiDEpJ7GCbVZC7eit6PrfJCGpaJXhXm9o4J1iFX9Nd9jgB3TFVZryn6H3cs-vZitw3Gr-GMN2HxYUuxkp6wEIuSUd1D6HVbgZME9VPQvxQknSC21drMGViNX3DBAMsNiJTQNXhtlhD71noFrEX8dT8NLQnG-klppzsuvICxCXyYTPHX8X7PHVDOZFvk',
  ),
];

const upsellProducts = [
  SeedProduct(
    key: 'wagyu_burger',
    name: 'Truffle Wagyu Burger',
    price: 32.00,
    description: 'Aged wagyu, winter truffle, brioche.',
    calories: 840,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAu4ogJ4MAs_MaWwB9bQZqCF-59LibpwudjHdRE5VW8ZrKtmArHKX7h7u66fryOlilCGbbc5K7WD_ieBiulMFqhTZ7Jw7L-8C_Ulc0C6tkSbOD1Xc016ancSHOKd77NC1o7gYJPrnbQ4RVMf7q8ZG1aEfXBlqFcWjzDHH7X6_JdmyZz0xNe4vVZONDiEKSYRCLSWeHX2A1CuraR5AcqcoVF11Z_L18vJwVzEAqS31OBv0pRNZzRb9TRRyvDr_5CJjhAEObqqqrZwDI',
  ),
  SeedProduct(
    key: 'linguine_vongole',
    name: 'Linguine Alle Vongole',
    price: 28.50,
    description: 'Wild clams, white wine, parsley oil.',
    calories: 620,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAwE7IzIb2bPaeRMkAvHnmILdJGo7wmjBfdyA9ldN7xL4Df90a6jCae9ubfvi5YK0S4oPYiwb4GuCV3gBD0fVlaoJ3fBYHvQWD9esf_TK6y7xH-oGN3es91KcuZ30C8PCBi5A8hngDZl-4bDq2ZqKfrNARMMNIEP2QG5aKbW3KahxFKzhnpZ0oUGXYWKFMYSNbDiWbEOebHsabeYnLlXdvLaWFv18Qtkzyucxik7pe3JTMJVBNdfdgEonQ8TfADMBluJrRgVdqARx4',
  ),
  SeedProduct(
    key: 'hokkaido_scallops',
    name: 'Hokkaido Scallops',
    price: 36.00,
    description: 'Pan-seared, cauliflower, brown butter.',
    calories: 410,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBRkegIh8K2cX6HjewmYXVIH0uyBuPaskUTBhoMyrxn04IF8SX-x-6n0w3HPRBsd8uDdhmUvmohVlEILHc4jIObUird1m-0feKSmkD92Gg1kjWnjtJlW12SAmZ7aFkZk0uuJMSQjc4oy-KKtLPQtMG_zQK_JmsTJC42-Cd0oprgQSNGjiMEzppXlx7F4_7rK1IWHgerMa1144cr-vpObHWWyUEqYDBfY2isEsKR16bWBKWH7I0pOAMDS5Vq3mKv3b3hoDIdem7tDS4',
  ),
  SeedProduct(
    key: 'dry_aged_ribeye',
    name: 'Dry-Aged Ribeye',
    price: 54.00,
    description: '45-day aged, bone marrow butter.',
    calories: 950,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBjyS_NLlXFORBEgP_P20yaARsT_v1ns6tlb6hxIFXEWFEJlBpyiBant39NsjDwbQhIMAL1wXNLQ410wArWfHr5IWZoJ-SpIKtdfZGeiihhxXrso0E8omaOpS2dPsyZIOyJzAssG5XIu6dglzC8wEoVGIbvSFzr2MDFu9Swp61zjOtAj0vxhvUqwqqy8KdKB8OiStqM30q94gnzr0yDMSvXd27m8FJ-ExQBKPyBfLp5B62h_6ueGlfuUUljp91z495FrF0w6IZyTXo',
  ),
];

// ── Coupon seed data ───────────────────────────────────────────────────

class SeedCoupon {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final String condition;
  final bool locked;

  const SeedCoupon({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.condition,
    this.locked = false,
  });
}

const seedCoupons = [
  SeedCoupon(
    key: 'festive_mains',
    title: '20% Off Festive Mains',
    description: 'Valid on all seasonal signature dishes this week.',
    icon: Icons.restaurant,
    condition: 'Expires in 2 days',
  ),
  SeedCoupon(
    key: 'free_drink',
    title: 'Free Drink with Any Order',
    description:
        'Choose from our curated winter cocktail list or house mocktails.',
    icon: Icons.local_bar,
    condition: 'Minimum Spend \$25.00',
  ),
  SeedCoupon(
    key: 'dessert_platter',
    title: 'Holiday Dessert Platter',
    description: 'Unlock this reward at Gold tier membership.',
    icon: Icons.lock,
    condition: 'Requires 5,000 total points',
    locked: true,
  ),
];

// ── Lookup helpers ─────────────────────────────────────────────────────

SeedProduct? lookupProduct(String key, List<SeedProduct> products) {
  for (final p in products) {
    if (p.key == key) return p;
  }
  return null;
}

SeedCoupon? lookupCoupon(String key) {
  for (final c in seedCoupons) {
    if (c.key == key) return c;
  }
  return null;
}

// ── Shared image URLs ──────────────────────────────────────────────────

const kioskBannerImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAQzrN87Tvd8S8Ym8ettmmvaYIOIze5Lb-Mr4pLxLUjCHk4XR5MltVpW4CLSSLj_74ro2XRS341LGXF_UBe7i8m2A5phCMjSv6oz06psNilGoB2XK7VjX0rPJRDNsVQmWG2VUb9V3WQNgxkuI5vdtSuKYzGbUK757KqHFfsYy70Z1SrJwPvOT5QJe9gRX4sLGPas6TIn0fXpM_1VASSAhzcfQa_raKi5-bP0XZM6E_0Tl8zqCbCUDqiSpkRKzoNdY2QiKClnqQdE0I';

const kioskOrderRisottoThumbUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCZTU3lbdfR46MFHHfHF-wX5Nm3NuiDlS7QN4u-bZSF3Ful7n10NuyMbVXQZKS096oNvbRBdwko5nVEncUbKvhHmWyXQ6jIX3-t2JWp2Yes25P-4XlQCB1QU7jIpafXWQtrqq1JWWuKFICJODp0qvs2JWrxqRe5JyJnGU7P3g4CQYryGIDxQJZs1B-RNlLyumvzn5MjknjSm8yDVNioHf2wCtb2jVLQAFrNL56YniOkNzs8JilKT24aUn7DZI5auFLGu5OK5f42Dbs';

const kioskOrderScallopsThumbUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBIHhscrh4u94_69aTY0G5VPnPCY5H7O3JTITTwRnrq0AcyVrA0vmgwVLKnwsyNeshQAlcjmbY00DHvXwiVe7QqXLrCcuYP9uDW1-iQA00FBtbTZts1jG4JXq0n0a6O1-sotOrQRnAD027Lpg8d8v7ujvkAsJil_rVZ3YMQzrqeQJvESX1fFHJmipD1Xgwoesg5ckMbZhdovW5t3Un13ptufHsyzjhICNaGJw9uMZhkkKaCrfCkQTpx5lxJeZUe4ypksqjjvSg4pC4';

const heroBackgroundImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD4sfUJtVO96YI82Ie3tQlRae8apQDGMEfIeTberImKMS1bmZU2A99l-VrK5VoS05wgARcetQ7uU_Xczj6CD6ber-rYgTqXf_Zylu6EKw0ykCCn89TD2HXFGGFBeY-ExOCXYYnPpjNJPqvSnunra1C2AcBcnMoPFBC8evQYvxjMmnBuz-fdeW-NtHrnlrEIOi4tFSNUCNX6-fxKB2vVP8fi6gtLQR46Lj7CZKrlitLZNTpBuNYL8LcTDoMCMCOmcaMVGzwL9dBdm38';

const profileAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAadtuOwfKN3oBAcPOWdIUgQLsNlAnxU3IxNhRA8J04Rtz1GIoZA8Bhv5b9R8suR6_mtZ3Uaqd8hNC6KxHkHDy0rw76tb8CCtXAfDQMGIXwOPdfMWXI-ahXNk01eHBjm_ITy-gR5Tuco1yo3o06_uKL83ivY59ONcAnk2voEqasdr_fB5g5NGyrKDqM1JI1XHLrvFzirFhI3VjMBeOgj_lpGWXauHG2lPH8pickvVF_4tjjElXM1GEuvUGatBGjgZeuX8gH0LdFpoI';
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/seed/seed_data.dart
git commit -m "feat: add seed data for products and coupons"
```

---

### Task 4: Create BrandTheme data model

No multi-dropdown needed here — just colors, strings, number, and a single dropdown.

**Files:**
- Create: `examples/data_models/lib/src/configs/brand_theme.dart`

- [ ] **Step 1: Create the data model**

Create `examples/data_models/lib/src/configs/brand_theme.dart`:

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'brand_theme.desk.dart';
part 'brand_theme.mapper.dart';

@DeskModel(
  title: 'Brand Theme',
  description: 'Global brand colors, typography, and styling for the Aura Gastronomy app',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [BrandThemeColorMapper()])
class BrandTheme with BrandThemeMappable, Serializable<BrandTheme> {
  @DeskColor(
    description: 'Primary brand color used for buttons, nav, and accents',
    option: DeskColorOption(),
  )
  final Color primaryColor;

  @DeskColor(
    description: 'Surface/background color for the app',
    option: DeskColorOption(),
  )
  final Color surfaceColor;

  @DeskColor(
    description: 'Primary text color',
    option: DeskColorOption(),
  )
  final Color textColor;

  @DeskString(
    description: 'Font family for headlines (e.g. Noto Serif)',
    option: DeskStringOption(),
  )
  final String headlineFont;

  @DeskString(
    description: 'Font family for body text (e.g. Manrope)',
    option: DeskStringOption(),
  )
  final String bodyFont;

  @DeskNumber(
    description: 'Corner radius for cards and buttons in pixels',
    option: DeskNumberOption(min: 0, max: 24),
  )
  final num cornerRadius;

  @DeskDropdown<String>(
    description: 'App theme mode',
    option: ThemeModeDropdownOption(),
  )
  final String themeMode;

  const BrandTheme({
    required this.primaryColor,
    required this.surfaceColor,
    required this.textColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    required this.themeMode,
  });

  static BrandTheme defaultValue = BrandTheme(
    primaryColor: const Color(0xFF496455),
    surfaceColor: const Color(0xFFFAF9F7),
    textColor: const Color(0xFF2F3331),
    headlineFont: 'Noto Serif',
    bodyFont: 'Manrope',
    cornerRadius: 8,
    themeMode: 'light',
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

class ThemeModeDropdownOption extends DeskDropdownOption<String> {
  const ThemeModeDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'light';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        DropdownOption(value: 'light', label: 'Light'),
        DropdownOption(value: 'dark', label: 'Dark'),
        DropdownOption(value: 'system', label: 'System'),
      ]);

  @override
  String? get placeholder => 'Select theme mode';
}
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/configs/brand_theme.dart
git commit -m "feat: add BrandTheme data model"
```

---

### Task 5: Create KioskConfig data model

Uses `DeskMultiDropdown` for product selection.

**Files:**
- Create: `examples/data_models/lib/src/configs/kiosk_config.dart`

- [ ] **Step 1: Create the data model**

Create `examples/data_models/lib/src/configs/kiosk_config.dart`:

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';

part 'kiosk_config.desk.dart';
part 'kiosk_config.mapper.dart';

@DeskModel(
  title: 'Kiosk Screen',
  description: 'Desktop 3-panel kiosk layout with product grid and order sidebar',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [KioskColorMapper(), ImageReferenceMapper()])
class KioskConfig with KioskConfigMappable, Serializable<KioskConfig> {
  @DeskString(
    description: 'Restaurant name shown in the nav drawer',
    option: DeskStringOption(),
  )
  final String restaurantName;

  @DeskString(
    description: 'Banner headline text',
    option: DeskStringOption(),
  )
  final String bannerTitle;

  @DeskText(
    description: 'Banner description text below the headline',
    option: DeskTextOption(rows: 2),
  )
  final String bannerSubtitle;

  @DeskImage(
    description: 'Banner background image',
    option: DeskImageOption(hotspot: false),
  )
  final ImageReference? bannerImage;

  @DeskMultiDropdown<String>(
    description: 'Products to display in the kiosk grid',
    option: KioskProductsDropdownOption(),
  )
  final List<String> products;

  const KioskConfig({
    required this.restaurantName,
    required this.bannerTitle,
    required this.bannerSubtitle,
    this.bannerImage,
    required this.products,
  });

  static KioskConfig defaultValue = KioskConfig(
    restaurantName: 'Aura Kiosk',
    bannerTitle: 'New Year Specials',
    bannerSubtitle:
        'Curated flavors to welcome the dawn of a new season. Experience artisanal culinary craftsmanship.',
    bannerImage: null,
    products: ['truffle_risotto', 'heritage_scallops', 'cherry_duck', 'valrhona_fondant'],
  );
}

class KioskColorMapper extends SimpleMapper<Color> {
  const KioskColorMapper();

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

class KioskProductsDropdownOption extends DeskMultiDropdownOption<String> {
  const KioskProductsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues =>
      ['truffle_risotto', 'heritage_scallops', 'cherry_duck', 'valrhona_fondant'];

  @override
  int? get maxSelected => 4;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final p in kioskProducts)
          DropdownOption(value: p.key, label: '${p.name} (\$${p.price.toStringAsFixed(2)})'),
      ]);

  @override
  String? get placeholder => 'Select products';
}
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/configs/kiosk_config.dart
git commit -m "feat: add KioskConfig data model"
```

---

### Task 6: Create HeroConfig data model

**Files:**
- Create: `examples/data_models/lib/src/configs/hero_config.dart`

- [ ] **Step 1: Create the data model**

Create `examples/data_models/lib/src/configs/hero_config.dart`:

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';

part 'hero_config.desk.dart';
part 'hero_config.mapper.dart';

@DeskModel(
  title: 'Hero Screen',
  description: 'Mobile home screen with hero image, categories, and featured products',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [HeroColorMapper(), ImageReferenceMapper()])
class HeroConfig with HeroConfigMappable, Serializable<HeroConfig> {
  @DeskString(
    description: 'Main headline in the hero section',
    option: DeskStringOption(),
  )
  final String heroTitle;

  @DeskText(
    description: 'Description text below the hero title',
    option: DeskTextOption(rows: 2),
  )
  final String heroSubtitle;

  @DeskImage(
    description: 'Background image for the hero section',
    option: DeskImageOption(hotspot: false),
  )
  final ImageReference? heroImage;

  @DeskString(
    description: 'Call-to-action button label',
    option: DeskStringOption(),
  )
  final String ctaLabel;

  @DeskMultiDropdown<String>(
    description: 'Featured products to display in the grid',
    option: HeroProductsDropdownOption(),
  )
  final List<String> products;

  const HeroConfig({
    required this.heroTitle,
    required this.heroSubtitle,
    this.heroImage,
    required this.ctaLabel,
    required this.products,
  });

  static HeroConfig defaultValue = HeroConfig(
    heroTitle: 'The Festive Feast is Here',
    heroSubtitle: 'Limited Seasonal Selection',
    heroImage: null,
    ctaLabel: 'Explore the Menu',
    products: ['roasted_turkey', 'berry_tart', 'mulled_wine', 'glazed_ham'],
  );
}

class HeroColorMapper extends SimpleMapper<Color> {
  const HeroColorMapper();

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

class HeroProductsDropdownOption extends DeskMultiDropdownOption<String> {
  const HeroProductsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues =>
      ['roasted_turkey', 'berry_tart', 'mulled_wine', 'glazed_ham'];

  @override
  int? get maxSelected => 4;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final p in heroProducts)
          DropdownOption(value: p.key, label: '${p.name} (\$${p.price.toStringAsFixed(2)})'),
      ]);

  @override
  String? get placeholder => 'Select featured products';
}
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/configs/hero_config.dart
git commit -m "feat: add HeroConfig data model"
```

---

### Task 7: Create UpsellConfig data model

**Files:**
- Create: `examples/data_models/lib/src/configs/upsell_config.dart`

- [ ] **Step 1: Create the data model**

Create `examples/data_models/lib/src/configs/upsell_config.dart`:

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';

part 'upsell_config.desk.dart';
part 'upsell_config.mapper.dart';

@DeskModel(
  title: 'Upsell Screen',
  description: 'Mobile Chef\'s Choice curated item list with editorial pull-quote',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [UpsellColorMapper()])
class UpsellConfig with UpsellConfigMappable, Serializable<UpsellConfig> {
  @DeskString(
    description: 'Section title (e.g. Chef\'s Choice)',
    option: DeskStringOption(),
  )
  final String sectionTitle;

  @DeskText(
    description: 'Subtitle text below the section title',
    option: DeskTextOption(rows: 2),
  )
  final String sectionSubtitle;

  @DeskText(
    description: 'Pull-quote text displayed between product items',
    option: DeskTextOption(rows: 3),
  )
  final String quoteText;

  @DeskString(
    description: 'Attribution name for the pull-quote',
    option: DeskStringOption(),
  )
  final String chefName;

  @DeskMultiDropdown<String>(
    description: 'Chef\'s choice products to feature',
    option: UpsellProductsDropdownOption(),
  )
  final List<String> products;

  const UpsellConfig({
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.quoteText,
    required this.chefName,
    required this.products,
  });

  static UpsellConfig defaultValue = UpsellConfig(
    sectionTitle: "Chef's Choice",
    sectionSubtitle:
        'Hand-selected seasonal masterpieces defined by precision and local ingredients.',
    quoteText:
        'Cuisine is the bridge between nature and culture. Every selection here tells a story of the harvest.',
    chefName: 'Executive Chef Elara',
    products: ['wagyu_burger', 'linguine_vongole', 'hokkaido_scallops', 'dry_aged_ribeye'],
  );
}

class UpsellColorMapper extends SimpleMapper<Color> {
  const UpsellColorMapper();

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

class UpsellProductsDropdownOption extends DeskMultiDropdownOption<String> {
  const UpsellProductsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues =>
      ['wagyu_burger', 'linguine_vongole', 'hokkaido_scallops', 'dry_aged_ribeye'];

  @override
  int? get maxSelected => 4;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final p in upsellProducts)
          DropdownOption(value: p.key, label: '${p.name} (\$${p.price.toStringAsFixed(2)})'),
      ]);

  @override
  String? get placeholder => 'Select chef\'s picks';
}
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/configs/upsell_config.dart
git commit -m "feat: add UpsellConfig data model"
```

---

### Task 8: Create RewardConfig data model

**Files:**
- Create: `examples/data_models/lib/src/configs/reward_config.dart`

- [ ] **Step 1: Create the data model**

Create `examples/data_models/lib/src/configs/reward_config.dart`:

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';

part 'reward_config.desk.dart';
part 'reward_config.mapper.dart';

@DeskModel(
  title: 'Reward Screen',
  description: 'Mobile loyalty rewards with points card and coupon list',
)
@MappableClass(ignoreNull: false, includeCustomMappers: [RewardColorMapper()])
class RewardConfig with RewardConfigMappable, Serializable<RewardConfig> {
  @DeskString(
    description: 'Brand name shown in the header',
    option: DeskStringOption(),
  )
  final String brandName;

  @DeskNumber(
    description: 'Current loyalty points balance',
    option: DeskNumberOption(min: 0, max: 100000),
  )
  final num pointsBalance;

  @DeskNumber(
    description: 'Points needed for the next reward',
    option: DeskNumberOption(min: 0, max: 100000),
  )
  final num nextRewardThreshold;

  @DeskString(
    description: 'Label for the next reward (e.g. Festive Tasting Menu)',
    option: DeskStringOption(),
  )
  final String rewardLabel;

  @DeskMultiDropdown<String>(
    description: 'Coupons to display in the rewards screen',
    option: CouponsDropdownOption(),
  )
  final List<String> coupons;

  const RewardConfig({
    required this.brandName,
    required this.pointsBalance,
    required this.nextRewardThreshold,
    required this.rewardLabel,
    required this.coupons,
  });

  static RewardConfig defaultValue = RewardConfig(
    brandName: 'Aura Gastronomy',
    pointsBalance: 2450,
    nextRewardThreshold: 3000,
    rewardLabel: 'Festive Tasting Menu',
    coupons: ['festive_mains', 'free_drink', 'dessert_platter'],
  );
}

class RewardColorMapper extends SimpleMapper<Color> {
  const RewardColorMapper();

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

class CouponsDropdownOption extends DeskMultiDropdownOption<String> {
  const CouponsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues =>
      ['festive_mains', 'free_drink', 'dessert_platter'];

  @override
  int? get maxSelected => 3;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final c in seedCoupons)
          DropdownOption(value: c.key, label: c.title),
      ]);

  @override
  String? get placeholder => 'Select coupons';
}
```

- [ ] **Step 2: Commit**

```bash
git add examples/data_models/lib/src/configs/reward_config.dart
git commit -m "feat: add RewardConfig data model"
```

---

### Task 9: Update barrel file and run code generation

**Files:**
- Modify: `examples/data_models/lib/example_data.dart`

- [ ] **Step 1: Update the barrel file**

Replace the contents of `examples/data_models/lib/example_data.dart` with:

```dart
library;

export 'src/configs/brand_theme.dart' hide BrandThemeColorMapper;
export 'src/configs/kiosk_config.dart' hide KioskColorMapper;
export 'src/configs/hero_config.dart' hide HeroColorMapper;
export 'src/configs/upsell_config.dart' hide UpsellColorMapper;
export 'src/configs/reward_config.dart' hide RewardColorMapper;
export 'src/seed/seed_data.dart';
```

- [ ] **Step 2: Run code generation**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs
```

Expected: Generates `.mapper.dart` and `.desk.dart` for all 5 new models. No errors.

- [ ] **Step 3: Verify analysis passes**

```bash
cd examples/data_models && dart analyze lib/
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add examples/data_models/
git commit -m "feat: update barrel file and run code generation for new models"
```

---

### Task 10: Create BrandThemePreview widget

**Files:**
- Create: `examples/example_app/lib/screens/brand_theme_preview.dart`

- [ ] **Step 1: Create the preview widget**

Create `examples/example_app/lib/screens/brand_theme_preview.dart`. This widget shows color swatches, typography previews, a sample food card, and settings summary — referencing `brand_theme.dart` fields.

Read `examples/upsell.html` for the Aura aesthetic and color tokens. The preview should use `config.primaryColor`, `config.surfaceColor`, `config.textColor`, `config.headlineFont`, `config.bodyFont`, `config.cornerRadius`, and `config.themeMode`.

Key layout:
- Header with restaurant icon + "Theme Preview" title
- Color swatch row: 3 expanded containers showing primary, surface, text colors with hex labels
- Typography section: headline font sample in serif, body font sample in sans
- Sample food card: white card with shadow, food item name, description, price in primary color, "Add to Cart" FilledButton
- Primary + outlined button row
- Settings summary rows: theme mode, corner radius, headline font, body font

- [ ] **Step 2: Commit**

```bash
git add examples/example_app/lib/screens/brand_theme_preview.dart
git commit -m "feat: add BrandThemePreview widget"
```

---

### Task 11: Create KioskPreview widget

**Files:**
- Create: `examples/example_app/lib/screens/kiosk_preview.dart`

- [ ] **Step 1: Create the preview widget**

Create `examples/example_app/lib/screens/kiosk_preview.dart`. This is the most complex preview — a 3-panel desktop layout faithfully recreating `examples/kiosk.html`.

Read `examples/kiosk.html` as the reference. The widget receives `KioskConfig config` and looks up products from `kioskProducts` seed data using `lookupProduct()`.

Key structure (use `Row` with 3 sections):
- **Left nav** (w=288, fixed): primary-colored brand name, 4 nav buttons (Dine In active with primary bg, Takeaway/Seasonal/Support inactive), wait time card at bottom
- **Center** (flexible, scrollable): banner header with `Image.network` + gradient overlay + title/subtitle, category tab bar, bento grid using nested `Row`/`Column` or `Wrap` — 1 large card (8/12 width, split image+details), 1 small card (4/12), 1 small card (4/12), 1 horizontal card (8/12)
- **Right sidebar** (w=400, fixed): "Your Order" header, 2 static order items with thumbnails from `kioskOrderRisottoThumbUrl`/`kioskOrderScallopsThumbUrl`, quantity controls, totals, "Place Order" button

Use the Aura color tokens: primary `#496455`, surface `#FAF9F7`, on-surface `#2F3331`, etc.

- [ ] **Step 2: Commit**

```bash
git add examples/example_app/lib/screens/kiosk_preview.dart
git commit -m "feat: add KioskPreview widget"
```

---

### Task 12: Create HeroPreview widget

**Files:**
- Create: `examples/example_app/lib/screens/hero_preview.dart`

- [ ] **Step 1: Create the preview widget**

Create `examples/example_app/lib/screens/hero_preview.dart`. Mobile single-column layout from `examples/hero.html`.

Key structure:
- Top app bar: hamburger icon + italic "Aura Gastronomy" + circular profile avatar from `profileAvatarUrl`
- Hero section: `AspectRatio(4/5)` with circular clip, `heroImage` or `heroBackgroundImageUrl` fallback, gradient overlay bottom-to-top, "Limited Seasonal Selection" label, `config.heroTitle`, CTA button with `config.ctaLabel` + arrow icon
- Category pills: horizontal `ListView` of 5 circular icon buttons (Starters, Mains active, Festive Treats, Drinks, Bakery)
- "Featured Today" header with vertical accent bar
- 2-column staggered grid: 4 product cards from seed data. Odd column offset with top padding. Each card: 3:4 aspect image with "+" FAB overlay, name, price.
- Pull-quote section: centered italic serif text + "The Aura Manifesto" attribution
- Bottom nav bar: Home (active), Menu, Cart, Profile — using Material icons

- [ ] **Step 2: Commit**

```bash
git add examples/example_app/lib/screens/hero_preview.dart
git commit -m "feat: add HeroPreview widget"
```

---

### Task 13: Create UpsellPreview widget

**Files:**
- Create: `examples/example_app/lib/screens/upsell_preview.dart`

- [ ] **Step 1: Create the preview widget**

Create `examples/example_app/lib/screens/upsell_preview.dart`. Mobile list layout from `examples/upsell.html`.

Key structure:
- Top app bar (same as HeroPreview)
- Centered editorial header: "Monthly Curation" uppercase label, `config.sectionTitle` in large serif, thin divider, `config.sectionSubtitle`
- Product list: 4 items from seed data. Each is a horizontal card (1/3 image left, 2/3 content right). Content: "Chef's Choice" gradient badge + calories label, name in serif, description, price + cart icon button. Items at index 0 and 3 use tertiary-container bg (`#F9F3EA`), items 1 and 2 use white bg.
- Pull-quote card: between items 2 and 3. Centered italic text `config.quoteText` + `config.chefName` attribution.
- Bottom nav (Home, Menu active, Cart, Profile)

- [ ] **Step 2: Commit**

```bash
git add examples/example_app/lib/screens/upsell_preview.dart
git commit -m "feat: add UpsellPreview widget"
```

---

### Task 14: Create RewardPreview widget

**Files:**
- Create: `examples/example_app/lib/screens/reward_preview.dart`

- [ ] **Step 1: Create the preview widget**

Create `examples/example_app/lib/screens/reward_preview.dart`. Mobile layout from `examples/reward.html`.

Key structure:
- Top app bar (same as HeroPreview)
- Loyalty card: Container with primary color bg, decorative semi-transparent circles (positioned overflow), "Seasonal Loyalty" uppercase label, "Holiday Rewards" serif header, `config.pointsBalance` large bold number + "Aura Points" label, `config.nextRewardThreshold` with "Next Reward" label on the right, progress bar (width = pointsBalance/nextRewardThreshold ratio), italic text "{remaining} points until your {config.rewardLabel}"
- "Active Coupons" header + count badge
- Coupon list from seed data using `lookupCoupon()`. Each coupon: rounded card with dashed border, title + description, icon badge (primary-container bg for active, tertiary bg for locked), condition row + Apply/Locked button. Locked coupons wrapped in `Opacity(opacity: 0.6)`.
- Editorial quote at bottom
- Bottom nav (Home, Menu, Cart active, Profile)

- [ ] **Step 2: Commit**

```bash
git add examples/example_app/lib/screens/reward_preview.dart
git commit -m "feat: add RewardPreview widget"
```

---

### Task 15: Update integration files (document_types.dart + main.dart)

**Files:**
- Modify: `examples/desk_app/lib/document_types.dart`
- Modify: `examples/desk_app/lib/main.dart`

- [ ] **Step 1: Replace document_types.dart**

Replace the contents of `examples/desk_app/lib/document_types.dart` with:

```dart
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_preview.dart';
import 'package:example_app/screens/kiosk_preview.dart';
import 'package:example_app/screens/hero_preview.dart';
import 'package:example_app/screens/upsell_preview.dart';
import 'package:example_app/screens/reward_preview.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (data) {
    final merged = {...BrandTheme.defaultValue.toMap(), ...data};
    return BrandThemePreview(config: BrandThemeMapper.fromMap(merged));
  },
);

final kioskDocumentType = kioskConfigTypeSpec.build(
  builder: (data) {
    final merged = {...KioskConfig.defaultValue.toMap(), ...data};
    return KioskPreview(config: KioskConfigMapper.fromMap(merged));
  },
);

final heroDocumentType = heroConfigTypeSpec.build(
  builder: (data) {
    final merged = {...HeroConfig.defaultValue.toMap(), ...data};
    return HeroPreview(config: HeroConfigMapper.fromMap(merged));
  },
);

final upsellDocumentType = upsellConfigTypeSpec.build(
  builder: (data) {
    final merged = {...UpsellConfig.defaultValue.toMap(), ...data};
    return UpsellPreview(config: UpsellConfigMapper.fromMap(merged));
  },
);

final rewardDocumentType = rewardConfigTypeSpec.build(
  builder: (data) {
    final merged = {...RewardConfig.defaultValue.toMap(), ...data};
    return RewardPreview(config: RewardConfigMapper.fromMap(merged));
  },
);
```

- [ ] **Step 2: Update main.dart**

Replace the `DartDeskConfig` block in `examples/desk_app/lib/main.dart`:

```dart
import 'package:dart_desk/studio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'document_types.dart';

const String _defaultServerUrl = 'http://localhost:8080/';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(const MarionetteConfiguration());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: _defaultServerUrl,
  );

  static const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'desk_w_5dGK1_MeafXRpFF5sLLU-0x5ICYqEIVDdyT9wrlcFmg',
  );

  @override
  Widget build(BuildContext context) {
    return DartDeskApp(
      serverUrl: serverUrl,
      apiKey: apiKey,
      config: DartDeskConfig(
        documentTypes: [
          brandThemeDocumentType,
          kioskDocumentType,
          heroDocumentType,
          upsellDocumentType,
          rewardDocumentType,
        ],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: brandThemeDocumentType,
            icon: Icons.palette,
          ),
          DocumentTypeDecoration(
            documentType: kioskDocumentType,
            icon: Icons.point_of_sale,
          ),
          DocumentTypeDecoration(
            documentType: heroDocumentType,
            icon: Icons.home,
          ),
          DocumentTypeDecoration(
            documentType: upsellDocumentType,
            icon: Icons.restaurant_menu,
          ),
          DocumentTypeDecoration(
            documentType: rewardDocumentType,
            icon: Icons.card_giftcard,
          ),
        ],
        title: 'Food Ordering CMS',
        subtitle: 'White-Label App Studio',
        icon: Icons.restaurant,
      ),
    );
  }
}
```

- [ ] **Step 3: Verify analysis passes**

```bash
cd examples/desk_app && flutter analyze
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add examples/desk_app/lib/document_types.dart examples/desk_app/lib/main.dart
git commit -m "feat: wire up new document types in desk_app"
```

---

### Task 16: Build and verify

- [ ] **Step 1: Run full analysis across all example packages**

```bash
cd examples/data_models && dart analyze lib/
cd examples/example_app && flutter analyze
cd examples/desk_app && flutter analyze
```

Expected: All pass with no errors.

- [ ] **Step 2: Launch the desk_app and verify it runs**

Use MCP tools to launch the app:

```
mcp__dart__launch_app with the desk_app project
```

Or if MCP unavailable:

```bash
cd examples/desk_app && flutter run -d macos
```

Expected: App launches, shows 5 document types in the sidebar (Brand Theme, Kiosk Screen, Hero Screen, Upsell Screen, Reward Screen). Clicking each shows the preview widget with default seed data.

- [ ] **Step 3: Commit if any fixes needed**

```bash
git add -A
git commit -m "fix: resolve any build issues from integration"
```
