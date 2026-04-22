# Example App Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all existing example documents with 4 new ones (Restaurant Profile, Menu Item, Promotion Campaign, Brand Theme) that collectively demonstrate every DeskFieldConfig type.

**Architecture:** Clean replace — delete all old configs, seed data, and preview screens, then create 4 new annotated classes with dart_mappable, new seed data, preview screens, and rewire the CMS app shell. Code generation produces `.desk.dart` and `.mapper.dart` files.

**Tech Stack:** Flutter, dart_desk_annotation (@DeskModel + DeskFieldConfig annotations), dart_mappable (@MappableClass), build_runner for codegen.

**Important:** Do NOT commit anything. The user will commit manually.

---

### Task 1: Delete Old Files

**Files:**
- Delete: `examples/data_models/lib/src/configs/brand_theme.dart`, `brand_theme.desk.dart`, `brand_theme.mapper.dart`
- Delete: `examples/data_models/lib/src/configs/hero_config.dart`, `hero_config.desk.dart`, `hero_config.mapper.dart`
- Delete: `examples/data_models/lib/src/configs/kiosk_config.dart`, `kiosk_config.desk.dart`, `kiosk_config.mapper.dart`
- Delete: `examples/data_models/lib/src/configs/upsell_config.dart`, `upsell_config.desk.dart`, `upsell_config.mapper.dart`
- Delete: `examples/data_models/lib/src/configs/reward_config.dart`, `reward_config.desk.dart`, `reward_config.mapper.dart`
- Delete: `examples/data_models/lib/src/configs/array_test_config.dart`, `array_test_config.desk.dart`, `array_test_config.mapper.dart`
- Delete: `examples/example_app/lib/screens/brand_theme_screen.dart`
- Delete: `examples/example_app/lib/screens/hero_screen.dart`
- Delete: `examples/example_app/lib/screens/kiosk_screen.dart`
- Delete: `examples/example_app/lib/screens/upsell_screen.dart`
- Delete: `examples/example_app/lib/screens/reward_screen.dart`

- [ ] **Step 1: Delete all old config files and their generated counterparts**

```bash
cd examples/data_models/lib/src/configs
rm -f brand_theme.dart brand_theme.desk.dart brand_theme.mapper.dart
rm -f hero_config.dart hero_config.desk.dart hero_config.mapper.dart
rm -f kiosk_config.dart kiosk_config.desk.dart kiosk_config.mapper.dart
rm -f upsell_config.dart upsell_config.desk.dart upsell_config.mapper.dart
rm -f reward_config.dart reward_config.desk.dart reward_config.mapper.dart
rm -f array_test_config.dart array_test_config.desk.dart array_test_config.mapper.dart
```

- [ ] **Step 2: Delete all old preview screens**

```bash
cd examples/example_app/lib/screens
rm -f brand_theme_screen.dart hero_screen.dart kiosk_screen.dart upsell_screen.dart reward_screen.dart
```

---

### Task 2: Create Seed Data

**Files:**
- Modify: `examples/data_models/lib/src/seed/seed_data.dart`

- [ ] **Step 1: Replace seed_data.dart with new seed data**

Replace the entire file with seed data for the new documents. The seed data provides dropdown option lists used by Menu Item and Restaurant Profile configs.

```dart
// Cuisine types for Restaurant Profile dropdown
const cuisineTypes = [
  'Italian',
  'Japanese',
  'Mexican',
  'American',
  'Thai',
  'Indian',
  'French',
  'Mediterranean',
];

// Payment methods for Restaurant Profile multi-dropdown
const paymentMethods = [
  'Cash',
  'Credit Card',
  'Debit Card',
  'Apple Pay',
  'Google Pay',
];

// Days of week for Operating Hours dropdown
const daysOfWeek = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

// Menu categories for Menu Item dropdown
const menuCategories = [
  'Appetizer',
  'Main',
  'Dessert',
  'Drink',
];

// Allergens for Menu Item multi-dropdown
const allergenTypes = [
  'Nuts',
  'Dairy',
  'Gluten',
  'Soy',
  'Shellfish',
  'Eggs',
];

// Tags for Menu Item multi-dropdown
const menuTags = [
  'Spicy',
  'Popular',
  'New',
  "Chef's Pick",
  'Seasonal',
];

// Discount types for Promotion Campaign dropdown
const discountTypes = [
  'Percentage',
  'Fixed Amount',
  'Buy One Get One',
  'Free Item',
];

// Font options for Brand Theme dropdowns
const headlineFonts = [
  'Noto Serif',
  'Playfair Display',
  'Montserrat',
  'Lora',
  'Raleway',
];

const bodyFonts = [
  'Manrope',
  'Inter',
  'Open Sans',
  'Roboto',
  'Lato',
];
```

---

