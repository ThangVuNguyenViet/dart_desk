# Example App Redesign — Full DeskFieldConfig Showcase

## Goal

Replace all 5 existing example documents with 4 new ones that collectively demonstrate every DeskFieldConfig type (except Geopoint) in a realistic food ordering CMS context. Clean replace — no legacy configs kept.

## Documents

### 1. Restaurant Profile

The "settings" page. Configured once, updated occasionally.

| Field | Dart Type | DeskFieldConfig | Notes |
|---|---|---|---|
| name | String | DeskString | Restaurant display name |
| slug | String | DeskString | URL-safe identifier |
| description | String | DeskText | Multi-line "about us", 4 rows |
| isActive | bool | DeskBoolean | Toggle: store open/closed |
| acceptsOnlineOrders | bool | DeskCheckbox | Checkbox with label |
| cuisineType | String | DeskDropdown\<String\> | Italian, Japanese, Mexican, American, Thai, Indian, French, Mediterranean |
| paymentMethods | List\<String\> | DeskMultiDropdown\<String\> | Cash, Card, Apple Pay, Google Pay |
| website | Uri | DeskUrl | Restaurant website (optional) |
| orderingUrl | Uri | DeskUrl | Online ordering link (optional) |
| openingSince | DateTime | DeskDate | Date only — "established" date |
| logo | ImageReference | DeskImage | Square logo |
| coverPhoto | ImageReference | DeskImage | Hero banner image |
| pdfMenu | String | DeskFile | Downloadable PDF menu |
| address | Object | DeskObject | Nested: street, city, state, zipCode (all String) |
| contactInfo | Object | DeskObject | Nested: phone (String), email (String) |
| operatingHours | List\<OperatingHour\> | DeskArray | Array of Objects — see below |

**Nested Object: Address** — street, city, state, zipCode (all DeskString)

**Nested Object: ContactInfo** — phone, email (all DeskString)

**Array Item: OperatingHour** — day (DeskDropdown: Mon–Sun), openTime (DeskString), closeTime (DeskString), isClosed (DeskBoolean)

**Default value:** A pre-filled "Aura Gastronomy" restaurant with realistic data.

### 2. Menu Item

The most-edited document. Product owners manage these daily.

| Field | Dart Type | DeskFieldConfig | Notes |
|---|---|---|---|
| name | String | DeskString | e.g. "Margherita Pizza" |
| sku | String | DeskString | Internal product code |
| description | Object | DeskBlock | Rich text — ingredients, story |
| price | num | DeskNumber | min: 0 |
| calories | num | DeskNumber | min: 0, optional |
| isAvailable | bool | DeskBoolean | Toggle on/off menu |
| isVegetarian | bool | DeskCheckbox | Dietary flag |
| isGlutenFree | bool | DeskCheckbox | Dietary flag |
| category | String | DeskDropdown\<String\> | Appetizer, Main, Dessert, Drink |
| allergens | List\<String\> | DeskMultiDropdown\<String\> | Nuts, Dairy, Gluten, Soy, Shellfish, Eggs |
| tags | List\<String\> | DeskMultiDropdown\<String\> | Spicy, Popular, New, Chef's Pick, Seasonal |
| photo | ImageReference | DeskImage | Product photo |
| nutritionInfo | Object | DeskObject | Nested: protein, carbs, fat (all Number) |
| variants | List\<Variant\> | DeskArray | Array of Objects — see below |

**Nested Object: NutritionInfo** — protein, carbs, fat (all DeskNumber, min: 0)

**Array Item: Variant** — label (DeskString, e.g. "Small", "Large"), price (DeskNumber, min: 0)

**Default value:** A "Truffle Risotto" with pre-filled nutrition and two variants.

### 3. Promotion Campaign

Time-bound marketing configuration.

| Field | Dart Type | DeskFieldConfig | Notes |
|---|---|---|---|
| title | String | DeskString | Campaign name |
| promoCode | String | DeskString | e.g. "SUMMER20" |
| termsAndConditions | String | DeskText | Multi-line, 3 rows |
| discountPercent | num | DeskNumber | min: 0, max: 100 |
| discountType | String | DeskDropdown\<String\> | Percentage, Fixed Amount, Buy One Get One, Free Item |
| applicableCategories | List\<String\> | DeskMultiDropdown\<String\> | Appetizer, Main, Dessert, Drink, All |
| isActive | bool | DeskBoolean | Toggle campaign on/off |
| validFrom | DateTime | DeskDate | Start date |
| startsAt | DateTime | DeskDateTime | Exact start time |
| endsAt | DateTime | DeskDateTime | Exact end time |
| landingPageUrl | Uri | DeskUrl | External landing page (optional) |
| bannerImage | ImageReference | DeskImage | Promo banner |
| termsDocument | String | DeskFile | Terms PDF upload |
| promoContent | Object | DeskBlock | Rich promo description |

