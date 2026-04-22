import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

import '../widgets/aura/aura_button.dart';
import '../widgets/aura/aura_theme.dart';
import '../widgets/aura/aura_tokens.dart';
import '../widgets/aura/aura_wordmark.dart';
import '../widgets/aura/photo.dart';
import '../widgets/aura/tablet_frame.dart';

class KioskScreen extends StatelessWidget {
  final KioskConfig config;
  final BrandTheme theme;

  const KioskScreen({super.key, required this.config, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AuraTheme.wrap(
      theme,
      child: Builder(
        builder: (context) => TabletFrame(child: _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final tokens = AuraTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final serifFont = theme.headlineFont;
    final cream = theme.surfaceColor;

    final subtotal = config.sidebarSampleOrder.fold<double>(
      0,
      (s, line) => s + line.price.toDouble() * line.qty.toDouble(),
    );
    final tax = subtotal * 0.0875;
    final total = subtotal + tax;

    return Row(
      children: [
        // ---- MAIN PANEL ----
        Expanded(
          child: Container(
            color: cream,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top chrome
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AuraWordmark(
                          color: scheme.onSurface,
                          size: 18,
                          showSub: true,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        for (final label in ['Dine in', 'Takeaway', 'Delivery'])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _chip(
                              label,
                              active: label == 'Dine in',
                              tokens: tokens,
                              scheme: scheme,
                            ),
                          ),
                        Container(
                          width: 1,
                          height: 20,
                          color: tokens.line,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        _chip(
                          config.sidebarTableLabel,
                          active: false,
                          tokens: tokens,
                          scheme: scheme,
                          dot: true,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Hero banner
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: tokens.greenDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Photo(
                        reference: config.bannerImage,
                        radius: 0,
                        height: 240,
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              tokens.greenDark,
                              tokens.greenDark.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 0.7],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(34, 30, 34, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.promoBadge.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 3,
                                    color: cream.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  config.bannerHeadline,
                                  style: TextStyle(
                                    fontFamily: serifFont,
                                    fontSize: 36,
                                    height: 1.02,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    color: cream,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 380,
                                  child: Text(
                                    config.bannerSubtitle,
                                    style: TextStyle(
                                      fontFamily: serifFont,
                                      fontSize: 14,
                                      height: 1.55,
                                      color: cream.withValues(alpha: 0.82),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                AuraButton(
                                  label: 'Explore menu',
                                  style: AuraButtonStyle.dark,
                                  showArrow: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "THE CHEF'S THREE",
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w700,
                            color: scheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Signatures from our spring counter',
                          style: TextStyle(
                            fontFamily: serifFont,
                            fontSize: 22,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    ),
                    Row(
                      children: [
                        for (final cat in ['All', 'Small plates', 'Mains', 'Sweets'])
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _chip(
                              cat,
                              active: cat == 'All',
                              tokens: tokens,
                              scheme: scheme,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Product grid
                Expanded(
                  child: Row(
                    children: [
                      for (int i = 0; i < config.gridProducts.length && i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(
                          child: _ProductCard(
                            product: config.gridProducts[i],
                            serifFont: serifFont,
                            cream: cream,
                            tokens: tokens,
                            scheme: scheme,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---- RIGHT SIDEBAR ----
        Container(
          width: 360,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: tokens.line)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: tokens.line.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Your order',
                            style: TextStyle(
                              fontFamily: serifFont,
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Text(
                          '#A·2614',
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.mute,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${config.sidebarTableLabel} · 2 guests · started 7:14pm',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: tokens.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),

              // Order lines
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      for (final line in config.sidebarSampleOrder)
                        _OrderRow(
                          line: line,
                          serifFont: serifFont,
                          tokens: tokens,
                        ),
                      // Suggestion prompt
                      Container(
                        margin: const EdgeInsets.fromLTRB(22, 14, 22, 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: tokens.line,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: tokens.creamWarm,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+',
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'May we suggest a glass of Grüner?',
                                style: TextStyle(
                                  fontFamily: serifFont,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                  color: tokens.inkSoft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Totals footer
              Container(
                padding: const EdgeInsets.fromLTRB(26, 16, 26, 22),
                decoration: BoxDecoration(
                  color: cream,
                  border: Border(
                    top: BorderSide(
                      color: tokens.line.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    _totalRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}',
                        tokens),
                    const SizedBox(height: 4),
                    _totalRow(
                        'Tax (8.75%)', '\$${tax.toStringAsFixed(2)}', tokens),
                    Divider(color: tokens.line, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontFamily: serifFont,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: serifFont,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AuraButton(
                        label: 'Send to kitchen',
                        showArrow: false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      config.footerNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: tokens.mute,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(
    String label, {
    required bool active,
    required AuraTokens tokens,
    required ColorScheme scheme,
    bool dot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? scheme.onSurface : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? scheme.onSurface : tokens.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: scheme.secondary,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 4),
            ),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, AuraTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: tokens.inkSoft)),
        Text(value, style: TextStyle(fontSize: 13, color: tokens.inkSoft)),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final KioskProduct product;
  final String serifFont;
  final Color cream;
  final AuraTokens tokens;
  final ColorScheme scheme;

  const _ProductCard({
    required this.product,
    required this.serifFont,
    required this.cream,
    required this.tokens,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Photo(
                reference: product.image,
                height: 160,
                radius: 0,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cream.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    product.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontFamily: serifFont,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.2,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: serifFont,
                          fontSize: 17,
                          color: scheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: scheme.primary),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+ Add to order',
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final OrderLine line;
  final String serifFont;
  final AuraTokens tokens;

  const _OrderRow({
    required this.line,
    required this.serifFont,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.itemName,
              style: TextStyle(
                fontFamily: serifFont,
                fontSize: 15.5,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'x${line.qty.toInt()}',
            style: TextStyle(fontSize: 13, color: tokens.mute),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 44,
            child: Text(
              '\$${(line.price.toDouble() * line.qty.toDouble()).toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: serifFont,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