### Task 3: Create Brand Theme Config

**Files:**
- Create: `examples/data_models/lib/src/configs/brand_theme.dart`

- [ ] **Step 1: Write brand_theme.dart**

This is the simplest config — Color, String, Number, Dropdown, Image. Follow the existing pattern: extend `DeskContent`, mix in generated `BrandThemeMappable` and `Serializable<BrandTheme>`, add `@DeskModel` and `@MappableClass` annotations, add `part` directives for codegen, provide `defaultValue`.

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'desk_content.dart';

part 'brand_theme.desk.dart';
part 'brand_theme.mapper.dart';

@DeskModel(
  title: 'Brand Theme',
  description: 'Visual identity — colors, fonts, and logo for the app',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'brandTheme',
  includeCustomMappers: [BrandThemeColorMapper(), ImageReferenceMapper()],
)
class BrandTheme extends DeskContent
    with BrandThemeMappable, Serializable<BrandTheme> {
  @DeskString(
    description: 'Theme name',
    option: DeskStringOption(),
  )
  final String name;

  @DeskColor(
    description: 'Primary brand color used for buttons and accents',
    option: DeskColorOption(),
  )
  final Color primaryColor;

  @DeskColor(
    description: 'Secondary brand color for backgrounds and cards',
    option: DeskColorOption(),
  )
  final Color secondaryColor;

  @DeskColor(
    description: 'Accent color for highlights and badges',
    option: DeskColorOption(),
  )
  final Color accentColor;

  @DeskDropdown<String>(
    description: 'Font family for headlines',
    option: HeadlineFontDropdownOption(),
  )
  final String headlineFont;

  @DeskDropdown<String>(
    description: 'Font family for body text',
    option: BodyFontDropdownOption(),
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

  @DeskImage(
    description: 'Brand logo',
    option: DeskImageOption(hotspot: false),
  )
  final ImageReference? logo;

  const BrandTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.headlineFont,
    required this.bodyFont,
    required this.cornerRadius,
    required this.themeMode,
    this.logo,
  });

  static BrandTheme defaultValue = BrandTheme(
    name: 'Aura Gastronomy',
    primaryColor: const Color(0xFF496455),
    secondaryColor: const Color(0xFFFAF9F7),
    accentColor: const Color(0xFFD4A574),
    headlineFont: 'Noto Serif',
    bodyFont: 'Manrope',
    cornerRadius: 8,
    themeMode: 'light',
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
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final f in headlineFonts) DropdownOption(value: f, label: f),
      ]);

  @override
  String? get placeholder => 'Select headline font';
}

class BodyFontDropdownOption extends DeskDropdownOption<String> {
  const BodyFontDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Manrope';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final f in bodyFonts) DropdownOption(value: f, label: f),
      ]);

  @override
  String? get placeholder => 'Select body font';
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

---

### Task 4: Create Restaurant Profile Config

**Files:**
- Create: `examples/data_models/lib/src/configs/restaurant_profile.dart`

- [ ] **Step 1: Write restaurant_profile.dart**

This is the most structurally complex config. It demonstrates: String, Text, Boolean, Checkbox, Dropdown, MultiDropdown, URL, Date, Image, File, Object (nested address + contactInfo), and Array (operatingHours).

For nested objects (`address`, `contactInfo`) and array items (`OperatingHour`), define them as separate `@MappableClass` classes in the same file. The `@DeskObject` uses `DeskObjectOption(children: [...])` to define the nested field layout. The `@DeskArray<OperatingHour>()` auto-discovers the item type.

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'desk_content.dart';

part 'restaurant_profile.desk.dart';
part 'restaurant_profile.mapper.dart';

// ── Nested types ──────────────────────────────────────────────────────────

@MappableClass()
class Address with AddressMappable {
  final String street;
  final String city;
  final String state;
  final String zipCode;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  static Address defaultValue = const Address(
    street: '123 Culinary Ave',
    city: 'San Francisco',
    state: 'CA',
    zipCode: '94102',
  );
}

@MappableClass()
class ContactInfo with ContactInfoMappable {
  final String phone;
  final String email;

  const ContactInfo({required this.phone, required this.email});

  static ContactInfo defaultValue = const ContactInfo(
    phone: '(415) 555-0192',
    email: 'hello@auragastronomy.com',
  );
}

