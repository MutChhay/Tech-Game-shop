import 'package:flutter/material.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String status;

  const OrderStatusTimeline({super.key, required this.status});

  int _currentStep() {
    switch (status) {
      case 'confirmed':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0; // pending
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentStep();

    return Column(
      children: [
        _step(
          index: 0,
          current: current,
          title: "Order Placed",
          subtitle: "We received your order",
        ),
        _divider(current >= 1),
        _step(
          index: 1,
          current: current,
          title: "Confirmed",
          subtitle: "Order is being prepared",
        ),
        _divider(current >= 2),
        _step(
          index: 2,
          current: current,
          title: "Shipped",
          subtitle: "On the way to you",
        ),
        _divider(current >= 3),
        _step(
          index: 3,
          current: current,
          title: "Delivered",
          subtitle: "Order delivered successfully",
        ),
      ],
    );
  }

  Widget _step({
    required int index,
    required int current,
    required String title,
    required String subtitle,
  }) {
    final isActive = index <= current;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: isActive
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(bool active) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      height: 30,
      width: 2,
      color: active ? Colors.green : Colors.grey.shade300,
    );
  }
}
