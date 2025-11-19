import 'package:flutter/material.dart';
import '../../../core/app_asset.dart';

enum EmptyWidgetType { cart, favorite }

class EmptyWidget extends StatelessWidget {
  final EmptyWidgetType type;
  final String title;
  final String? subtitle; // Added subtitle
  final bool condition;
  final Widget child;

  const EmptyWidget({
    super.key,
    this.type = EmptyWidgetType.cart,
    required this.title,
    this.subtitle, // Optional subtitle
    this.condition = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return condition
        ? child
        : Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          type == EmptyWidgetType.cart
              ? Image.asset(AppAsset.emptyCart, width: 300)
              : Image.asset(AppAsset.emptyFavorite, width: 300),
          const SizedBox(height: 10),
          Text(
              title,
              style: Theme.of(context).textTheme.displayMedium
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}