@MappableClass()
@DeskModel(
  title: 'Operating Hour',
  description: 'A single day operating schedule',
)
class OperatingHour with OperatingHourMappable
    implements Serializable<OperatingHour> {
  @DeskDropdown<String>(
    description: 'Day of the week',
    option: DayOfWeekDropdownOption(),
  )
  final String day;

  @DeskString(
    description: 'Opening time (e.g. 09:00)',
    option: DeskStringOption(),
  )
  final String openTime;

  @DeskString(
    description: 'Closing time (e.g. 22:00)',
    option: DeskStringOption(),
  )
  final String closeTime;

  @DeskBoolean(
    description: 'Is the restaurant closed on this day?',
  )
  final bool isClosed;

  const OperatingHour({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  static OperatingHour defaultValue = const OperatingHour(
    day: 'Monday',
    openTime: '09:00',
    closeTime: '22:00',
    isClosed: false,
  );
}

// ── Main config ───────────────────────────────────────────────────────────

@DeskModel(
  title: 'Restaurant Profile',
  description: 'Store identity, location, hours, and contact information',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'restaurantProfile',
  includeCustomMappers: [RestaurantProfileColorMapper(), ImageReferenceMapper()],
)
class RestaurantProfile extends DeskContent
    with RestaurantProfileMappable, Serializable<RestaurantProfile> {
  @DeskString(
    description: 'Restaurant display name',
    option: DeskStringOption(),
  )
  final String name;

  @DeskString(
    description: 'URL-safe identifier',
    option: DeskStringOption(),
  )
  final String slug;

  @DeskText(
    description: 'About us description',
    option: DeskTextOption(rows: 4),
  )
  final String description;

  @DeskBoolean(
    description: 'Is this store currently active?',
  )
  final bool isActive;

  @DeskCheckbox(
    description: 'Does this location accept online orders?',
    option: DeskCheckboxOption(label: 'Accepts online orders'),
  )
  final bool acceptsOnlineOrders;

  @DeskDropdown<String>(
    description: 'Primary cuisine type',
    option: CuisineTypeDropdownOption(),
  )
  final String cuisineType;

  @DeskMultiDropdown<String>(
    description: 'Accepted payment methods',
    option: PaymentMethodsDropdownOption(),
  )
  final List<String> paymentMethods;

  @DeskUrl(
    description: 'Restaurant website',
    option: DeskUrlOption(optional: true),
  )
  final Uri? website;

  @DeskUrl(
    description: 'Online ordering link',
    option: DeskUrlOption(optional: true),
  )
  final Uri? orderingUrl;

  @DeskDate(
    description: 'Established date',
    option: DeskDateOption(optional: true),
  )
  final DateTime? openingSince;

  @DeskImage(
    description: 'Square logo',
    option: DeskImageOption(hotspot: false),
  )
  final ImageReference? logo;

  @DeskImage(
    description: 'Cover photo / hero banner',
    option: DeskImageOption(hotspot: true),
  )
  final ImageReference? coverPhoto;

  @DeskFile(
    description: 'Downloadable PDF menu',
    option: DeskFileOption(optional: true),
  )
  final String? pdfMenu;

  @DeskObject(
    description: 'Street address',
  )
  final Address address;

  @DeskObject(
    description: 'Contact information',
  )
  final ContactInfo contactInfo;

  @DeskArray<OperatingHour>(
    description: 'Weekly operating hours',
  )
  final List<OperatingHour> operatingHours;

  const RestaurantProfile({
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    required this.acceptsOnlineOrders,
    required this.cuisineType,
    required this.paymentMethods,
    this.website,
    this.orderingUrl,
    this.openingSince,
    this.logo,
    this.coverPhoto,
    this.pdfMenu,
    required this.address,
    required this.contactInfo,
    required this.operatingHours,
  });

  static RestaurantProfile defaultValue = RestaurantProfile(
    name: 'Aura Gastronomy',
    slug: 'aura-gastronomy',
    description:
        'A modern fine dining experience blending seasonal ingredients with innovative techniques. '
        'Our menu celebrates the art of culinary craft.',
    isActive: true,
    acceptsOnlineOrders: true,
    cuisineType: 'Mediterranean',
    paymentMethods: ['Credit Card', 'Apple Pay', 'Google Pay'],
    website: Uri.parse('https://auragastronomy.com'),
    orderingUrl: Uri.parse('https://order.auragastronomy.com'),
    openingSince: DateTime(2019, 6, 15),
    logo: null,
    coverPhoto: null,
    pdfMenu: null,
    address: Address.defaultValue,
    contactInfo: ContactInfo.defaultValue,
    operatingHours: [
      const OperatingHour(day: 'Monday', openTime: '11:00', closeTime: '22:00', isClosed: false),
      const OperatingHour(day: 'Tuesday', openTime: '11:00', closeTime: '22:00', isClosed: false),
      const OperatingHour(day: 'Wednesday', openTime: '11:00', closeTime: '22:00', isClosed: false),
      const OperatingHour(day: 'Thursday', openTime: '11:00', closeTime: '23:00', isClosed: false),
      const OperatingHour(day: 'Friday', openTime: '11:00', closeTime: '23:00', isClosed: false),
      const OperatingHour(day: 'Saturday', openTime: '10:00', closeTime: '23:00', isClosed: false),
      const OperatingHour(day: 'Sunday', openTime: '10:00', closeTime: '21:00', isClosed: false),
    ],
  );
}

class RestaurantProfileColorMapper extends SimpleMapper<Color> {
  const RestaurantProfileColorMapper();

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

class CuisineTypeDropdownOption extends DeskDropdownOption<String> {
  const CuisineTypeDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Mediterranean';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final c in cuisineTypes) DropdownOption(value: c, label: c),
      ]);

  @override
  String? get placeholder => 'Select cuisine type';
}

class PaymentMethodsDropdownOption extends DeskMultiDropdownOption<String> {
  const PaymentMethodsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues => ['Credit Card', 'Apple Pay', 'Google Pay'];

  @override
  int? get maxSelected => null;

  @override
  int? get minSelected => 1;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final p in paymentMethods) DropdownOption(value: p, label: p),
      ]);

  @override
  String? get placeholder => 'Select payment methods';
}