**Default value:** A "Summer Festival" campaign with realistic dates and 20% discount.

### 4. Brand Theme

Visual identity — colors, fonts, logo. Fresh implementation (not evolved from old).

| Field | Dart Type | DeskFieldConfig | Notes |
|---|---|---|---|
| name | String | DeskString | Theme name |
| primaryColor | Color | DeskColor | Primary brand color |
| secondaryColor | Color | DeskColor | Secondary color |
| accentColor | Color | DeskColor | Accent/highlight color |
| headlineFont | String | DeskDropdown\<String\> | Noto Serif, Playfair Display, Montserrat, Lora, Raleway |
| bodyFont | String | DeskDropdown\<String\> | Manrope, Inter, Open Sans, Roboto, Lato |
| cornerRadius | num | DeskNumber | min: 0, max: 24 |
| themeMode | String | DeskDropdown\<String\> | Light, Dark, System |
| logo | ImageReference | DeskImage | Brand logo |

**Default value:** The existing "Aura Gastronomy" theme values.

## Field Coverage

| DeskFieldConfig | Restaurant Profile | Menu Item | Promotion | Brand Theme |
|---|---|---|---|---|
| String | name, slug | name, sku | title, promoCode | name |
| Text | description | — | termsAndConditions | — |
| Number | — | price, calories | discountPercent | cornerRadius |
| Boolean | isActive | isAvailable | isActive | — |
| Checkbox | acceptsOnlineOrders | isVegetarian, isGlutenFree | — | — |
| URL | website, orderingUrl | — | landingPageUrl | — |
| Date | openingSince | — | validFrom | — |
| DateTime | — | — | startsAt, endsAt | — |
| Image | logo, coverPhoto | photo | bannerImage | logo |
| Color | — | — | — | primary, secondary, accent |
| File | pdfMenu | — | termsDocument | — |
| Dropdown | cuisineType | category | discountType | headlineFont, bodyFont, themeMode |
| MultiDropdown | paymentMethods | allergens, tags | applicableCategories | — |
| Array | operatingHours | variants | — | — |
| Object | address, contactInfo | nutritionInfo | — | — |
| Block | — | description | promoContent | — |

All 16 field types covered (Geopoint excluded by design).

## Files to Delete

- `examples/data_models/lib/src/configs/brand_theme.dart` (and .desk.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/hero_config.dart` (and .desk.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/kiosk_config.dart` (and .desk.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/upsell_config.dart` (and .desk.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/reward_config.dart` (and .desk.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/array_test_config.dart` (and .desk.dart, .mapper.dart)
- `examples/example_app/lib/screens/brand_theme_screen.dart`
- `examples/example_app/lib/screens/hero_screen.dart`
- `examples/example_app/lib/screens/kiosk_screen.dart`
- `examples/example_app/lib/screens/upsell_screen.dart`
- `examples/example_app/lib/screens/reward_screen.dart`

## Files to Create

### Data Models (`examples/data_models/lib/src/configs/`)
- `restaurant_profile.dart` — class + dropdown options + ColorMapper + ImageReferenceMapper
- `menu_item.dart` — class + dropdown options + nested types
- `promotion_campaign.dart` — class + dropdown options
- `brand_theme.dart` — class + dropdown options + ColorMapper

### Seed Data (`examples/data_models/lib/src/seed/`)
- `seed_data.dart` — replace with new seed data for menu item dropdowns (allergens, tags, categories) and product lookups

### CMS App (`examples/desk_app/lib/`)
- `document_types.dart` — rewire to new 4 document types
- `main.dart` — update documentTypes list and icons

### Preview Screens (`examples/example_app/lib/screens/`)
- `restaurant_profile_screen.dart` — preview widget
- `menu_item_screen.dart` — preview widget
- `promotion_campaign_screen.dart` — preview widget
- `brand_theme_screen.dart` — preview widget

### Barrel Exports
- `examples/data_models/lib/example_data.dart` — update exports

## Files to Update

- `examples/data_models/lib/src/configs/desk_content.dart` — keep as-is, it's the base class

## Code Generation

After creating the annotated classes, run `dart run build_runner build` in `examples/data_models/` to regenerate `.desk.dart` and `.mapper.dart` files.

## Pattern Notes

Each config class must:
1. Extend `DeskContent` with `XxxMappable` and `Serializable<Xxx>` mixins
2. Use `@DeskModel(title:, description:)` annotation
3. Use `@MappableClass(ignoreNull: false, discriminatorValue: '...')` with necessary custom mappers
4. Have `part 'xxx.desk.dart'` and `part 'xxx.mapper.dart'`
5. Provide a `static Xxx defaultValue` for the preview builder
6. Custom dropdown options extend `DeskDropdownOption<T>` or `DeskMultiDropdownOption<T>`
7. Color fields need a `SimpleMapper<Color>` for hex serialization
8. ImageReference fields need an `ImageReferenceMapper`
