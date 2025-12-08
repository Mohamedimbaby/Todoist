import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/sync/sync_cubit.dart';
import '../../cubits/sync/sync_state.dart';

/// Todoist token input widget
class TokenInput extends StatefulWidget {
  const TokenInput({super.key});

  @override
  State<TokenInput> createState() => _TokenInputState();
}

class _TokenInputState extends State<TokenInput> {
  final _controller = TextEditingController();
  bool _obscureText = true;
  bool _isConnecting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        final hasToken = state is SyncLoaded && state.hasToken;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todoist API Token',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (hasToken)
                  _buildConnectedState(context)
                else
                  _buildInputState(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectedState(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Connected to Todoist')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.read<SyncCubit>().removeToken(),
                child: const Text('Disconnect'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputState(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: 'Paste your Todoist API token',
            suffixIcon: IconButton(
              icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
          enabled: !_isConnecting,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isConnecting ? null : _connect,
            child: _isConnecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Connect'),
          ),
        ),
      ],
    );
  }

  Future<void> _connect() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isConnecting = true);

    await context.read<SyncCubit>().saveToken(_controller.text);
    _controller.clear();

    if (mounted) {
      setState(() => _isConnecting = false);
    }
  }
}