class DayOfWeekDropdownOption extends DeskDropdownOption<String> {
  const DayOfWeekDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Monday';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final d in daysOfWeek) DropdownOption(value: d, label: d),
      ]);

  @override
  String? get placeholder => 'Select day';
}
```

---

### Task 5: Create Menu Item Config

**Files:**
- Create: `examples/data_models/lib/src/configs/menu_item.dart`

- [ ] **Step 1: Write menu_item.dart**

Demonstrates: String, Block, Number, Boolean, Checkbox, Dropdown, MultiDropdown, Image, Object (nutritionInfo), Array (variants).

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'desk_content.dart';

part 'menu_item.desk.dart';
part 'menu_item.mapper.dart';

// ── Nested types ──────────────────────────────────────────────────────────

@MappableClass()
class NutritionInfo with NutritionInfoMappable {
  final num protein;
  final num carbs;
  final num fat;

  const NutritionInfo({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  static NutritionInfo defaultValue = const NutritionInfo(
    protein: 12,
    carbs: 45,
    fat: 18,
  );
}

@MappableClass()
@DeskModel(
  title: 'Variant',
  description: 'A size/price variant of a menu item',
)
class MenuItemVariant with MenuItemVariantMappable
    implements Serializable<MenuItemVariant> {
  @DeskString(
    description: 'Variant label (e.g. Small, Large)',
    option: DeskStringOption(),
  )
  final String label;

  @DeskNumber(
    description: 'Price for this variant',
    option: DeskNumberOption(min: 0),
  )
  final num price;

  const MenuItemVariant({required this.label, required this.price});

  static MenuItemVariant defaultValue = const MenuItemVariant(
    label: 'Regular',
    price: 0,
  );
}

// ── Main config ───────────────────────────────────────────────────────────

@DeskModel(
  title: 'Menu Item',
  description: 'A product on the restaurant menu with pricing, dietary info, and variants',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'menuItem',
  includeCustomMappers: [MenuItemColorMapper(), ImageReferenceMapper()],
)
class MenuItem extends DeskContent
    with MenuItemMappable, Serializable<MenuItem> {
  @DeskString(
    description: 'Item name',
    option: DeskStringOption(),
  )
  final String name;

  @DeskString(
    description: 'Internal product code',
    option: DeskStringOption(),
  )
  final String sku;

  @DeskBlock(
    description: 'Rich description — ingredients, story, preparation',
    option: DeskBlockOption(),
  )
  final Object? description;

  @DeskNumber(
    description: 'Base price',
    option: DeskNumberOption(min: 0),
  )
  final num price;

  @DeskNumber(
    description: 'Calorie count (optional)',
    option: DeskNumberOption(min: 0),
  )
  final num calories;

  @DeskBoolean(
    description: 'Is this item currently available?',
  )
  final bool isAvailable;

  @DeskCheckbox(
    description: 'Vegetarian',
    option: DeskCheckboxOption(label: 'Vegetarian'),
  )
  final bool isVegetarian;

  @DeskCheckbox(
    description: 'Gluten-free',
    option: DeskCheckboxOption(label: 'Gluten-free'),
  )
  final bool isGlutenFree;

  @DeskDropdown<String>(
    description: 'Menu category',
    option: MenuCategoryDropdownOption(),
  )
  final String category;

  @DeskMultiDropdown<String>(
    description: 'Allergens present in this item',
    option: AllergensDropdownOption(),
  )
  final List<String> allergens;

  @DeskMultiDropdown<String>(
    description: 'Tags for filtering and display',
    option: MenuTagsDropdownOption(),
  )
  final List<String> tags;

  @DeskImage(
    description: 'Product photo',
    option: DeskImageOption(hotspot: true),
  )
  final ImageReference? photo;

  @DeskObject(
    description: 'Nutritional information per serving',
  )
  final NutritionInfo nutritionInfo;

  @DeskArray<MenuItemVariant>(
    description: 'Size/price variants',
  )
  final List<MenuItemVariant> variants;

  const MenuItem({
    required this.name,
    required this.sku,
    this.description,
    required this.price,
    required this.calories,
    required this.isAvailable,
    required this.isVegetarian,
    required this.isGlutenFree,
    required this.category,
    required this.allergens,
    required this.tags,
    this.photo,
    required this.nutritionInfo,
    required this.variants,
  });

  static MenuItem defaultValue = MenuItem(
    name: 'Black Truffle Risotto',
    sku: 'RISK-001',
    description: null,
    price: 34.50,
    calories: 620,
    isAvailable: true,
    isVegetarian: true,
    isGlutenFree: true,
    category: 'Main',
    allergens: ['Dairy'],
    tags: ["Chef's Pick", 'Popular'],
    photo: null,
    nutritionInfo: NutritionInfo.defaultValue,
    variants: [
      const MenuItemVariant(label: 'Regular', price: 34.50),
      const MenuItemVariant(label: 'Large', price: 42.00),
    ],
  );
}

class MenuItemColorMapper extends SimpleMapper<Color> {
  const MenuItemColorMapper();

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

class MenuCategoryDropdownOption extends DeskDropdownOption<String> {
  const MenuCategoryDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Main';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final c in menuCategories) DropdownOption(value: c, label: c),
      ]);

  @override
  String? get placeholder => 'Select category';
}

class AllergensDropdownOption extends DeskMultiDropdownOption<String> {
  const AllergensDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues => [];

  @override
  int? get maxSelected => null;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final a in allergenTypes) DropdownOption(value: a, label: a),
      ]);

  @override
  String? get placeholder => 'Select allergens';
}

class MenuTagsDropdownOption extends DeskMultiDropdownOption<String> {
  const MenuTagsDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues => [];

  @override
  int? get maxSelected => null;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final t in menuTags) DropdownOption(value: t, label: t),
      ]);

  @override
  String? get placeholder => 'Select tags';
}
```

