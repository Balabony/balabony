import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stories_data.dart';
import '../models/story.dart';
import '../providers/subscription_provider.dart';
import '../services/elevenlabs_service.dart';
import '../services/stories_service.dart';
import '../widgets/paywall_dialog.dart';

class StoriesScreen extends ConsumerStatefulWidget {
  const StoriesScreen({super.key});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen> {
  final _elevenlabs = ElevenLabsService();
  final _storiesService = StoriesService();

  String? _playingId;
  String? _loadingId;

  static const _gold = Color(0xFFEF9F27);
  static const _bg = Color(0xFF000512);
  static const _cardBg = Color(0xFF040D20);

  @override
  void dispose() {
    _elevenlabs.dispose();
    super.dispose();
  }

  Future<void> _onStoryTap(Story story) async {
    if (_loadingId != null) return;

    if (_playingId == story.id) {
      await _elevenlabs.stop();
      setState(() => _playingId = null);
      return;
    }

    if (story.isPremium) {
      final premium = await ref.read(subscriptionProvider.future);
      if (!mounted) return;
      if (!premium) {
        final subscribed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const PaywallDialog(),
        );
        if (subscribed != true || !mounted) return;
      }
    }

    await _elevenlabs.stop();
    setState(() {
      _playingId = null;
      _loadingId = story.id;
    });

    try {
      final text = await _storiesService.getStoryText(story.id);
      if (!mounted) return;
      setState(() {
        _loadingId = null;
        _playingId = story.id;
      });
      await _elevenlabs.speak(text, onComplete: () {
        if (mounted) setState(() => _playingId = null);
      });
    } catch (_) {
      if (mounted) setState(() { _loadingId = null; _playingId = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);
    final isPremium = subState.valueOrNull ?? false;
    final freeStories = allStories.where((s) => !s.isPremium).toList();
    final premiumStories = allStories.where((s) => s.isPremium).toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'Аудіоісторії',
          style: TextStyle(
            color: _gold,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _SectionHeader(label: 'Безкоштовно', showBadge: false),
          const SizedBox(height: 12),
          ...freeStories.map((s) => _StoryCard(
            story: s,
            isPlaying: _playingId == s.id,
            isLoading: _loadingId == s.id,
            isLocked: false,
            onTap: () => _onStoryTap(s),
          )),
          const SizedBox(height: 24),
          _SectionHeader(label: 'Преміум', showBadge: true),
          const SizedBox(height: 12),
          ...premiumStories.map((s) => _StoryCard(
            story: s,
            isPlaying: _playingId == s.id,
            isLoading: _loadingId == s.id,
            isLocked: !isPremium,
            onTap: () => _onStoryTap(s),
          )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool showBadge;

  const _SectionHeader({required this.label, required this.showBadge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBadge)
          const Text('✦ ', style: TextStyle(color: Color(0xFFEF9F27), fontSize: 16)),
        Text(
          label,
          style: TextStyle(
            color: showBadge ? const Color(0xFFEF9F27) : Colors.white.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final bool isPlaying;
  final bool isLoading;
  final bool isLocked;
  final VoidCallback onTap;

  static const _gold = Color(0xFFEF9F27);

  const _StoryCard({
    required this.story,
    required this.isPlaying,
    required this.isLoading,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF040D20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? _gold
                  : story.isPremium
                      ? _gold.withOpacity(0.2)
                      : Colors.white.withOpacity(0.07),
              width: isPlaying ? 1.5 : 1,
            ),
            boxShadow: isPlaying
                ? [BoxShadow(color: _gold.withOpacity(0.1), blurRadius: 12)]
                : null,
          ),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo()),
              const SizedBox(width: 12),
              _buildAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: story.isPremium
                ? _gold.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
          ),
          child: Center(
            child: Text(
              isPlaying ? '🔊' : '📖',
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        if (isLocked)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0a0f1e),
              ),
              child: const Center(
                child: Text('🔒', style: TextStyle(fontSize: 10)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                story.title,
                style: TextStyle(
                  color: isPlaying ? _gold : Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (story.isPremium) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _gold.withOpacity(0.3), width: 0.5),
                ),
                child: const Text(
                  'ПРЕМІУМ',
                  style: TextStyle(color: _gold, fontSize: 9, letterSpacing: 0.8),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          story.description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          story.duration,
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAction() {
    if (isLoading) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _gold,
        ),
      );
    }

    if (isPlaying) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _gold.withOpacity(0.15),
          border: Border.all(color: _gold, width: 1),
        ),
        child: const Icon(Icons.stop_rounded, color: _gold, size: 18),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked
            ? Colors.white.withOpacity(0.04)
            : _gold.withOpacity(0.12),
        border: Border.all(
          color: isLocked ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Icon(
        isLocked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
        color: isLocked ? Colors.white.withOpacity(0.3) : _gold,
        size: 20,
      ),
    );
  }
}
