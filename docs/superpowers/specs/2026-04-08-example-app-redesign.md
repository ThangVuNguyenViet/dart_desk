# Example App Redesign — Full CmsFieldConfig Showcase

## Goal

Replace all 5 existing example documents with 4 new ones that collectively demonstrate every CmsFieldConfig type (except Geopoint) in a realistic food ordering CMS context. Clean replace — no legacy configs kept.

## Documents

### 1. Restaurant Profile

The "settings" page. Configured once, updated occasionally.

| Field | Dart Type | CmsFieldConfig | Notes |
|---|---|---|---|
| name | String | CmsStringFieldConfig | Restaurant display name |
| slug | String | CmsStringFieldConfig | URL-safe identifier |
| description | String | CmsTextFieldConfig | Multi-line "about us", 4 rows |
| isActive | bool | CmsBooleanFieldConfig | Toggle: store open/closed |
| acceptsOnlineOrders | bool | CmsCheckboxFieldConfig | Checkbox with label |
| cuisineType | String | CmsDropdownFieldConfig\<String\> | Italian, Japanese, Mexican, American, Thai, Indian, French, Mediterranean |
| paymentMethods | List\<String\> | CmsMultiDropdownFieldConfig\<String\> | Cash, Card, Apple Pay, Google Pay |
| website | Uri | CmsUrlFieldConfig | Restaurant website (optional) |
| orderingUrl | Uri | CmsUrlFieldConfig | Online ordering link (optional) |
| openingSince | DateTime | CmsDateFieldConfig | Date only — "established" date |
| logo | ImageReference | CmsImageFieldConfig | Square logo |
| coverPhoto | ImageReference | CmsImageFieldConfig | Hero banner image |
| pdfMenu | String | CmsFileFieldConfig | Downloadable PDF menu |
| address | Object | CmsObjectFieldConfig | Nested: street, city, state, zipCode (all String) |
| contactInfo | Object | CmsObjectFieldConfig | Nested: phone (String), email (String) |
| operatingHours | List\<OperatingHour\> | CmsArrayFieldConfig | Array of Objects — see below |

**Nested Object: Address** — street, city, state, zipCode (all CmsStringFieldConfig)

**Nested Object: ContactInfo** — phone, email (all CmsStringFieldConfig)

**Array Item: OperatingHour** — day (CmsDropdownFieldConfig: Mon–Sun), openTime (CmsStringFieldConfig), closeTime (CmsStringFieldConfig), isClosed (CmsBooleanFieldConfig)

**Default value:** A pre-filled "Aura Gastronomy" restaurant with realistic data.

### 2. Menu Item

The most-edited document. Product owners manage these daily.

| Field | Dart Type | CmsFieldConfig | Notes |
|---|---|---|---|
| name | String | CmsStringFieldConfig | e.g. "Margherita Pizza" |
| sku | String | CmsStringFieldConfig | Internal product code |
| description | Object | CmsBlockFieldConfig | Rich text — ingredients, story |
| price | num | CmsNumberFieldConfig | min: 0 |
| calories | num | CmsNumberFieldConfig | min: 0, optional |
| isAvailable | bool | CmsBooleanFieldConfig | Toggle on/off menu |
| isVegetarian | bool | CmsCheckboxFieldConfig | Dietary flag |
| isGlutenFree | bool | CmsCheckboxFieldConfig | Dietary flag |
| category | String | CmsDropdownFieldConfig\<String\> | Appetizer, Main, Dessert, Drink |
| allergens | List\<String\> | CmsMultiDropdownFieldConfig\<String\> | Nuts, Dairy, Gluten, Soy, Shellfish, Eggs |
| tags | List\<String\> | CmsMultiDropdownFieldConfig\<String\> | Spicy, Popular, New, Chef's Pick, Seasonal |
| photo | ImageReference | CmsImageFieldConfig | Product photo |
| nutritionInfo | Object | CmsObjectFieldConfig | Nested: protein, carbs, fat (all Number) |
| variants | List\<Variant\> | CmsArrayFieldConfig | Array of Objects — see below |

**Nested Object: NutritionInfo** — protein, carbs, fat (all CmsNumberFieldConfig, min: 0)

**Array Item: Variant** — label (CmsStringFieldConfig, e.g. "Small", "Large"), price (CmsNumberFieldConfig, min: 0)