---

### Task 6: Create Promotion Campaign Config

**Files:**
- Create: `examples/data_models/lib/src/configs/promotion_campaign.dart`

- [ ] **Step 1: Write promotion_campaign.dart**

Demonstrates: String, Text, Number, Boolean, Dropdown, MultiDropdown, Date, DateTime, URL, Image, File, Block.

```dart
import 'dart:async';

import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import '../seed/seed_data.dart';
import 'desk_content.dart';

part 'promotion_campaign.desk.dart';
part 'promotion_campaign.mapper.dart';

@DeskModel(
  title: 'Promotion Campaign',
  description: 'Time-bound marketing campaigns with discounts, banners, and promo codes',
)
@MappableClass(
  ignoreNull: false,
  discriminatorValue: 'promotionCampaign',
  includeCustomMappers: [PromotionColorMapper(), ImageReferenceMapper()],
)
class PromotionCampaign extends DeskContent
    with PromotionCampaignMappable, Serializable<PromotionCampaign> {
  @DeskString(
    description: 'Campaign title',
    option: DeskStringOption(),
  )
  final String title;

  @DeskString(
    description: 'Promo code (e.g. SUMMER20)',
    option: DeskStringOption(),
  )
  final String promoCode;

  @DeskText(
    description: 'Terms and conditions',
    option: DeskTextOption(rows: 3),
  )
  final String termsAndConditions;

  @DeskNumber(
    description: 'Discount percentage',
    option: DeskNumberOption(min: 0, max: 100),
  )
  final num discountPercent;

  @DeskDropdown<String>(
    description: 'Type of discount',
    option: DiscountTypeDropdownOption(),
  )
  final String discountType;

  @DeskMultiDropdown<String>(
    description: 'Menu categories this promotion applies to',
    option: ApplicableCategoriesDropdownOption(),
  )
  final List<String> applicableCategories;

  @DeskBoolean(
    description: 'Is this campaign currently active?',
  )
  final bool isActive;

  @DeskDate(
    description: 'Date from which the promo code is valid',
    option: DeskDateOption(optional: true),
  )
  final DateTime? validFrom;

  @DeskDateTime(
    description: 'Exact start time of the campaign',
    option: DeskDateTimeOption(optional: true),
  )
  final DateTime? startsAt;

  @DeskDateTime(
    description: 'Exact end time of the campaign',
    option: DeskDateTimeOption(optional: true),
  )
  final DateTime? endsAt;

  @DeskUrl(
    description: 'External landing page for the campaign',
    option: DeskUrlOption(optional: true),
  )
  final Uri? landingPageUrl;

  @DeskImage(
    description: 'Promotional banner image',
    option: DeskImageOption(hotspot: true),
  )
  final ImageReference? bannerImage;

  @DeskFile(
    description: 'Terms and conditions PDF',
    option: DeskFileOption(optional: true),
  )
  final String? termsDocument;

  @DeskBlock(
    description: 'Rich promotional content',
    option: DeskBlockOption(),
  )
  final Object? promoContent;

  const PromotionCampaign({
    required this.title,
    required this.promoCode,
    required this.termsAndConditions,
    required this.discountPercent,
    required this.discountType,
    required this.applicableCategories,
    required this.isActive,
    this.validFrom,
    this.startsAt,
    this.endsAt,
    this.landingPageUrl,
    this.bannerImage,
    this.termsDocument,
    this.promoContent,
  });

  static PromotionCampaign defaultValue = PromotionCampaign(
    title: 'Summer Festival',
    promoCode: 'SUMMER20',
    termsAndConditions:
        'Valid for dine-in and takeaway orders. Cannot be combined with other offers. '
        'Management reserves the right to modify or cancel this promotion.',
    discountPercent: 20,
    discountType: 'Percentage',
    applicableCategories: ['Main', 'Appetizer'],
    isActive: true,
    validFrom: DateTime(2026, 6, 1),
    startsAt: DateTime(2026, 6, 1, 10, 0),
    endsAt: DateTime(2026, 8, 31, 23, 59),
    landingPageUrl: Uri.parse('https://auragastronomy.com/summer'),
    bannerImage: null,
    termsDocument: null,
    promoContent: null,
  );
}

class PromotionColorMapper extends SimpleMapper<Color> {
  const PromotionColorMapper();

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

class DiscountTypeDropdownOption extends DeskDropdownOption<String> {
  const DiscountTypeDropdownOption({super.hidden});

  @override
  bool get allowNull => false;

  @override
  FutureOr<String?>? get defaultValue => 'Percentage';

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        for (final d in discountTypes) DropdownOption(value: d, label: d),
      ]);

  @override
  String? get placeholder => 'Select discount type';
}

class ApplicableCategoriesDropdownOption
    extends DeskMultiDropdownOption<String> {
  const ApplicableCategoriesDropdownOption({super.hidden});

  @override
  List<String>? get defaultValues => ['Main', 'Appetizer'];

  @override
  int? get maxSelected => null;

  @override
  int? get minSelected => null;

  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) =>
      Future.value([
        DropdownOption(value: 'All', label: 'All Categories'),
        for (final c in menuCategories) DropdownOption(value: c, label: c),
      ]);

  @override
  String? get placeholder => 'Select applicable categories';
}
```

