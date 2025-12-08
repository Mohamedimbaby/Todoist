import 'package:flutter/material.dart';
import '../../../domain/entities/history_entity.dart';
import 'history_item.dart';

/// List of history records
class HistoryList extends StatelessWidget {
  final List<HistoryEntity> records;

  const HistoryList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: records.length,
      itemBuilder: (context, index) => HistoryItem(record: records[index]),
    );
  }
}

