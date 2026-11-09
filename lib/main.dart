import 'package:flutter/material.dart';

void main() => runApp(const CurrencyApp());

const _denominations = <int>[500, 200, 100, 50, 20, 10];
const _ink = Color(0xFF14382F);
const _green = Color(0xFF16745A);

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _green,
      brightness: Brightness.light,
      surface: const Color(0xFFF5F7F4),
    );
    return MaterialApp(
      title: 'Currency',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF4F7F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
      home: const CashCounterPage(),
    );
  }
}

class CashCounterPage extends StatefulWidget {
  const CashCounterPage({super.key});

  @override
  State<CashCounterPage> createState() => _CashCounterPageState();
}

class _CashCounterPageState extends State<CashCounterPage> {
  late final Map<int, TextEditingController> _controllers;

  int _quantity(int denomination) =>
      int.tryParse(_controllers[denomination]!.text) ?? 0;

  int get _total => _denominations.fold<int>(
    0,
    (sum, denomination) => sum + denomination * _quantity(denomination),
  );

  int get _noteCount => _denominations.fold<int>(
    0,
    (sum, denomination) => sum + _quantity(denomination),
  );

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final denomination in _denominations)
        denomination: TextEditingController()..addListener(_refresh),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _setQuantity(int denomination, int value) {
    final controller = _controllers[denomination]!;
    final next = value <= 0 ? '' : value.toString();
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  void _clearAll() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
  }

  Future<void> _editQuantity(int denomination) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuantityKeypad(
        denomination: denomination,
        initialValue: _controllers[denomination]!.text,
      ),
    );
    if (result != null && mounted) _setQuantity(denomination, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;
            final dense = constraints.maxHeight < 580;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 14 : 20,
                    compact ? 8 : 16,
                    compact ? 14 : 20,
                    compact ? 8 : 16,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(compact: compact),
                      SizedBox(height: compact ? 8 : 16),
                      _buildTotalCard(compact: compact, dense: dense),
                      SizedBox(height: compact ? 8 : 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Count your notes',
                              style: TextStyle(
                                fontSize: compact ? 16 : 19,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _noteCount == 0 ? null : _clearAll,
                            icon: const Icon(
                              Icons.restart_alt_rounded,
                              size: 18,
                            ),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 2 : 6),
                      Expanded(
                        child: Column(
                          children: [
                            for (final denomination in _denominations)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: denomination == _denominations.last
                                        ? 0
                                        : (compact ? 5 : 8),
                                  ),
                                  child: _buildDenominationRow(
                                    denomination,
                                    compact: compact,
                                    dense: dense,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({required bool compact}) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/currency_logo.png',
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
          ),
        ),
        SizedBox(width: compact ? 9 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Currency',
                style: TextStyle(
                  fontSize: compact ? 20 : 23,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                  letterSpacing: -.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Quick cash counter',
                style: TextStyle(fontSize: 13, color: Color(0xFF718078)),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFE6F1E8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 9 : 11,
              vertical: compact ? 5 : 7,
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 15, color: _green),
                SizedBox(width: 4),
                Text(
                  'INR',
                  style: TextStyle(
                    color: _green,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard({required bool compact, required bool dense}) {
    return Container(
      padding: EdgeInsets.all(dense ? 8 : (compact ? 12 : 22)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF17483B), Color(0xFF0E3028)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: .17),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL CASH',
                  style: TextStyle(
                    color: Color(0xFFC5D8CD),
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: dense ? 24 : (compact ? 28 : 36),
                height: dense ? 24 : (compact ? 28 : 36),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),
          SizedBox(height: dense ? 2 : (compact ? 3 : 10)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹ ${_formatIndian(_total)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: dense ? 24 : (compact ? 29 : 38),
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
          ),
          SizedBox(height: dense ? 4 : (compact ? 7 : 17)),
          Container(height: 1, color: Colors.white.withValues(alpha: .15)),
          SizedBox(height: dense ? 4 : (compact ? 6 : 13)),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: Color(0xFFB7D4C2),
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                '$_noteCount notes counted',
                style: const TextStyle(
                  color: Color(0xFFDCE9E0),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (_noteCount > 0)
                Text(
                  '$_activeDenominations values',
                  style: const TextStyle(
                    color: Color(0xFFB7D4C2),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  int get _activeDenominations => _denominations
      .where((denomination) => _quantity(denomination) > 0)
      .length;

  Widget _buildDenominationRow(
    int denomination, {
    required bool compact,
    required bool dense,
  }) {
    final quantity = _quantity(denomination);
    final subtotal = denomination * quantity;
    final tint = _noteTint(denomination);
    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 8 : 12,
        dense ? 3 : (compact ? 4 : 12),
        compact ? 8 : 14,
        dense ? 3 : (compact ? 4 : 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080E3028),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: dense ? 54 : (compact ? 62 : 72),
            height: dense ? 30 : (compact ? 36 : 48),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 7,
                  top: 6,
                  child: Icon(
                    Icons.circle_outlined,
                    size: 9,
                    color: _ink.withValues(alpha: .22),
                  ),
                ),
                Text(
                  '₹$denomination',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: -.5,
                  ),
                ),
                Positioned(
                  right: 7,
                  bottom: 6,
                  child: Icon(
                    Icons.circle_outlined,
                    size: 9,
                    color: _ink.withValues(alpha: .22),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${_formatIndian(denomination)} note',
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: dense ? 11 : (compact ? 12 : 13),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ ${_formatIndian(subtotal)}',
                  style: TextStyle(
                    color: quantity == 0 ? const Color(0xFF9AA7A0) : _green,
                    fontWeight: FontWeight.w800,
                    fontSize: dense ? 12 : (compact ? 13 : 14),
                  ),
                ),
              ],
            ),
          ),
          _stepButton(
            icon: Icons.remove_rounded,
            enabled: quantity > 0,
            onPressed: () => _setQuantity(denomination, quantity - 1),
            compact: compact,
            dense: dense,
          ),
          SizedBox(width: compact ? 3 : 6),
          SizedBox(
            width: dense ? 42 : (compact ? 48 : 58),
            child: TextField(
              controller: _controllers[denomination],
              readOnly: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                isDense: true,
                contentPadding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(
                  height: dense ? 30 : (compact ? 34 : 40),
                ),
              ),
              onTap: () => _editQuantity(denomination),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: dense ? 13 : (compact ? 14 : 16),
                color: _ink,
              ),
            ),
          ),
          SizedBox(width: compact ? 3 : 6),
          _stepButton(
            icon: Icons.add_rounded,
            enabled: quantity < 999999,
            onPressed: () => _setQuantity(denomination, quantity + 1),
            compact: compact,
            dense: dense,
          ),
        ],
      ),
    );
  }

  Widget _stepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
    required bool compact,
    required bool dense,
  }) {
    return SizedBox(
      width: dense ? 26 : (compact ? 30 : 34),
      height: dense ? 26 : (compact ? 30 : 38),
      child: IconButton.filledTonal(
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        iconSize: 19,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFEDF4EF),
          foregroundColor: _green,
          disabledBackgroundColor: const Color(0xFFF4F6F4),
          disabledForegroundColor: const Color(0xFFB7C1BB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }
}

class _QuantityKeypad extends StatefulWidget {
  const _QuantityKeypad({
    required this.denomination,
    required this.initialValue,
  });

  final int denomination;
  final String initialValue;

  @override
  State<_QuantityKeypad> createState() => _QuantityKeypadState();
}

class _QuantityKeypadState extends State<_QuantityKeypad> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _press(String key) {
    setState(() {
      if (key == 'C') {
        _value = '';
      } else if (key == '?') {
        if (_value.isNotEmpty) _value = _value.substring(0, _value.length - 1);
      } else if (_value.length < 6) {
        _value += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const rows = <List<String>>[
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '?'],
    ];
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '?${widget.denomination} notes',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6F3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _value.isEmpty ? '0' : _value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final row in rows)
              Row(
                children: [
                  for (final key in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.tonal(
                            onPressed: () => _press(key),
                            child: Text(
                              key,
                              style: TextStyle(
                                fontSize: key == 'C' || key == '?' ? 18 : 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () =>
                    Navigator.pop(context, int.tryParse(_value) ?? 0),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _noteTint(int denomination) => switch (denomination) {
  500 => const Color(0xFFD9E9D6),
  200 => const Color(0xFFFFE4C9),
  100 => const Color(0xFFFFE2DC),
  50 => const Color(0xFFDCEBFA),
  20 => const Color(0xFFFFF0C9),
  _ => const Color(0xFFE9E0F5),
};

String _formatIndian(int value) {
  final digits = value.toString();
  if (digits.length <= 3) return digits;
  final lastThree = digits.substring(digits.length - 3);
  var leading = digits.substring(0, digits.length - 3);
  final pairs = <String>[];
  while (leading.length > 2) {
    pairs.insert(0, leading.substring(leading.length - 2));
    leading = leading.substring(0, leading.length - 2);
  }
  if (leading.isNotEmpty) pairs.insert(0, leading);
  return '${pairs.join(',')},$lastThree';
}