---

### Task 7: Update Barrel Exports

**Files:**
- Modify: `examples/data_models/lib/example_data.dart`

- [ ] **Step 1: Replace example_data.dart exports**

```dart
library;

export 'src/configs/desk_content.dart';
export 'src/configs/brand_theme.dart' hide BrandThemeColorMapper;
export 'src/configs/restaurant_profile.dart' hide RestaurantProfileColorMapper;
export 'src/configs/menu_item.dart' hide MenuItemColorMapper;
export 'src/configs/promotion_campaign.dart' hide PromotionColorMapper;
export 'src/seed/seed_data.dart';
```

---

### Task 8: Run Code Generation

- [ ] **Step 1: Run build_runner in data_models**

```bash
cd examples/data_models && dart run build_runner build --delete-conflicting-outputs
```

Expected: Generates `.desk.dart` and `.mapper.dart` for all 4 new configs plus nested types.

- [ ] **Step 2: Verify generated files exist**

```bash
ls examples/data_models/lib/src/configs/*.g.dart examples/data_models/lib/src/configs/*.mapper.dart
```

Expected: `brand_theme.desk.dart`, `brand_theme.mapper.dart`, `restaurant_profile.desk.dart`, `restaurant_profile.mapper.dart`, `menu_item.desk.dart`, `menu_item.mapper.dart`, `promotion_campaign.desk.dart`, `promotion_campaign.mapper.dart`

---

### Task 9: Create Preview Screens

**Files:**
- Create: `examples/example_app/lib/screens/brand_theme_screen.dart`
- Create: `examples/example_app/lib/screens/restaurant_profile_screen.dart`
- Create: `examples/example_app/lib/screens/menu_item_screen.dart`
- Create: `examples/example_app/lib/screens/promotion_campaign_screen.dart`

- [ ] **Step 1: Write brand_theme_screen.dart**

A preview that shows color swatches, typography samples, and a sample card with the theme applied. Similar to the old one but uses the new field structure (added secondaryColor, accentColor, logo).

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

class BrandThemeScreen extends StatelessWidget {
  const BrandThemeScreen({super.key, required this.config});

  final BrandTheme config;