**Default value:** A "Truffle Risotto" with pre-filled nutrition and two variants.

### 3. Promotion Campaign

Time-bound marketing configuration.

| Field | Dart Type | CmsFieldConfig | Notes |
|---|---|---|---|
| title | String | CmsStringFieldConfig | Campaign name |
| promoCode | String | CmsStringFieldConfig | e.g. "SUMMER20" |
| termsAndConditions | String | CmsTextFieldConfig | Multi-line, 3 rows |
| discountPercent | num | CmsNumberFieldConfig | min: 0, max: 100 |
| discountType | String | CmsDropdownFieldConfig\<String\> | Percentage, Fixed Amount, Buy One Get One, Free Item |
| applicableCategories | List\<String\> | CmsMultiDropdownFieldConfig\<String\> | Appetizer, Main, Dessert, Drink, All |
| isActive | bool | CmsBooleanFieldConfig | Toggle campaign on/off |
| validFrom | DateTime | CmsDateFieldConfig | Start date |
| startsAt | DateTime | CmsDateTimeFieldConfig | Exact start time |
| endsAt | DateTime | CmsDateTimeFieldConfig | Exact end time |
| landingPageUrl | Uri | CmsUrlFieldConfig | External landing page (optional) |
| bannerImage | ImageReference | CmsImageFieldConfig | Promo banner |
| termsDocument | String | CmsFileFieldConfig | Terms PDF upload |
| promoContent | Object | CmsBlockFieldConfig | Rich promo description |

**Default value:** A "Summer Festival" campaign with realistic dates and 20% discount.

### 4. Brand Theme

Visual identity — colors, fonts, logo. Fresh implementation (not evolved from old).

| Field | Dart Type | CmsFieldConfig | Notes |
|---|---|---|---|
| name | String | CmsStringFieldConfig | Theme name |
| primaryColor | Color | CmsColorFieldConfig | Primary brand color |
| secondaryColor | Color | CmsColorFieldConfig | Secondary color |
| accentColor | Color | CmsColorFieldConfig | Accent/highlight color |
| headlineFont | String | CmsDropdownFieldConfig\<String\> | Noto Serif, Playfair Display, Montserrat, Lora, Raleway |
| bodyFont | String | CmsDropdownFieldConfig\<String\> | Manrope, Inter, Open Sans, Roboto, Lato |
| cornerRadius | num | CmsNumberFieldConfig | min: 0, max: 24 |
| themeMode | String | CmsDropdownFieldConfig\<String\> | Light, Dark, System |
| logo | ImageReference | CmsImageFieldConfig | Brand logo |

**Default value:** The existing "Aura Gastronomy" theme values.

## Field Coverage

| CmsFieldConfig | Restaurant Profile | Menu Item | Promotion | Brand Theme |
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

- `examples/data_models/lib/src/configs/brand_theme.dart` (and .cms.g.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/hero_config.dart` (and .cms.g.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/kiosk_config.dart` (and .cms.g.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/upsell_config.dart` (and .cms.g.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/reward_config.dart` (and .cms.g.dart, .mapper.dart)
- `examples/data_models/lib/src/configs/array_test_config.dart` (and .cms.g.dart, .mapper.dart)
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

### CMS App (`examples/cms_app/lib/`)
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

- `examples/data_models/lib/src/configs/cms_content.dart` — keep as-is, it's the base class

## Code Generation

After creating the annotated classes, run `dart run build_runner build` in `examples/data_models/` to regenerate `.cms.g.dart` and `.mapper.dart` files.

## Pattern Notes

Each config class must:
1. Extend `CmsContent` with `XxxMappable` and `Serializable<Xxx>` mixins
2. Use `@CmsConfig(title:, description:)` annotation
3. Use `@MappableClass(ignoreNull: false, discriminatorValue: '...')` with necessary custom mappers
4. Have `part 'xxx.cms.g.dart'` and `part 'xxx.mapper.dart'`
5. Provide a `static Xxx defaultValue` for the preview builder
6. Custom dropdown options extend `CmsDropdownOption<T>` or `CmsMultiDropdownOption<T>`
7. Color fields need a `SimpleMapper<Color>` for hex serialization
8. ImageReference fields need an `ImageReferenceMapper`
