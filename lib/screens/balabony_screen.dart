import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ball_state.dart';
import '../providers/ball_provider.dart';
import '../widgets/balabony_sphere.dart';

class BalabonyScreen extends ConsumerStatefulWidget {
  const BalabonyScreen({super.key});

  @override
  ConsumerState<BalabonyScreen> createState() => _BalabonyScreenState();
}

class _BalabonyScreenState extends ConsumerState<BalabonyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ballStateProvider.notifier).initialize();
    });
  }

  Color _getStateColor(BallState state) {
    switch (state) {
      case BallState.idle:
        return const Color(0xFF1a237e);
      case BallState.listening:
        return const Color(0xFFef9f27);
      case BallState.thinking:
        return const Color(0xFF7b1fa2);
      case BallState.speaking:
        return const Color(0xFFef9f27);
    }
  }

  String _getHintText(BallState state) {
    switch (state) {
      case BallState.idle:
        return 'Торкніться щоб говорити';
      case BallState.listening:
        return 'Торкніться щоб зупинити';
      case BallState.thinking:
        return 'Думаю...';
      case BallState.speaking:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ballData = ref.watch(ballStateProvider);
    final stateColor = _getStateColor(ballData.state);

    return Scaffold(
      backgroundColor: const Color(0xFF04060a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04060a),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Text('🎮', style: TextStyle(fontSize: 24)),
            onPressed: () => Navigator.pushNamed(context, '/games'),
            tooltip: 'Ігри',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    stateColor.withOpacity(0.08),
                    const Color(0xFF04060a),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ballData.displayText.isNotEmpty
                            ? Text(
                                ballData.displayText,
                                key: ValueKey(ballData.displayText),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  height: 1.6,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: BalabonySphere(
                      state: ballData.state,
                      amplitude: ballData.amplitude,
                      onTap: () => ref.read(ballStateProvider.notifier).onTap(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity:
                          _getHintText(ballData.state).isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _getHintText(ballData.state),
                        style: TextStyle(
                          color: ballData.state == BallState.thinking
                              ? const Color(0xFF7b1fa2)
                              : Colors.white.withOpacity(0.4),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