  String _toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(config.cornerRadius.toDouble());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.name,
            style: TextStyle(
              fontFamily: config.headlineFont,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Theme Mode: ${config.themeMode}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Color swatches
          Row(
            children: [
              _ColorSwatch(color: config.primaryColor, label: 'Primary\n${_toHex(config.primaryColor)}'),
              _ColorSwatch(color: config.secondaryColor, label: 'Secondary\n${_toHex(config.secondaryColor)}'),
              _ColorSwatch(color: config.accentColor, label: 'Accent\n${_toHex(config.accentColor)}'),
            ],
          ),
          const SizedBox(height: 24),

          // Typography
          Text(
            'The Art of Fine Dining',
            style: TextStyle(
              fontFamily: config.headlineFont,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience culinary excellence crafted with the finest ingredients from around the world.',
            style: TextStyle(fontFamily: config.bodyFont, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Sample card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: radius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample Menu Card',
                    style: TextStyle(fontFamily: config.headlineFont, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This card demonstrates the corner radius and font styling applied from the theme.',
                    style: TextStyle(fontFamily: config.bodyFont, fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$34.50', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: config.primaryColor)),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: config.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: radius),
                        ),
                        onPressed: () {},
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Settings summary
          _SettingsRow(label: 'Corner Radius', value: '${config.cornerRadius}px'),
          _SettingsRow(label: 'Headline Font', value: config.headlineFont),
          _SettingsRow(label: 'Body Font', value: config.bodyFont),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Write restaurant_profile_screen.dart**

A preview showing the restaurant info in a settings-like layout.

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

class RestaurantProfileScreen extends StatelessWidget {
  const RestaurantProfileScreen({super.key, required this.config});

  final RestaurantProfile config;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: config.logo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(config.logo!.url, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.restaurant, size: 32, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(config.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(config.slug, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusChip(label: config.isActive ? 'Active' : 'Inactive', isActive: config.isActive),
                        if (config.acceptsOnlineOrders) ...[
                          const SizedBox(width: 8),
                          _StatusChip(label: 'Online Orders', isActive: true),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(config.description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 20),

          // Details
          _SectionTitle('Details'),
          _DetailRow('Cuisine', config.cuisineType),
          if (config.openingSince != null)
            _DetailRow('Established', '${config.openingSince!.year}'),
          _DetailRow('Payment', config.paymentMethods.join(', ')),
          if (config.website != null)
            _DetailRow('Website', config.website.toString()),
          const SizedBox(height: 20),

          // Address
          _SectionTitle('Address'),
          Text(
            '${config.address.street}\n${config.address.city}, ${config.address.state} ${config.address.zipCode}',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),

          // Contact
          _SectionTitle('Contact'),
          _DetailRow('Phone', config.contactInfo.phone),
          _DetailRow('Email', config.contactInfo.email),
          const SizedBox(height: 20),

          // Operating Hours
          _SectionTitle('Operating Hours'),
          ...config.operatingHours.map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(h.day, style: const TextStyle(fontSize: 13)),
                    Text(
                      h.isClosed ? 'Closed' : '${h.openTime} – ${h.closeTime}',
                      style: TextStyle(fontSize: 13, color: h.isClosed ? Colors.red[400] : Colors.grey[700]),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500]))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isActive});
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green[300]! : Colors.red[300]!),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: isActive ? Colors.green[700] : Colors.red[700])),
    );
  }
}
```

- [ ] **Step 3: Write menu_item_screen.dart**

A preview showing the menu item as a product card.

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

class MenuItemScreen extends StatelessWidget {
  const MenuItemScreen({super.key, required this.config});

  final MenuItem config;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: config.photo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(config.photo!.url, fit: BoxFit.cover),
                  )
                : const Center(child: Icon(Icons.fastfood, size: 48, color: Colors.grey)),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(config.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('SKU: ${config.sku}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${config.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${config.calories} cal', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status + Dietary
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _Chip(label: config.isAvailable ? 'Available' : 'Unavailable', color: config.isAvailable ? Colors.green : Colors.red),
              _Chip(label: config.category, color: Colors.blue),
              if (config.isVegetarian) _Chip(label: 'Vegetarian', color: Colors.green),
              if (config.isGlutenFree) _Chip(label: 'Gluten-free', color: Colors.orange),
              ...config.tags.map((t) => _Chip(label: t, color: Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),

          // Allergens
          if (config.allergens.isNotEmpty) ...[
            Text('Allergens', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red[700])),
            const SizedBox(height: 4),
            Text(config.allergens.join(', '), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
          ],

          // Nutrition
          Text('Nutrition (per serving)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              _NutritionBox(label: 'Protein', value: '${config.nutritionInfo.protein}g'),
              _NutritionBox(label: 'Carbs', value: '${config.nutritionInfo.carbs}g'),
              _NutritionBox(label: 'Fat', value: '${config.nutritionInfo.fat}g'),
            ],
          ),
          const SizedBox(height: 16),

          // Variants
          if (config.variants.isNotEmpty) ...[
            Text('Variants', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...config.variants.map((v) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(v.label, style: const TextStyle(fontSize: 14)),
                      Text('\$${v.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[300]!),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color[700])),
    );
  }
}

class _NutritionBox extends StatelessWidget {
  const _NutritionBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Write promotion_campaign_screen.dart**

A preview showing the campaign as a marketing card.

```dart
import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

class PromotionCampaignScreen extends StatelessWidget {
  const PromotionCampaignScreen({super.key, required this.config});

