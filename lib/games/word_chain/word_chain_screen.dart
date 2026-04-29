import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordChainScreen extends StatefulWidget {
  const WordChainScreen({super.key});

  @override
  State<WordChainScreen> createState() => _WordChainScreenState();
}

const _gold = Color(0xFFEF9F27);
const _goldDim = Color(0xFF7A5010);
const _bg = Color(0xFF000512);
const _cardBg = Color(0xFF040D20);

final _dictionary = {
  '�ȯ�', '²���', '����', '���ֲ�', '������', '�˲�',
  '����', '����', '����', '����', '�����', '����',
  '�������', '�����', '��Ͳ���', '����', '�����',
  '�����', '����', '����', '����', '�����', '�����',
  '������', '��в��', '�����', '���', '����', '�����',
  '������', '������', '�����', '�²�ֲ�', '�����',
  '�����', '������', '����', '���', '�����', '���',
  '����', '�����', '����', '������', '������', '������',
  '������', '������', '������', '�����', '�����',
  '��̲�', '������', '������', '��ղ�', '�������',
  '�����', '����', '�������', '�Բ��', '������',
  '�����', '����', '�����', '������', '�����', '����',
  '��Ҳ�', '������', '�����', '�����', '������',
  '������', '���˲�����', '�����', '�����', '�������',
  '�������', '����²�', '�������', '�����', '�������',
  '������', '������', '������', '����', '����Ͳ�',
  '�������', '��������', '�����', '������', '�����',
  '������', '�����', '�����', '��˲��', '�������',
  '������', '����', '��ײ�', '�����', '²���', '²���',
  '²��', '²���', '����', '�������', '������',
  '������', '������', '�����Ͳ�', '�������', 'ò����',
  '�Ͳ���', '�����', '��в�', '����', '��������',
  '�в�', '����', '�����', '�����', '�����',
  '������', '�������', '��²�', '�����', '����',
  'Ĳ�����', 'Ĳ�����', '������', '����', '�����',
  '�����', '��������', '����ò�', '������',
  '��������', '������', '����', '������',
  '�����', '�������', '������', '�����', '�����',
  '������', '����', 'ǲ���', '�����', '�̲�', '������',
  '�������', '�Ͳ�', '�����', '����в�',
  '������', '��̲��', '�������', '�������', '�²���',
  'ʲ�����', '�����', '�����', '������', '��˲��',
  '��˲�', '������', '������', '������', '��ϲ���',
  '��������', '������', '�������', '�������', '�����',
  '������', '�����', '���������', '��˲�', '�����',
  '�����', '���Ҳ���', '�������', '�����', '������',
  '�����', '˲���', '˲���', '˲����', '������',
  '���', '�����', '����', '����', '������',
  '������', '������', '������', '������', '�������',
  '�������', '�����', '�����', '������', '�����',
  '����Ĳ�', '������', '̲����', '̲��', '������',
  '������', '�����', '������', '�����', '�в�',
  '��������', '��Ĳ�', '�����', '�����', '�����',
  '��Ѳ���', '���������', '�����', '��������',
  '������', '������', '����', 'Ͳ�', 'Ͳ�',
  '��в�', '����', '�ò���', '�˲����', '�����',
  '���²��', '�������', '�Ѳ��', '���в�', '�������',
  '�����', '��ò�', '����', '������', '��������',
  '��������', '����', '����', '�����', '��Ѳ��',
  '������', '��������', '������', 'ϲ���',
  '������', '�����', '���ǲ�', '����', '�����',
  '�������', '������', '������', '������', '�������',
  '���̲��', '�����', '���Բ��', '����', '�������',
  '��Ĳ���', '�������', '������', '�������', 'в���',
  '����', '������', '������',
  '�����', '������', '�²���', '����', '�����',
  '�������', '�Ͳ�', '����', '�����', '��ϲ���',
  '�ϲ�', '����', '��в���', '�������', '������',
  '��в���', '��������', '�������', '������', '������',
  '�������', '�����', '�������',
  '���������', '�������', '���������', '�����', '����',
  '�����', '�����', '������', 'Բ����', '�������',
  '����', '�����', '�˲�', '�����', '����',
  '������', '�����', '�����', '�������',
  '�����', '�����', '��в����', '�������', '�������',
  '�����', '�����', '�������', '�����', '����',
  '�����', '���в���', '��������',
  '����', '�Ͳ���',
  '��������', '�²�', '�����', '�ʲ�', '�������',
};

class _WordChainScreenState extends State<WordChainScreen> {
  final List<String> _chain = [];
  String _input = '';
  String? _message;
  bool _isError = false;
  int _score = 0;
  final _controller = TextEditingController();
  final _focus = FocusNode();

  String? get _lastLetter =>
      _chain.isEmpty ? null : _chain.last.characters.last.toUpperCase();

  void _submit() {
    final word = _input.trim().toUpperCase();
    if (word.isEmpty) return;

    if (!_dictionary.contains(word)) {
      setState(() {
        _message = '�$word� �� �������� � ��������';
        _isError = true;
      });
      return;
    }

    if (_chain.contains(word)) {
      setState(() {
        _message = '�$word� ��� ���� �����������';
        _isError = true;
      });
      return;
    }

    if (_lastLetter != null &&
        word.characters.first.toUpperCase() != _lastLetter) {
      setState(() {
        _message = '����� �� ���������� � �$_lastLetter�';
        _isError = true;
      });
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _chain.add(word);
      _score += word.length;
      _input = '';
      _message = null;
      _isError = false;
    });
    _controller.clear();
    _focus.requestFocus();
  }

  void _reset() {
    setState(() {
      _chain.clear();
      _input = '';
      _message = null;
      _isError = false;
      _score = 0;
    });
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('�������� ���',
            style: TextStyle(
                color: _gold, fontSize: 26, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('$_score ����',
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildHint(),
          const SizedBox(height: 16),
          _buildInput(),
          if (_message != null) _buildMessage(),
          const SizedBox(height: 8),
          Expanded(child: _buildChain()),
          _buildResetButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border.all(color: _goldDim, width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('�������� ����� ���������� �  ',
              style: TextStyle(color: Colors.white54, fontSize: 17)),
          Text(
            _lastLetter ?? '����-��� �����',
            style: TextStyle(
              color: _lastLetter != null ? _gold : Colors.white38,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '������ �����...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: _cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _goldDim, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _goldDim, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _gold, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
              onChanged: (v) => setState(() => _input = v),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _submit,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_forward, color: _bg, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isError
              ? Colors.red.withOpacity(0.1)
              : _gold.withOpacity(0.1),
          border: Border.all(
            color: _isError ? Colors.redAccent : _gold,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _message!,
          style: TextStyle(
            color: _isError ? Colors.redAccent : _gold,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChain() {
    if (_chain.isEmpty) {
      return Center(
        child: Text(
          '������ ����� �����',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 18),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _chain.length,
      reverse: true,
      itemBuilder: (_, i) {
        final word = _chain[_chain.length - 1 - i];
        final isLast = i == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isLast ? _gold : _cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLast ? _gold : _goldDim,
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${_chain.length - i}',
                    style: TextStyle(
                      color: isLast ? _bg : _goldDim,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    border: Border.all(
                      color: isLast ? _gold : _goldDim.withOpacity(0.4),
                      width: isLast ? 1.2 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        word,
                        style: TextStyle(
                          color: isLast ? _gold : Colors.white70,
                          fontSize: 20,
                          fontWeight: isLast
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+${word.length}',
                        style: TextStyle(
                          color: isLast ? _gold : _goldDim,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _reset,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '���� ���',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _bg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

