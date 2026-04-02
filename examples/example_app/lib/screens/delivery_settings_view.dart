import 'package:data_models/example_data.dart';
import 'package:flutter/material.dart';

/// Preview of delivery zone settings as shown in the food ordering app.
class DeliverySettingsView extends StatelessWidget {
  final DeliverySettings config;
  const DeliverySettingsView({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone header
            _ZoneHeader(config: config),
            const SizedBox(height: 24),
            // Fee breakdown card
            _FeeCard(config: config),
            const SizedBox(height: 16),
            // Service info
            _InfoTile(
              icon: Icons.access_time,
              label: 'Service Hours',
              value: config.serviceHours,
            ),
            const SizedBox(height: 10),
            _InfoTile(
              icon: Icons.timer_outlined,
              label: 'Estimated Delivery',
              value: '${config.estimatedMinutes.toInt()} minutes',
            ),
            const SizedBox(height: 10),
            _InfoTile(
              icon: Icons.local_shipping_outlined,
              label: 'Fulfillment',
              value: switch (config.deliveryType) {
                'delivery' => 'Delivery only',
                'pickup' => 'Pickup only',
                'both' => 'Delivery & Pickup',
                _ => config.deliveryType,
              },
            ),
            if (config.contactUrl != null) ...[
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.support_agent,
                label: 'Support',
                value: config.contactUrl!,
                isLink: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ZoneHeader extends StatelessWidget {
  final DeliverySettings config;
  const _ZoneHeader({required this.config});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: config.active
                ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delivery_dining,
            color: config.active
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade400,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    config.zoneName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: config.active
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      config.active ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: config.active
                            ? const Color(0xFF2E7D32)
                            : Colors.red.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                config.zoneDescription,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeeCard extends StatelessWidget {
  final DeliverySettings config;
  const _FeeCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _FeeRow(
            label: 'Minimum Order',
            value: '\$${config.minimumOrder.toStringAsFixed(2)}',
          ),
          const Divider(height: 20),
          _FeeRow(
            label: 'Delivery Fee',
            value: '\$${config.deliveryFee.toStringAsFixed(2)}',
          ),
          const Divider(height: 20),
          _FeeRow(
            label: 'Free Delivery Over',
            value: '\$${config.freeDeliveryThreshold.toStringAsFixed(2)}',
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _FeeRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: highlight ? const Color(0xFF2E7D32) : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLink;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFD4451A)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLink ? Colors.blue.shade600 : const Color(0xFF1A1A1A),
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
