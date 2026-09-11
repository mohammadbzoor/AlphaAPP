import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alpha_app/core/utils/app_colors.dart';

class BirthdayDialog extends StatelessWidget {
  final String name;
  final bool isDark;

  const BirthdayDialog({
    Key? key,
    required this.name,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFBFEE6), // very light yellow-green
              Color(0xFFD4EAB9), // light green
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative elements simulating confetti
            const Positioned(
                top: 40,
                left: 40,
                child: Text('🎊', style: TextStyle(fontSize: 12))),
            const Positioned(
                top: 80,
                right: 60,
                child: Text('🎈', style: TextStyle(fontSize: 10))),
            const Positioned(
                bottom: 150,
                left: 20,
                child: Text('✨', style: TextStyle(fontSize: 16))),
            const Positioned(
                bottom: 80,
                right: 30,
                child: Text('🎉', style: TextStyle(fontSize: 14))),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Top party popper icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text('🎉', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(height: 16),

                  // Happy Birthday text
                  Text(
                    'Happy\nBirthday!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name Pill Box
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('✨',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF4CAF50))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F1D3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$name!',
                          style: GoogleFonts.caveat(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('✨',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF4CAF50))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Main Content: Mascot and Info Card
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Mascot Image with radial glow
                      Expanded(
                        flex: 4,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.8),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/happy.png',
                              fit: BoxFit.contain,
                              height:
                                  140, // Increased height to match design proportions
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info Card
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('💚',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Everyone at Alpha wishes you a fantastic birthday and a year filled with success, joy, and new opportunities.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF4A554D),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('⭐',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Thank you for being part of our community!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF4A554D),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Thank You Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF0D4A22), // Very dark green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 18)),
                          Text(
                            'Thank you',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Close Button
            Positioned(
              top: 16,
              right: 16,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F3DB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Color(0xFF1B5E20), size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
