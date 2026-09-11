import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  /// mood: 0 = BAD, 1 = middle (NOT BAD), 2 = GOOD
  double mood = 2.0;
  String _note = '';

  String get label {
    if (mood < 2 / 3) return 'BAD';
    if (mood < 4 / 3) return 'NOT BAD';
    return 'GOOD';
  }

  // Background ramp (red -> amber -> lime)
  static const _bad = Color(0xFFF44336);
  static const _mid = Color(0xFFFFC107);
  static const _good = Color(0xFFB2FF59);

  Color _bgFor(double v) {
    if (v <= 1) return Color.lerp(_bad, _mid, v.clamp(0, 1))!;
    return Color.lerp(_mid, _good, (v - 1).clamp(0, 1))!;
    // v in [0,2]
  }

  Color _uiFgFor(double v) =>
      _bgFor(v).computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

  @override
  Widget build(BuildContext context) {
    final uiFg = _uiFgFor(mood);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      color: _bgFor(mood),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: uiFg),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.info_outline_rounded, color: uiFg),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'Rate our services:-',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: uiFg,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 26),

              // Face (features have constant dark color)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: CustomPaint(
                      painter: _FacePainter(
                        mood: mood, // 0..2
                        featureColor: const Color(0xFF1B1B1B),
                        shadowColor: Colors.black.withOpacity(0.08),
                      ),
                    ),
                  ),
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                child: Text(
                  label,
                  key: ValueKey(label),
                  style: TextStyle(
                    color: uiFg.withOpacity(0.95),
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Smooth slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 14,
                    ),
                    activeTrackColor: uiFg.withOpacity(0.9),
                    inactiveTrackColor: uiFg.withOpacity(0.35),
                    thumbColor: uiFg,
                  ),
                  child: Slider(
                    min: 0,
                    max: 2,
                    value: mood,
                    onChanged: (v) => setState(() => mood = v),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: uiFg.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Bad'),
                      Text('Not bad'),
                      Text('Good'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SoftButton(
                        label: 'Add Note',
                        fg: uiFg,
                        bg: uiFg.withOpacity(0.1),
                        onTap: () => _showAddNoteDialog(),
                        trailing: const Icon(Icons.edit_note_rounded, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SoftButton(
                        label: 'Submit',
                        fg: _submitFgFor(mood),
                        bg: _submitBgFor(mood),
                        onTap: () => _submitRating(),
                        trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
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
  }

  Color _submitBgFor(double v) =>
      Color.alphaBlend(Colors.black12, _bgFor(v)).withOpacity(0.85);

  Color _submitFgFor(double v) =>
      _submitBgFor(v).computeLuminance() > 0.5 ? Colors.black : Colors.white;

  void _showAddNoteDialog() {
    final uiFg = _uiFgFor(mood);
    final bg = _bgFor(mood);
    final controller = TextEditingController(text: _note);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bg,
          title: Text(
            'Add a Note',
            style: TextStyle(color: uiFg),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: uiFg),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your comment here...',
              hintStyle: TextStyle(color: uiFg.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: uiFg.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: uiFg),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: uiFg.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _note = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(color: uiFg, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _submitRating() async {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thank you for your rating! ',
          style: TextStyle(color: _uiFgFor(mood)),
        ),
        backgroundColor: _bgFor(mood),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate back to previous screen
    Navigator.of(context).pop();
  }
}

/* =====================  FACE  ===================== */

class _FacePainter extends CustomPainter {
  final double mood; // 0..2 (bad..good)
  final Color featureColor; // constant dark features
  final Color shadowColor; // soft drop shadow

  _FacePainter({
    required this.mood,
    required this.featureColor,
    required this.shadowColor,
  });

  double _lerp(double a, double b, double t) => a + (b - a) * t;
  double _smooth(double t) =>
      t <= 0 ? 0 : (t >= 1 ? 1 : t * t * (3 - 2 * t)); // smoothstep

  @override
  void paint(Canvas canvas, Size size) {
    // s: 0 = BAD, 1 = GOOD
    final s = (mood / 2).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);

    // --------- EYES (closed at middle) ---------
    // Mid emphasis function: 0 at ends, 1 at middle
    final midPulse = 4 * s * (1 - s);

    // Height is smallest at the middle so eyes look "closed"
    final maxH = size.shortestSide * 0.14; // big circles at GOOD
    final minH = size.shortestSide * 0.025; // thin slit at NOT BAD
    final eyeH = _lerp(
      _lerp(size.shortestSide * 0.06, maxH, _smooth(s)), // edge height trend
      minH,
      midPulse, // pull to slit at middle
    );

    // Aspect: 1 at edges (circles), smaller at middle (slits)
    final aspect = _lerp(1.0, 0.22, midPulse); // 0.22 ~ closed pill
    final eyeW = eyeH / aspect;

    // Vertical drift: slightly lower when sad, higher when happy
    final eyeY = center.dy - size.height * 0.08 + _lerp(6.0, -6.0, _smooth(s));
    final eyeDx = size.width * 0.18;

    final eyePaint = Paint()..color = featureColor;
    final shadowPaint = Paint()..color = shadowColor;

    RRect eyeRect(Offset c) => RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: eyeW * 2, height: eyeH * 2),
          Radius.circular(eyeH),
        );

    // soft shadow behind eyes
    canvas.drawRRect(eyeRect(Offset(center.dx - eyeDx, eyeY + 2)), shadowPaint);
    canvas.drawRRect(eyeRect(Offset(center.dx + eyeDx, eyeY + 2)), shadowPaint);

    // Eyes (no eyebrows at all)
    canvas.drawRRect(eyeRect(Offset(center.dx - eyeDx, eyeY)), eyePaint);
    canvas.drawRRect(eyeRect(Offset(center.dx + eyeDx, eyeY)), eyePaint);

    // --------- MOUTH (FROWN at BAD -> SMILE at GOOD) ---------
    final baseY = center.dy + size.height * 0.20;
    final width = _lerp(size.width * 0.52, size.width * 0.68, _smooth(s));
    final left = Offset(center.dx - width / 2, baseY);
    final right = Offset(center.dx + width / 2, baseY);

    // curvature mapping:
    //  s=0  -> +0.75 (clear smile) - BAD should smile
    //  s=0.5-> ~0.00 (neutral-ish)
    //  s=1  -> -0.90 (strong frown) - GOOD should frown
    final curvature = _lerp(0.75, -0.90, _smooth(s));

    // y grows downward, so subtracting a positive curvature lifts the control point => smile.
    final ctrl = Offset(center.dx, baseY - curvature * size.height * 0.16);

    final mouth = Path()
      ..moveTo(left.dx, left.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, right.dx, right.dy)
      ..lineTo(right.dx, right.dy + 6)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy + 6, left.dx, left.dy + 6)
      ..close();

    // tiny shadow + fill
    final mouthShadow = mouth.shift(const Offset(0, 2));
    canvas.drawPath(mouthShadow, shadowPaint);
    canvas.drawPath(mouth, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _FacePainter old) =>
      old.mood != mood ||
      old.featureColor != featureColor ||
      old.shadowColor != shadowColor;
}

/* =============== UI bits =============== */

class _SoftButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SoftButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                IconTheme(
                  data: IconThemeData(color: fg),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
