import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sync/sync_cubit.dart';
import '../../cubits/sync/sync_state.dart';
import '../../widgets/sync/token_input.dart';
import '../../widgets/sync/sync_queue_list.dart';
import '../../widgets/sync/sync_status_card.dart';

/// Sync management page
class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: BlocBuilder<SyncCubit, SyncState>(
        builder: (context, state) {
          if (state is SyncLoaded) {
            return _buildContent(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SyncLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TokenInput(),
        const SizedBox(height: 16),
        SyncStatusCard(
          pendingCount: state.pendingCount,
          hasToken: state.hasToken,
        ),
        const SizedBox(height: 16),
        if (state.pendingActions.isNotEmpty)
          SyncQueueList(actions: state.pendingActions),
      ],
    );
  }
}

