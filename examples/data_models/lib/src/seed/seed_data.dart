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
