import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class QuantityTool extends StatefulWidget {
  final int currentQuantity;
  final Function() onAdd;
  final Function() onRemove;
  const QuantityTool({
    super.key,
    required this.currentQuantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<QuantityTool> createState() => _QuantityToolState();
}

class _QuantityToolState extends State<QuantityTool> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Iconsax.minus, color: Colors.grey),
            onPressed: widget.currentQuantity > 0 ? widget.onRemove : null,
          ),
          SizedBox(width: 10),
          Text(
            "${widget.currentQuantity}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Iconsax.add, color: Colors.grey),
            onPressed: widget.onAdd,
          ),
        ],
      ),
    );
  }
}
