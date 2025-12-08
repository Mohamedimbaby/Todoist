import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/injection.dart';
import '../../cubits/history/history_cubit.dart';
import '../../cubits/history/history_state.dart';
import '../../widgets/history/history_list.dart';
import '../../widgets/history/history_summary.dart';

/// History page showing completed tasks
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HistoryCubit>()..loadHistory(),
      child: Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HistoryError) {
              return Center(child: Text(state.message));
            }
            if (state is HistoryLoaded) {
              return _buildContent(state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(HistoryLoaded state) {
    if (state.records.isEmpty) {
      return const Center(child: Text('No completed tasks yet'));
    }
    return Column(
      children: [
        HistorySummary(
          totalTime: state.formattedTotalTime,
          completedCount: state.records.length,
        ),
        Expanded(child: HistoryList(records: state.records)),
      ],
    );
  }
}
