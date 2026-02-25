import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Reusable Run'n'Earn logo widget with image and tagline.
class LogoWidget extends StatelessWidget {
  final double logoHeight;

  const LogoWidget({super.key, this.logoHeight = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: logoHeight,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          'MOVE  •  CONNECT  •  GAIN',
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
