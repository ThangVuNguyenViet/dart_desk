# Example Showcase Redesign

Complete redesign of the dart_desk CMS example app. Replaces all 5 existing data models and preview screens with new ones based on 4 HTML reference designs (kiosk, hero, upsell, reward) plus a brand theme model.

## Reference Files

- `dart_desk/examples/kiosk.html` — Desktop 3-panel kiosk layout
- `dart_desk/examples/hero.html` — Mobile home screen with hero image
- `dart_desk/examples/upsell.html` — Mobile "Chef's Choice" list view
- `dart_desk/examples/reward.html` — Mobile loyalty rewards + coupons

All share the "Aura Gastronomy" brand: green primary (#496455), Noto Serif headlines, Manrope body, Material Design 3 color tokens.

## Design Decisions

- **Approach**: Minimal CMS fields + seed data dropdowns. Preview widgets do the visual heavy lifting.
- **Product selection**: Per-screen seed product lists, chosen via dropdown. Each screen has its own curated products.
- **Reward screen**: Lightweight config fields + seed coupon data via dropdown.
- **Kiosk order sidebar**: Static seed data, not interactive.
- **Theme**: Separate `BrandTheme` data model (5th model) with its own preview screen. All previews use Aura theme defaults.
- **Image URLs**: All default image URLs extracted from the HTML reference files.

---

## Data Models

### 1. KioskConfig

| Field | Type | Annotation | Notes |
|---|---|---|---|
| `restaurantName` | `String` | `@CmsStringFieldConfig` | Nav drawer title |
| `bannerTitle` | `String` | `@CmsStringFieldConfig` | Hero banner headline |
| `bannerSubtitle` | `String` | `@CmsTextFieldConfig` | Banner description text |
| `bannerImage` | `ImageReference?` | `@CmsImageFieldConfig` | Banner background image |
| `products` | `List<String>` | `@CmsArrayFieldConfig` | Array of product keys; each item uses a dropdown editor backed by kiosk seed products |

### 2. HeroConfig

| Field | Type | Annotation | Notes |
|---|---|---|---|
| `heroTitle` | `String` | `@CmsStringFieldConfig` | Main hero text |
| `heroSubtitle` | `String` | `@CmsTextFieldConfig` | Hero description |
| `heroImage` | `ImageReference?` | `@CmsImageFieldConfig` | Hero background |
| `ctaLabel` | `String` | `@CmsStringFieldConfig` | Button text |
| `products` | `List<String>` | `@CmsArrayFieldConfig` | Array of product keys; each item uses a dropdown editor backed by hero seed products |

### 3. UpsellConfig

| Field | Type | Annotation | Notes |
|---|---|---|---|
| `sectionTitle` | `String` | `@CmsStringFieldConfig` | e.g. "Chef's Choice" |
| `sectionSubtitle` | `String` | `@CmsTextFieldConfig` | Description below title |
| `quoteText` | `String` | `@CmsTextFieldConfig` | Pull-quote content |
| `chefName` | `String` | `@CmsStringFieldConfig` | Quote attribution |
| `products` | `List<String>` | `@CmsArrayFieldConfig` | Array of product keys; each item uses a dropdown editor backed by upsell seed products |

### 4. RewardConfig

| Field | Type | Annotation | Notes |
|---|---|---|---|
| `brandName` | `String` | `@CmsStringFieldConfig` | e.g. "Aura Gastronomy" |
| `pointsBalance` | `num` | `@CmsNumberFieldConfig` | Current points |
| `nextRewardThreshold` | `num` | `@CmsNumberFieldConfig` | Points needed |
| `rewardLabel` | `String` | `@CmsStringFieldConfig` | e.g. "Festive Tasting Menu" |
| `coupons` | `List<String>` | `@CmsArrayFieldConfig` | Array of coupon keys; each item uses a dropdown editor backed by seed coupons |

### 5. BrandTheme

| Field | Type | Annotation | Notes |
|---|---|---|---|
| `primaryColor` | `Color` | `@CmsColorFieldConfig` | Default `#496455` |
| `surfaceColor` | `Color` | `@CmsColorFieldConfig` | Default `#FAF9F7` |
| `textColor` | `Color` | `@CmsColorFieldConfig` | Default `#2F3331` |
| `headlineFont` | `String` | `@CmsStringFieldConfig` | Default "Noto Serif" |
| `bodyFont` | `String` | `@CmsStringFieldConfig` | Default "Manrope" |
| `cornerRadius` | `num` | `@CmsNumberFieldConfig` | Default 8 |
| `themeMode` | `String` | `@CmsDropdownFieldConfig` | light / dark / system |

---

## Seed Data

### Kiosk Products

| Key | Name | Price | Description | Tags | Image URL |
|---|---|---|---|---|---|
| `truffle_risotto` | Black Truffle Risotto | 34.50 | Arborio rice, forest mushrooms, 24-month aged parmesan, Perigord truffles | Vegetarian, Gluten-Free | `https://lh3.googleusercontent.com/aida-public/AB6AXuC55Kc61wukj2x-5tEdMbGBbK2Ac7ybF-9uaflz3tRjCTNLINl77QVrJm5BDeOu8GNG1y2YZMaaip7_xn8meK6pNGJxWfiP60VvuqeV9CbdppwiOXQX1CtI48TUv4wufYlNHNrLp7lcBCtAA-0h5Dc8ZSi83XGDepLpYbib_MM0ug6HtR6VG8EPW0ESTZ2Xe1h74DdpA-QMt083BRjvl37D1geMPgYpn94nG7tJs0zNbBLJE2S9_96aoyY_KAKXLn9RboVgctA7eQc` |
| `heritage_scallops` | Heritage Scallops | 28.00 | Hand-dived Atlantic scallops, parsnip velvet, crispy pancetta soil | — | `https://lh3.googleusercontent.com/aida-public/AB6AXuBO6ZQsbMv6ymfDux8DDzJQ8ZdaONc-5NYQuT91O2u75qxMPYFB3y-caU19vuIXWj70CilshFt8T7HBXAJmAwGnEefm9rIyUgKizvZ5lCN06TD52Yw_Y8mspwmT8cMnx0etleN5YHypMJ3ti17lwu5zC5g__4nL3I6TWwNxD6cEJMV0L5CZo7DmftrZ2dPFp7iRZIb4ytu0A671h9Tcwlk--_b8E5aLFlRJ38qGLeFcBiCAcxa2OSSHXbSuIJmV6-V7fkuPb1bX0hQ` |
| `cherry_duck` | Cherry Glazed Duck | 42.00 | Roasted breast, confit leg croquette, dark cherry reduction | — | `https://lh3.googleusercontent.com/aida-public/AB6AXuAg8XhvBkUgJfr1wM7JztNsuOD1ewfd3tcqEcN54r4yKNZqkB3vZ_hAw3cvwVAn26vRvq1oOT85oD6LMrwb2Ad3vs3xkNXavc2hUENoPF_SN1yJg-9WOf7mzCF9G1q8oizLWgBcevOIByCoYBAodHZsuw_TkmqWMwFt1n8uPbcB9jfjfHqf91c4fURloN_43YzZEKSxHql1knzADMZ5HKb1tGUSvDuub0z1jlIhs0rj3fLPbsAreTs80OPwSeGyae14MUFjo-7lUfI` |
| `valrhona_fondant` | Valrhona Fondant | 16.00 | 70% dark chocolate, molten center, Tahitian vanilla bean cream | — | `https://lh3.googleusercontent.com/aida-public/AB6AXuBBMLG0_CElO9XwTUIQkM-i7crsB86_ZWkdyfaEBwXNch-gDLizH2CjW80VomdcBvFn7ZKmWJTu1OVY_z9A9GZXW4FOHZd5gRPuEfLPuE1zV6f4T06PX_0InTZFwUQRG_wGFsTQPd07mcZLv6MthHosxX25wcam1tcs8FCoXUiSryAaNic1s3jDIbrFgcBIzk0ga-AQPiMUpNms0bBZeEPO5CbJEn291I65LA5xmDMYF02JT-u0djsvtRFHjOIDuDcuwfrQr2ySZL0` |

Banner image: `https://lh3.googleusercontent.com/aida-public/AB6AXuAQzrN87Tvd8S8Ym8ettmmvaYIOIze5Lb-Mr4pLxLUjCHk4XR5MltVpW4CLSSLj_74ro2XRS341LGXF_UBe7i8m2A5phCMjSv6oz06psNilGoB2XK7VjX0rPJRDNsVQmWG2VUb9V3WQNgxkuI5vdtSuKYzGbUK757KqHFfsYy70Z1SrJwPvOT5QJe9gRX4sLGPas6TIn0fXpM_1VASSAhzcfQa_raKi5-bP0XZM6E_0Tl8zqCbCUDqiSpkRKzoNdY2QiKClnqQdE0I`

Order sidebar thumbnails:
- Risotto: `https://lh3.googleusercontent.com/aida-public/AB6AXuCZTU3lbdfR46MFHHfHF-wX5Nm3NuiDlS7QN4u-bZSF3Ful7n10NuyMbVXQZKS096oNvbRBdwko5nVEncUbKvhHmWyXQ6jIX3-t2JWp2Yes25P-4XlQCB1QU7jIpafXWQtrqq1JWWuKFICJODp0qvs2JWrxqRe5JyJnGU7P3g4CQYryGIDxQJZs1B-RNlLyumvzn5MjknjSm8yDVNioHf2wCtb2jVLQAFrNL56YniOkNzs8JilKT24aUn7DZI5auFLGu5OK5f42Dbs`
- Scallops: `https://lh3.googleusercontent.com/aida-public/AB6AXuBIHhscrh4u94_69aTY0G5VPnPCY5H7O3JTITTwRnrq0AcyVrA0vmgwVLKnwsyNeshQAlcjmbY00DHvXwiVe7QqXLrCcuYP9uDW1-iQA00FBtbTZts1jG4JXq0n0a6O1-sotOrQRnAD027Lpg8d8v7ujvkAsJil_rVZ3YMQzrqeQJvESX1fFHJmipD1Xgwoesg5ckMbZhdovW5t3Un13ptufHsyzjhICNaGJw9uMZhkkKaCrfCkQTpx5lxJeZUe4ypksqjjvSg4pC4`

### Hero Products

| Key | Name | Price | Image URL |
|---|---|---|---|
| `roasted_turkey` | Roasted Turkey Platter | 84.00 | `https://lh3.googleusercontent.com/aida-public/AB6AXuAT40v_sLw55b4SL27WdbIGcMv-BTVIgtGUCG8gFyI1w3fh6cg1tFcGVVFJsnObLhuyaR9qs-JuYVHz8WNipg9ebgqbYx841FbxdzYdi0UoyNYK4Wagola1TONbdw67tMDWTPlJCJg5jglUaGspnWi8rPwsMpo2A0pTa-eZpAiSSnJjzzXMMgHFS_jy3-X6bEWkXkc8kesLVXKY78a2ferzojQ8eC4_YwZ3jBNkoD443TzdtkNe2PvRRJHLZA-bF6GlQ9LONN6vnEA` |
| `berry_tart` | Berry Mascarpone Tart | 12.50 | `https://lh3.googleusercontent.com/aida-public/AB6AXuCk4oVPQvBD9eXfcVXuqTIcVknK1ib_lbkGTNySdCYgul9SW3feUxXgLqCMU4XZshDABYLna23CMIH2EP3s-vlOShcfp7sm6DHL1faBsDzEIWfZ1DKU_tg6n197MZ9n8K0QNDhEKJadl_U6teM45pb9dfheGn_U1MO_Sfl9p4eMiWQBcJhjLU7lpgpkEaHgPd_QWkikdlNUdhdCPpNCjOTanZi0HSy7fNMpy42cmPL_oTwzlnqlo6juJ1kowZ8jESApfGAOaptp8k8` |
| `mulled_wine` | Seasonal Mulled Wine | 14.00 | `https://lh3.googleusercontent.com/aida-public/AB6AXuCg-plghUaaB7VtjJmWgxLtZoN8OTvWVZHS4IdVwCgtvNcfKtDGuIKqq-Gg4qEDbjkxHxucz4VjXf3kYd4Ugkf14Mbqo10PzSVtShft8nYnx4TaiZquqFTfKfZte0--Qb1Zzs-qjU-kcVlqxZ-RT13m6jGMO6fOM1tekW5LHEVOQFZiuqho7DrWVPLBwTaflvPdKq_8HImT0moBAzQ3WHPapcl-mdRS7aqA8J8bhTtv5Lt7wC_zG7JU23JOcgYQ1Rze23hQHvPShsQ` |
| `glazed_ham` | Honey Glazed Ham | 58.00 | `https://lh3.googleusercontent.com/aida-public/AB6AXuC_m-Oeg69KUjrxHeJMNaMnERp0eaL6TDDLMW-If9pq3d1qMQspy18B2XVfXRk_hn8jXccE0INqMOU0QaZGEiDEpJ7GCbVZC7eit6PrfJCGpaJXhXm9o4J1iFX9Nd9jgB3TFVZryn6H3cs-vZitw3Gr-GMN2HxYUuxkp6wEIuSUd1D6HVbgZME9VPQvxQknSC21drMGViNX3DBAMsNiJTQNXhtlhD71noFrEX8dT8NLQnG-klppzsuvICxCXyYTPHX8X7PHVDOZFvk` |

Hero background: `https://lh3.googleusercontent.com/aida-public/AB6AXuD4sfUJtVO96YI82Ie3tQlRae8apQDGMEfIeTberImKMS1bmZU2A99l-VrK5VoS05wgARcetQ7uU_Xczj6CD6ber-rYgTqXf_Zylu6EKw0ykCCn89TD2HXFGGFBeY-ExOCXYYnPpjNJPqvSnunra1C2AcBcnMoPFBC8evQYvxjMmnBuz-fdeW-NtHrnlrEIOi4tFSNUCNX6-fxKB2vVP8fi6gtLQR46Lj7CZKrlitLZNTpBuNYL8LcTDoMCMCOmcaMVGzwL9dBdm38`

Profile avatar: `https://lh3.googleusercontent.com/aida-public/AB6AXuAadtuOwfKN3oBAcPOWdIUgQLsNlAnxU3IxNhRA8J04Rtz1GIoZA8Bhv5b9R8suR6_mtZ3Uaqd8hNC6KxHkHDy0rw76tb8CCtXAfDQMGIXwOPdfMWXI-ahXNk01eHBjm_ITy-gR5Tuco1yo3o06_uKL83ivY59ONcAnk2voEqasdr_fB5g5NGyrKDqM1JI1XHLrvFzirFhI3VjMBeOgj_lpGWXauHG2lPH8pickvVF_4tjjElXM1GEuvUGatBGjgZeuX8gH0LdFpoI`

### Upsell Products

| Key | Name | Price | Description | Calories | Image URL |
|---|---|---|---|---|---|
| `wagyu_burger` | Truffle Wagyu Burger | 32.00 | Aged wagyu, winter truffle, brioche | 840 | `https://lh3.googleusercontent.com/aida-public/AB6AXuAu4ogJ4MAs_MaWwB9bQZqCF-59LibpwudjHdRE5VW8ZrKtmArHKX7h7u66fryOlilCGbbc5K7WD_ieBiulMFqhTZ7Jw7L-8C_Ulc0C6tkSbOD1Xc016ancSHOKd77NC1o7gYJPrnbQ4RVMf7q8ZG1aEfXBlqFcWjzDHH7X6_JdmyZz0xNe4vVZONDiEKSYRCLSWeHX2A1CuraR5AcqcoVF11Z_L18vJwVzEAqS31OBv0pRNZzRb9TRRyvDr_5CJjhAEObqqqrZwDI` |
| `linguine_vongole` | Linguine Alle Vongole | 28.50 | Wild clams, white wine, parsley oil | 620 | `https://lh3.googleusercontent.com/aida-public/AB6AXuAwE7IzIb2bPaeRMkAvHnmILdJGo7wmjBfdyA9ldN7xL4Df90a6jCae9ubfvi5YK0S4oPYiwb4GuCV3gBD0fVlaoJ3fBYHvQWD9esf_TK6y7xH-oGN3es91KcuZ30C8PCBi5A8hngDZl-4bDq2ZqKfrNARMMNIEP2QG5aKbW3KahxFKzhnpZ0oUGXYWKFMYSNbDiWbEOebHsabeYnLlXdvLaWFv18Qtkzyucxik7pe3JTMJVBNdfdgEonQ8TfADMBluJrRgVdqARx4` |
| `hokkaido_scallops` | Hokkaido Scallops | 36.00 | Pan-seared, cauliflower, brown butter | 410 | `https://lh3.googleusercontent.com/aida-public/AB6AXuBRkegIh8K2cX6HjewmYXVIH0uyBuPaskUTBhoMyrxn04IF8SX-x-6n0w3HPRBsd8uDdhmUvmohVlEILHc4jIObUird1m-0feKSmkD92Gg1kjWnjtJlW12SAmZ7aFkZk0uuJMSQjc4oy-KKtLPQtMG_zQK_JmsTJC42-Cd0oprgQSNGjiMEzppXlx7F4_7rK1IWHgerMa1144cr-vpObHWWyUEqYDBfY2isEsKR16bWBKWH7I0pOAMDS5Vq3mKv3b3hoDIdem7tDS4` |
| `dry_aged_ribeye` | Dry-Aged Ribeye | 54.00 | 45-day aged, bone marrow butter | 950 | `https://lh3.googleusercontent.com/aida-public/AB6AXuBjyS_NLlXFORBEgP_P20yaARsT_v1ns6tlb6hxIFXEWFEJlBpyiBant39NsjDwbQhIMAL1wXNLQ410wArWfHr5IWZoJ-SpIKtdfZGeiihhxXrso0E8omaOpS2dPsyZIOyJzAssG5XIu6dglzC8wEoVGIbvSFzr2MDFu9Swp61zjOtAj0vxhvUqwqqy8KdKB8OiStqM30q94gnzr0yDMSvXd27m8FJ-ExQBKPyBfLp5B62h_6ueGlfuUUljp91z495FrF0w6IZyTXo` |

### Coupons

| Key | Title | Description | Icon | Condition | State |
|---|---|---|---|---|---|
| `festive_mains` | 20% Off Festive Mains | Valid on all seasonal signature dishes this week | restaurant | Expires in 2 days | active |
| `free_drink` | Free Drink with Any Order | Choose from curated winter cocktail list or house mocktails | local_bar | Min spend $25.00 | active |
| `dessert_platter` | Holiday Dessert Platter | Unlock this reward at Gold tier membership | lock | Requires 5,000 total points | locked |

---

## Preview Widgets

### KioskPreview
Faithful recreation of `kiosk.html`. Fixed 3-panel desktop layout:
- **Left nav drawer** (w=288): restaurant name, menu items (Dine In active, Takeaway, Seasonal, Support), wait time card at bottom
- **Center content** (scrollable): banner with `bannerImage` + gradient + `bannerTitle`/`bannerSubtitle` + "Limited Availability" tag; category tabs (Mains active, Appetizers, Beverages, Desserts); bento grid — 1 large 8-col featured card (image left + details right) + 1 small 4-col card + 1 small 4-col card + 1 horizontal 8-col card. Products from seed data.
- **Right sidebar** (w=400): "Your Order" header + 2 items badge; 2 static order items (risotto + scallops) with thumbnails, customization text, quantity controls; subtotal/service fee/total; "Place Order" button + "Clear Selection" link
- **Floating top bar**: category pills + "Table 24" badge

### HeroPreview
Recreation of `hero.html`. Mobile single-column:
- Top app bar: hamburger + "Aura Gastronomy" italic + profile avatar
- Circular hero section (4:5 aspect): `heroImage` + gradient overlay + "Limited Seasonal Selection" label + `heroTitle` + CTA button with `ctaLabel`
- Horizontal category pills: Starters, Mains (active), Festive Treats, Drinks, Bakery — circular icons
- "Featured Today" header with accent bar
- 2-column staggered grid: 4 products from seed data, odd columns offset down. Each card: 3:4 image with "+" FAB, name, price.
- Editorial pull-quote: italic serif text + "The Aura Manifesto" attribution
- Bottom nav: Home (active), Menu, Cart, Profile

### UpsellPreview
Recreation of `upsell.html`. Mobile list:
- Top app bar: hamburger + "Aura Gastronomy" + profile avatar
- Centered editorial header: "Monthly Curation" label + `sectionTitle` + divider + `sectionSubtitle`
- 4 product cards from seed data. Each: horizontal layout (1/3 image, 2/3 content), "Chef's Choice" gradient badge, calories, name, description, price, cart button. Items 1 and 4 get tertiary-container background (highlighted), items 2 and 3 get white background.
- Pull-quote card between items 3 and 4: `quoteText` + `chefName` attribution
- Bottom nav: Home, Menu (active), Cart, Profile

### RewardPreview
Recreation of `reward.html`. Mobile:
- Top app bar: hamburger + "Aura Gastronomy" + profile avatar
- Loyalty card: primary color background with decorative circles, "Seasonal Loyalty" label, "Holiday Rewards" header, `pointsBalance` display, `nextRewardThreshold` with "Next Reward" label, progress bar (points/threshold ratio), italic text showing remaining points until `rewardLabel`
- "Active Coupons" header + "N Available" badge
- Coupon cards from seed data: dashed border, title, description, icon badge (colored by type), condition row (expiry/min spend/locked), Apply/Locked button. Locked coupons at 60% opacity.
- Editorial quote at bottom
- Bottom nav: Home, Menu, Cart (active), Profile

### BrandThemePreview
Updated theme preview:
- Header with logo placeholder + "Theme Preview"
- Color swatch row: primary, surface, text colors with hex labels
- Typography preview: headline font sample + body font sample
- Sample food card using theme colors (name, description, price, "Add to Cart" button)
- Primary + Secondary button row
- Settings summary: theme mode, corner radius, headline font, body font

---

## File Structure

### Delete
- `dart_desk/examples/data_models/lib/src/configs/storefront_config.dart` (+ `.mapper.dart`, `.cms.g.dart`)
- `dart_desk/examples/data_models/lib/src/configs/menu_highlight.dart` (+ generated)
- `dart_desk/examples/data_models/lib/src/configs/promo_offer.dart` (+ generated)
- `dart_desk/examples/data_models/lib/src/configs/app_theme.dart` (+ generated)
- `dart_desk/examples/data_models/lib/src/configs/delivery_settings.dart` (+ generated)
- `dart_desk/examples/example_app/lib/screens/storefront_preview.dart`
- `dart_desk/examples/example_app/lib/screens/menu_highlight_card.dart`
- `dart_desk/examples/example_app/lib/screens/promo_offer_banner.dart`
- `dart_desk/examples/example_app/lib/screens/app_theme_preview.dart`
- `dart_desk/examples/example_app/lib/screens/delivery_settings_view.dart`

### New — Data Models
In `dart_desk/examples/data_models/lib/src/configs/`:
- `kiosk_config.dart`
- `hero_config.dart`
- `upsell_config.dart`
- `reward_config.dart`
- `brand_theme.dart`

### New — Seed Data
In `dart_desk/examples/data_models/lib/src/seed/`:
- `kiosk_products.dart`
- `hero_products.dart`
- `upsell_products.dart`
- `coupons.dart`

### New — Preview Widgets
In `dart_desk/examples/example_app/lib/screens/`:
- `kiosk_preview.dart`
- `hero_preview.dart`
- `upsell_preview.dart`
- `reward_preview.dart`
- `brand_theme_preview.dart`

### Update
- `dart_desk/examples/data_models/lib/example_data.dart` — update exports
- `dart_desk/examples/cms_app/lib/document_types.dart` — swap 5 old types for 5 new
- `dart_desk/examples/cms_app/lib/main.dart` — update `documentTypes` and `documentTypeDecorations`

### Code Generation
Run `dart run build_runner build` in `dart_desk/examples/data_models/` after writing data models to generate `.mapper.dart` and `.cms.g.dart` files.
