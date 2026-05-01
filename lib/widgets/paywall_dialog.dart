import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_service.dart';
import '../providers/subscription_provider.dart';

class PaywallDialog extends ConsumerStatefulWidget {
  const PaywallDialog({super.key});

  @override
  ConsumerState<PaywallDialog> createState() => _PaywallDialogState();
}

class _PaywallDialogState extends ConsumerState<PaywallDialog> {
  String _selectedPlan = 'monthly';
  bool _subscribing = false;
  bool _restoring = false;
  String? _restoreMessage;
  bool? _restoreSuccess;

  bool get _loading => _subscribing || _restoring;

  static const _gold = Color(0xFFEF9F27);
  static const _bg   = Color(0xFF080d1a);

  // ─── Subscribe ─────────────────────────────────────────────────────────────
  Future<void> _subscribe() async {
    setState(() => _subscribing = true);
    try {
      await SubscriptionService().launchPayment(plan: _selectedPlan);
    } finally {
      if (mounted) setState(() => _subscribing = false);
    }
  }

  // ─── Restore Purchase ──────────────────────────────────────────────────────
  Future<void> _restorePurchase() async {
    setState(() { _restoring = true; _restoreMessage = null; });
    try {
      final result = await SubscriptionService().restorePurchase();
      if (!mounted) return;

      if (result?['restored'] == true) {
        await ref.read(subscriptionProvider.notifier).refresh();
        if (!mounted) return;
        final formatted = _formatDate(result!['expires_at'] as String? ?? '');
        setState(() {
          _restoreMessage = '✓ Підписку відновлено! Діє до $formatted';
          _restoreSuccess = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _restoreMessage = 'Активну підписку не знайдено';
          _restoreSuccess = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _restoreMessage = 'Помилка з\'єднання. Спробуйте ще раз';
          _restoreSuccess = false;
        });
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  String _formatDate(String iso) {
    const months = [
      'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
      'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
    ];
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day} ${months[dt.month - 1]} ${dt.year} р.';
    } catch (_) {
      return iso;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _gold.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.08),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildFeatures(),
            _buildPlanToggle(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gold.withOpacity(0.15), _gold.withOpacity(0.03)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFEF9F27), Color(0xFFb87020)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Балабон Преміум',
            style: TextStyle(
              color: _gold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Розмовляйте вільно,\nскільки завгодно',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    const features = [
      ('✓', 'Необмежені розмови з Балабоном'),
      ('✓', 'Природний живий голос'),
      ('✓', 'Аудіоісторії та казки'),
      ('✓', 'Поруч у будь-який момент'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Column(
        children: features.map((f) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Text(f.$1,
                style: const TextStyle(
                  color: _gold, fontSize: 17, fontWeight: FontWeight.bold,
                )),
              const SizedBox(width: 12),
              Text(f.$2,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85), fontSize: 15,
                )),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPlanToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(child: _PlanCard(
            label: '1 місяць',
            price: '99 грн',
            sublabel: null,
            selected: _selectedPlan == 'monthly',
            onTap: () => setState(() => _selectedPlan = 'monthly'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _PlanCard(
            label: '1 рік',
            price: '799 грн',
            sublabel: 'Економія 33%',
            selected: _selectedPlan == 'yearly',
            onTap: () => setState(() => _selectedPlan = 'yearly'),
          )),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // ── Subscribe ──────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _subscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: const Color(0xFF080d1a),
                disabledBackgroundColor: _gold.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _subscribing
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Color(0xFF080d1a),
                      ),
                    )
                  : const Text(
                      'Підписатися',
                      style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Restore Purchase ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: _loading ? null : _restorePurchase,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.7),
                disabledForegroundColor: Colors.white.withOpacity(0.2),
                side: BorderSide(
                  color: _loading
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _restoring
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    )
                  : const Text(
                      'Відновити підписку',
                      style: TextStyle(fontSize: 15),
                    ),
            ),
          ),

          // ── Restore feedback ───────────────────────────────────────────────
          if (_restoreMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _restoreMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _restoreSuccess == true
                    ? const Color(0xFF66BB6A)
                    : Colors.redAccent.withOpacity(0.85),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],

          // ── Dismiss ────────────────────────────────────────────────────────
          TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(false),
            child: Text(
              'Не зараз',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan Card ───────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final String label;
  final String price;
  final String? sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.label,
    required this.price,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  static const _gold = Color(0xFFEF9F27);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _gold.withOpacity(0.12) : const Color(0xFF0f1628),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _gold : Colors.white.withOpacity(0.1),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? _gold : Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white.withOpacity(0.85),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (sublabel != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sublabel!,
                  style: const TextStyle(color: _gold, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
