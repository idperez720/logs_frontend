// lib/features/home/presentation/widgets/composer.dart
import 'dart:async';
import 'package:flutter/material.dart';

class Composer extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String hint;

  /// Configurable typography
  final double fontSize;
  final double lineHeight;

  /// Optional: monospace toggle for pure typewriter feel
  final bool monospace;

  const Composer({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint = 'Start typing your log…',
    this.fontSize = 22.0,
    this.lineHeight = 1.4,
    this.monospace = true,
  });

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _c =
      TextEditingController(text: widget.value);
  final _focus = FocusNode();
  final _editableKey = GlobalKey<EditableTextState>();

  String _hintShown = '';
  Timer? _t;
  bool _suppressChange = false;

  // Blinking cursor controller (for the custom horizontal caret)
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _startHint();

    _c.addListener(() {
      if (_suppressChange) return;
      widget.onChanged(_c.text);
      // move cursor painter
      setState(() {});
    });

    _focus.addListener(() {
      if (_focus.hasFocus) {
        _stopHint();
        _blink.repeat();
      } else {
        if (_c.text.isEmpty) _startHint();
        _blink.stop();
      }
      setState(() {});
    });
  }

  void _startHint() {
    _t?.cancel();
    _hintShown = '';
    var i = 0;
    _t = Timer.periodic(const Duration(milliseconds: 55), (p) {
      if (!mounted || _c.text.isNotEmpty || _focus.hasFocus) {
        p.cancel();
        return;
      }
      if (i >= widget.hint.length) {
        p.cancel();
        return;
      }
      setState(() => _hintShown = widget.hint.substring(0, i + 1));
      i++;
    });
  }

  void _stopHint() => _t?.cancel();

  @override
  void didUpdateWidget(covariant Composer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _c.text) {
      _suppressChange = true;
      final newText = widget.value;
      _c.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      _suppressChange = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _blink.dispose();
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  TextStyle get _textStyle => TextStyle(
        // Keep it simple + typewriter-y
        fontSize: widget.fontSize,
        height: widget.lineHeight,
        // Using generic monospace family name when requested (best-effort across platforms)
        fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
        // Slightly darker than default for a “ink on paper” feel
        color: Colors.black87,
      );

  @override
  Widget build(BuildContext context) {
    final paperColor = const Color(0xFFFFFFFF); // warm off-white
    final borderColor = const Color(0xFF111111);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: const [
          // tiny drop shadow for “paper on desk”
          BoxShadow(
              blurRadius: 6, offset: Offset(0, 2), color: Color(0x14000000)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            // Subtle top & side margins emulate page margins
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Stack(
                children: [
                  if (_c.text.isEmpty && !_focus.hasFocus)
                    // Animated hint typed-out text
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Text(
                          _hintShown,
                          style: _textStyle.copyWith(color: Colors.black38),
                        ),
                      ),
                    ),

                  // The raw EditableText gives us access to the caret rect
                  _TypewriterEditable(
                    key: _editableKey,
                    controller: _c,
                    focusNode: _focus,
                    style: _textStyle,
                    lineHeight: widget.lineHeight,
                    blink: _blink,
                  ),
                ],
              ),
            ),

            // Minimalist bottom border accent (like a typewriter rail)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(height: 1, color: Colors.black12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal widget that renders an EditableText and paints a custom horizontal caret
class _TypewriterEditable extends StatefulWidget {
  const _TypewriterEditable({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.lineHeight,
    required this.blink,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final double lineHeight;
  final Animation<double> blink;

  @override
  State<_TypewriterEditable> createState() => _TypewriterEditableState();
}

class _TypewriterEditableState extends State<_TypewriterEditable> {
  final _editableKey = GlobalKey<EditableTextState>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
    widget.focusNode.addListener(_onTick);
    widget.blink.addListener(_onTick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    widget.focusNode.removeListener(_onTick);
    widget.blink.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  Rect? _caretRect() {
    final state = _editableKey.currentState;
    if (state == null) return null;
    final render = state.renderEditable;
    final selection = widget.controller.selection;
    if (!selection.isValid) return null;
    // Local rect for the caret
    return render.getLocalRectForCaret(selection.extent);
  }

  @override
  Widget build(BuildContext context) {
    // Text height in px
    final pxLine = widget.style.fontSize! * widget.lineHeight;

    return Stack(
      children: [
        EditableText(
          key: _editableKey,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: widget.style,
          cursorColor: Colors.transparent, // hide default cursor
          backgroundCursorColor: Colors.transparent,
          keyboardType: TextInputType.multiline,
          textAlign: TextAlign.left,
          textCapitalization: TextCapitalization.sentences,
          maxLines: null,
          expands: false,
          // mimic TextField padding via content padding already provided outside
          selectionColor: const Color(0x2A000000),
          selectionControls: materialTextSelectionControls,
          // Disable autocorrect & suggestions for a cleaner typewriter vibe (toggle if you want them)
          autocorrect: false,
          enableSuggestions: false,
        ),

        // Custom horizontal caret (underscore) that blinks
        IgnorePointer(
          child: CustomPaint(
            painter: _HorizontalCaretPainter(
              caretRect: _caretRect(),
              isVisible:
                  widget.focusNode.hasFocus && (widget.blink.value < 0.5),
              thickness: 2.0,
              width: (widget.style.fontSize ?? 16) * 0.6, // underscore length
              baselineOffset: 2.0, // a tiny dip below baseline
              color: Colors.black87,
              lineHeightPx: pxLine,
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalCaretPainter extends CustomPainter {
  _HorizontalCaretPainter({
    required this.caretRect,
    required this.isVisible,
    required this.thickness,
    required this.width,
    required this.baselineOffset,
    required this.color,
    required this.lineHeightPx,
  });

  final Rect? caretRect;
  final bool isVisible;
  final double thickness;
  final double width;
  final double baselineOffset;
  final Color color;
  final double lineHeightPx;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isVisible || caretRect == null) return;

    final rect = caretRect!;
    // Position underscore centered on caret x, near the baseline of the line
    final startX = rect.left - (width / 2);
    final y = rect.bottom - baselineOffset.clamp(0, lineHeightPx);

    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(Offset(startX, y), Offset(startX + width, y), p);
  }

  @override
  bool shouldRepaint(covariant _HorizontalCaretPainter oldDelegate) {
    return oldDelegate.caretRect != caretRect ||
        oldDelegate.isVisible != isVisible ||
        oldDelegate.width != width ||
        oldDelegate.thickness != thickness ||
        oldDelegate.color != color;
  }
}
