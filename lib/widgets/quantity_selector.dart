import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;

  const QuantitySelector({
    Key? key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Decrease button
        InkWell(
          onTap: value > minValue ? () => onChanged(value - 1) : null,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: value > minValue
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.remove,
              size: 20,
              color: value > minValue
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
            ),
          ),
        ),

        // Quantity display
        Container(
          width: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // Increase button
        InkWell(
          onTap: value < maxValue ? () => onChanged(value + 1) : null,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: value < maxValue
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.add,
              size: 20,
              color: value < maxValue
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}
