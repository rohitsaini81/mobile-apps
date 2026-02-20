import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalcNoteApp());
}

class CalcNoteApp extends StatelessWidget {
  const CalcNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalcNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A5CAA)),
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
      ),
      home: const CalcNotePage(),
    );
  }
}

class CalcNotePage extends StatefulWidget {
  const CalcNotePage({super.key});

  @override
  State<CalcNotePage> createState() => _CalcNotePageState();
}

class _CalcNotePageState extends State<CalcNotePage> {
  static const double _lineHeight = 28;

  final TextEditingController _controller = TextEditingController(
    text: 'rice: 12*5\nshipping = 25\ntotal = 12*5 + shipping\ntotal*0.1',
  );
  final FocusNode _focusNode = FocusNode();
  final ScrollController _noteScroll = ScrollController();
  final ScrollController _resultScroll = ScrollController();

  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _noteScroll.addListener(_syncScroll);
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _noteScroll.removeListener(_syncScroll);
    _controller.removeListener(_refresh);
    _controller.dispose();
    _focusNode.dispose();
    _noteScroll.dispose();
    _resultScroll.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncScroll() {
    if (_syncing || !_resultScroll.hasClients) {
      return;
    }
    _syncing = true;
    _resultScroll.jumpTo(
      _noteScroll.offset.clamp(0.0, _resultScroll.position.maxScrollExtent),
    );
    _syncing = false;
  }

  List<String> get _lines => _controller.text.split('\n');

  List<String> get _results {
    final engine = _CalcEngine(_lines);
    return engine.evaluate().map((e) => e.display).toList(growable: false);
  }

  String _activeLineText() {
    final selection = _controller.selection;
    final text = _controller.text;
    final cursor = selection.baseOffset.clamp(0, text.length);

    int start = cursor;
    while (start > 0 && text[start - 1] != '\n') {
      start--;
    }

    int end = cursor;
    while (end < text.length && text[end] != '\n') {
      end++;
    }

    return text.substring(start, end);
  }