  final PromotionCampaign config;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    return '${_formatDate(dt)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: config.bannerImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(config.bannerImage!.url, fit: BoxFit.cover),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign, size: 40, color: Colors.amber[700]),
                        const SizedBox(height: 8),
                        Text(config.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber[900])),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Status + Code
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: config.isActive ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: config.isActive ? Colors.green[300]! : Colors.red[300]!),
                ),
                child: Text(
                  config.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(fontSize: 12, color: config.isActive ? Colors.green[700] : Colors.red[700]),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(config.promoCode, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Discount info
          Text(
            '${config.discountPercent}% ${config.discountType}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Applies to: ${config.applicableCategories.join(', ')}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 20),

          // Schedule
          _SectionTitle('Schedule'),
          _DetailRow('Valid From', _formatDate(config.validFrom)),
          _DetailRow('Starts At', _formatDateTime(config.startsAt)),
          _DetailRow('Ends At', _formatDateTime(config.endsAt)),
          const SizedBox(height: 16),

          // Links
          if (config.landingPageUrl != null) ...[
            _SectionTitle('Links'),
            _DetailRow('Landing Page', config.landingPageUrl.toString()),
            const SizedBox(height: 16),
          ],

          // T&C
          _SectionTitle('Terms & Conditions'),
          Text(config.termsAndConditions, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500]))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
```

---

### Task 10: Rewire CMS App

**Files:**
- Modify: `examples/desk_app/lib/document_types.dart`
- Modify: `examples/desk_app/lib/main.dart`

- [ ] **Step 1: Replace document_types.dart**

```dart
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:example_app/screens/restaurant_profile_screen.dart';
import 'package:example_app/screens/menu_item_screen.dart';
import 'package:example_app/screens/promotion_campaign_screen.dart';

final brandThemeDocumentType = brandThemeTypeSpec.build(
  builder: (data) {
    final merged = {...BrandTheme.defaultValue.toMap(), ...data};
    return BrandThemeScreen(config: BrandThemeMapper.fromMap(merged));
  },
);

final restaurantProfileDocumentType = restaurantProfileTypeSpec.build(
  builder: (data) {
    final merged = {...RestaurantProfile.defaultValue.toMap(), ...data};
    return RestaurantProfileScreen(config: RestaurantProfileMapper.fromMap(merged));
  },
);

final menuItemDocumentType = menuItemTypeSpec.build(
  builder: (data) {
    final merged = {...MenuItem.defaultValue.toMap(), ...data};
    return MenuItemScreen(config: MenuItemMapper.fromMap(merged));
  },
);

final promotionCampaignDocumentType = promotionCampaignTypeSpec.build(
  builder: (data) {
    final merged = {...PromotionCampaign.defaultValue.toMap(), ...data};
    return PromotionCampaignScreen(config: PromotionCampaignMapper.fromMap(merged));
  },
);
```

- [ ] **Step 2: Update main.dart**

Replace the `documentTypes` list and `documentTypeDecorations` in the `DartDeskConfig`:

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
          restaurantProfileDocumentType,
          menuItemDocumentType,
          promotionCampaignDocumentType,
          brandThemeDocumentType,
        ],
        documentTypeDecorations: [
          DocumentTypeDecoration(
            documentType: restaurantProfileDocumentType,
            icon: Icons.store,
          ),
          DocumentTypeDecoration(
            documentType: menuItemDocumentType,
            icon: Icons.restaurant_menu,
          ),
          DocumentTypeDecoration(
            documentType: promotionCampaignDocumentType,
            icon: Icons.campaign,
          ),
          DocumentTypeDecoration(
            documentType: brandThemeDocumentType,
            icon: Icons.palette,
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

---

### Task 11: Verify Build

- [ ] **Step 1: Verify data_models package compiles**

```bash
cd examples/data_models && flutter analyze
```

Expected: No errors.

- [ ] **Step 2: Verify desk_app compiles**

```bash
cd examples/desk_app && flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Verify example_app compiles**

```bash
cd examples/example_app && flutter analyze
```

Expected: No errors.
