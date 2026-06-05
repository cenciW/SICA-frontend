import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';

class AlertBadge extends StatelessWidget {
  final String productId;
  final Widget child;

  const AlertBadge({super.key, required this.productId, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, provider, _) {
        final count = provider.activeCount;
        if (count == 0) return child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