  void _setTextAndCursor(String text, int cursor) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor.clamp(0, text.length)),
    );
    _focusNode.requestFocus();
  }

  void _insert(String value) {
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final updated = text.replaceRange(start, end, value);
    _setTextAndCursor(updated, start + value.length);
  }

  void _newline() => _insert('\n');

  void _backspace() {
    final selection = _controller.selection;
    final text = _controller.text;
    int start = selection.start >= 0 ? selection.start : text.length;
    int end = selection.end >= 0 ? selection.end : text.length;

    if (start == end && start > 0) {
      start -= 1;
    }
    if (start == end) {
      return;
    }

    final updated = text.replaceRange(start, end, '');
    _setTextAndCursor(updated, start);
  }

  void _clearLineOrAll() {
    final text = _controller.text;
    final selection = _controller.selection;
    final cursor = selection.baseOffset >= 0 ? selection.baseOffset : text.length;

    int start = cursor;
    while (start > 0 && text[start - 1] != '\n') {
      start--;
    }

    int end = cursor;
    while (end < text.length && text[end] != '\n') {
      end++;
    }

    final line = text.substring(start, end);
    if (line.trim().isEmpty && text.trim().isNotEmpty) {
      _setTextAndCursor('', 0);
      return;
    }

    final updated = text.replaceRange(start, end, '');
    _setTextAndCursor(updated, start);
  }

  void _moveCursor(int delta) {
    final text = _controller.text;
    final current = _controller.selection.baseOffset >= 0
        ? _controller.selection.baseOffset
        : text.length;
    _setTextAndCursor(text, (current + delta).clamp(0, text.length));
  }

  void _moveCursorWord(int direction) {
    final text = _controller.text;
    final current = _controller.selection.baseOffset >= 0
        ? _controller.selection.baseOffset
        : text.length;
    int next = current;

    bool isWordChar(String c) => RegExp(r'[A-Za-z0-9_]').hasMatch(c);

    if (direction < 0) {
      if (next == 0) {
        return;
      }
      next--;
      while (next > 0 && !isWordChar(text[next])) {
        next--;
      }
      while (next > 0 && isWordChar(text[next - 1])) {
        next--;
      }
    } else {
      if (next >= text.length) {
        return;
      }
      while (next < text.length && !isWordChar(text[next])) {
        next++;
      }
      while (next < text.length && isWordChar(text[next])) {
        next++;
      }
    }

    _setTextAndCursor(text, next.clamp(0, text.length));
  }

  void _evaluateAndAppend() {
    final line = _activeLineText();
    final engine = _CalcEngine([line]);
    final result = engine.evaluate().first;
    if (!result.hasValue) {
      return;
    }
    _newline();
    _insert(result.display);
  }

  void _onKeyPress(String key) {
    switch (key) {
      case 'C':
        _clearLineOrAll();
        return;
      case '⌫':
        _backspace();
        return;
      case '←':
        _moveCursor(-1);
        return;
      case '→':
        _moveCursor(1);
        return;
      case '⏎':
        _newline();
        return;
      case '=':
        _evaluateAndAppend();
        return;
      default:
        _insert(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.enter, control: true):
            const _EvaluateIntent(),
        const SingleActivator(LogicalKeyboardKey.enter, meta: true):
            const _EvaluateIntent(),
        const SingleActivator(LogicalKeyboardKey.escape): const _ClearIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
            const _WordLeftIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
            const _WordRightIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _EvaluateIntent: CallbackAction<_EvaluateIntent>(
            onInvoke: (intent) {
              _evaluateAndAppend();
              return null;
            },
          ),
          _ClearIntent: CallbackAction<_ClearIntent>(
            onInvoke: (intent) {
              _clearLineOrAll();
              return null;
            },
          ),
          _WordLeftIntent: CallbackAction<_WordLeftIntent>(
            onInvoke: (intent) {
              _moveCursorWord(-1);
              return null;
            },
          ),
          _WordRightIntent: CallbackAction<_WordRightIntent>(
            onInvoke: (intent) {
              _moveCursorWord(1);
              return null;
            },
          ),
        },
        child: Scaffold(
          appBar: AppBar(
        elevation: 0,
        title: const Text('CalcNote'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(22),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Notepad Calculator',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ),
        ),
      ),
          body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 34,
                      child: ListView.builder(
                        controller: _resultScroll,
                        itemCount: _lines.length,
                        padding: const EdgeInsets.only(top: 16),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: _lineHeight,
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        readOnly: false,
                        showCursor: true,
                        autofocus: true,
                        expands: true,
                        maxLines: null,
                        scrollController: _noteScroll,
                        enableInteractiveSelection: true,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(
                          fontSize: 19,
                          height: 1.45,
                          letterSpacing: 0.2,
                        ),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(4, 16, 8, 16),
                        ),
                      ),
                    ),
                    Container(
                      width: 128,
                      padding: const EdgeInsets.fromLTRB(8, 16, 12, 16),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: ListView.builder(
                        controller: _resultScroll,
                        itemCount: results.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: _lineHeight,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                results[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: results[index] == 'Error'
                                      ? const Color(0xFFB91C1C)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _CalcKeypad(onPress: _onKeyPress),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

class _EvaluateIntent extends Intent {
  const _EvaluateIntent();
}

class _ClearIntent extends Intent {
  const _ClearIntent();
}

class _WordLeftIntent extends Intent {
  const _WordLeftIntent();
}

class _WordRightIntent extends Intent {
  const _WordRightIntent();
}

class _CalcKeypad extends StatefulWidget {
  const _CalcKeypad({required this.onPress});

  final ValueChanged<String> onPress;

  @override
  State<_CalcKeypad> createState() => _CalcKeypadState();
}

class _CalcKeypadState extends State<_CalcKeypad> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<List<List<String>>> _pages = [
    [
      ['C', '(', ')', '⌫', '/'],
      ['7', '8', '9', '*', '←'],
      ['4', '5', '6', '-', '→'],
      ['1', '2', '3', '+', '⏎'],
      ['0', '00', '.', '%', '='],
    ],
    [
      ['sin(', 'cos(', 'tan(', 'sqrt(', '⌫'],
      ['log(', 'ln(', '^', 'mod', '←'],
      ['pi', 'e', 'abs(', '(', '→'],
      ['7', '8', '9', ')', '⏎'],
      ['0', '.', '1', '2', '='],
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F4F8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 294,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (value) => setState(() => _page = value),
              itemCount: _pages.length,
              itemBuilder: (context, pageIndex) {
                final rows = _pages[pageIndex];
                return Column(
                  children: rows
                      .map(
                        (row) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: row
                                .map(
                                  (key) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: _KeyButton(
                                        label: key,
                                        accent: key == '=',
                                        secondary: _isSecondary(key),
                                        onTap: () => widget.onPress(
                                          key == 'pi' ? '3.1415926535' :
                                          key == 'e' ? '2.7182818284' : key,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              final active = index == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF2A5CAA)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isSecondary(String key) {
    const secondary = {
      'C',
      '⌫',
      '←',
      '→',
      '⏎',
      '/',
      '*',
      '-',
      '+',
      '%',
      '(',
      ')',
      'mod',
      '^',
      'sin(',
      'cos(',
      'tan(',
      'sqrt(',
      'log(',
      'ln(',
      'abs(',
      'pi',
      'e',
    };
    return secondary.contains(key);
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.onTap,
    required this.accent,
    required this.secondary,
  });

  final String label;
  final VoidCallback onTap;
  final bool accent;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final bg = accent
        ? const Color(0xFF2A5CAA)
        : secondary
        ? const Color(0xFFE7EDF8)
        : Colors.white;

    final fg = accent
        ? Colors.white
        : secondary
        ? const Color(0xFF1E3A6D)
        : const Color(0xFF0F172A);

    return SizedBox(
      height: 50,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _CalcEngine {
  _CalcEngine(this.lines);

  final List<String> lines;

  List<_LineResult> evaluate() {
    final vars = <String, double>{};
    final values = <double?>[];
    final results = <_LineResult>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final parsed = _extractExpression(line);
      if (parsed == null) {
        results.add(const _LineResult.empty());
        values.add(null);
        continue;
      }

      final expression = _replaceLineReferences(parsed.expression, values);
      final parser = _ExpressionParser(expression, vars: vars);
      final value = parser.parse();

      if (value == null || value.isNaN || value.isInfinite) {
        results.add(const _LineResult.error());
        values.add(null);
        continue;
      }

      if (parsed.variableName != null) {
        vars[parsed.variableName!] = value;
      }

      results.add(_LineResult.value(_formatNumber(value)));
      values.add(value);
    }

    return results;
  }

  String _replaceLineReferences(String expression, List<double?> values) {
    return expression.replaceAllMapped(RegExp(r'\$(\d+)'), (match) {
      final line = int.tryParse(match.group(1) ?? '');
      if (line == null || line < 1 || line > values.length) {
        return '0';
      }
      final value = values[line - 1];
      return value?.toString() ?? '0';
    });
  }

  _ParsedLine? _extractExpression(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty ||
        trimmed.startsWith('//') ||
        trimmed.startsWith('#') ||
        trimmed.startsWith(';')) {
      return null;
    }

    final assign = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(.+)$')
        .firstMatch(trimmed);
    if (assign != null) {
      return _ParsedLine(assign.group(2)!, variableName: assign.group(1));
    }

    if (trimmed.contains(':')) {
      final idx = trimmed.lastIndexOf(':');
      final candidate = trimmed.substring(idx + 1).trim();
      if (candidate.isNotEmpty) {
        return _ParsedLine(candidate);
      }
    }

    if (RegExp(r'[0-9)]').hasMatch(trimmed) &&
        RegExp(r'[+\-*/%^()]').hasMatch(trimmed)) {
      return _ParsedLine(trimmed);
    }

    return null;
  }
}

class _ParsedLine {
  const _ParsedLine(this.expression, {this.variableName});

  final String expression;
  final String? variableName;
}

class _LineResult {
  const _LineResult(this.display, this.hasValue);

  const _LineResult.empty() : this('', false);

  const _LineResult.error() : this('Error', false);

  const _LineResult.value(String value) : this(value, true);

  final String display;
  final bool hasValue;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  final fixed = value.toStringAsFixed(10);
  return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

class _ExpressionParser {
  _ExpressionParser(this.input, {required this.vars});

  final String input;
  final Map<String, double> vars;
  int _index = 0;

  double? parse() {
    try {
      final value = _parseExpression();
      _skipSpaces();
      if (_index != input.length) {
        return null;
      }
      return value;
    } catch (_) {
      return null;
    }
  }

  double _parseExpression() {
    var value = _parseTerm();
    while (true) {
      _skipSpaces();
      if (_consume('+')) {
        value += _parseTerm();
      } else if (_consume('-')) {
        value -= _parseTerm();
      } else {
        break;
      }
    }
    return value;
  }

  double _parseTerm() {
    var value = _parsePower();
    while (true) {
      _skipSpaces();
      if (_consume('*')) {
        value *= _parsePower();
      } else if (_consume('/')) {
        value /= _parsePower();
      } else if (_consume('%')) {
        value %= _parsePower();
      } else if (_consumeWord('mod')) {
        value %= _parsePower();
      } else {
        break;
      }
    }
    return value;
  }

  double _parsePower() {
    var value = _parseFactor();
    _skipSpaces();
    if (_consume('^')) {
      final exponent = _parsePower();
      return math.pow(value, exponent).toDouble();
    }
    return value;
  }

  double _parseFactor() {
    _skipSpaces();

    if (_consume('+')) {
      return _parseFactor();
    }
    if (_consume('-')) {
      return -_parseFactor();
    }

    if (_consume('(')) {
      final value = _parseExpression();
      _expect(')');
      return _applyPercent(value);
    }

    final ident = _parseIdentifier();
    if (ident != null) {
      if (_consume('(')) {
        final arg = _parseExpression();
        _expect(')');
        return _applyPercent(_callFunction(ident, arg));
      }
      if (ident == 'pi') {
        return _applyPercent(math.pi);
      }
      if (ident == 'e') {
        return _applyPercent(math.e);
      }
      return _applyPercent(vars[ident] ?? (throw const FormatException('Unknown variable')));
    }

    final number = _parseNumber();
    return _applyPercent(number);
  }

  double _applyPercent(double value) {
    _skipSpaces();
    if (_consume('%')) {
      return value / 100.0;
    }
    return value;
  }

  double _callFunction(String name, double arg) {
    switch (name) {
      case 'sin':
        return math.sin(arg);
      case 'cos':
        return math.cos(arg);
      case 'tan':
        return math.tan(arg);
      case 'sqrt':
        return math.sqrt(arg);
      case 'log':
        return math.log(arg) / math.ln10;
      case 'ln':
        return math.log(arg);
      case 'abs':
        return arg.abs();
      default:
        throw const FormatException('Unsupported function');
    }
  }

  double _parseNumber() {
    _skipSpaces();
    final start = _index;
    var hasDot = false;

    while (_index < input.length) {
      final c = input[_index];
      final digit = c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
      if (digit) {
        _index++;
      } else if (c == '.' && !hasDot) {
        hasDot = true;
        _index++;
      } else {
        break;
      }
    }

    if (start == _index) {
      throw const FormatException('Expected number');
    }

    return double.parse(input.substring(start, _index));
  }

  String? _parseIdentifier() {
    _skipSpaces();
    if (_index >= input.length) {
      return null;
    }

    final start = _index;
    final first = input[_index];
    if (!_isLetter(first) && first != '_') {
      return null;
    }

    _index++;
    while (_index < input.length) {
      final c = input[_index];
      if (_isLetter(c) || _isDigit(c) || c == '_') {
        _index++;
      } else {
        break;
      }
    }

    return input.substring(start, _index);
  }

  bool _consume(String token) {
    _skipSpaces();
    if (_index < input.length && input[_index] == token) {
      _index++;
      return true;
    }
    return false;
  }

  bool _consumeWord(String word) {
    _skipSpaces();
    final end = _index + word.length;
    if (end > input.length || input.substring(_index, end) != word) {
      return false;
    }

    if (end < input.length && _isLetterOrDigitOrUnderscore(input[end])) {
      return false;
    }

    _index = end;
    return true;
  }

  void _expect(String token) {
    if (!_consume(token)) {
      throw const FormatException('Unexpected token');
    }
  }

  void _skipSpaces() {
    while (_index < input.length && input[_index] == ' ') {
      _index++;
    }
  }

  bool _isLetter(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  bool _isLetterOrDigitOrUnderscore(String c) {
    return _isLetter(c) || _isDigit(c) || c == '_';
  }
}
