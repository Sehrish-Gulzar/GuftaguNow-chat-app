import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateChip extends StatelessWidget {
  final DateTime date;

  const DateChip({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Chip(
          label: Text(
            DateFormat('yMMMMd').format(date),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[600],
        ),
      ),
    );
  }
}
