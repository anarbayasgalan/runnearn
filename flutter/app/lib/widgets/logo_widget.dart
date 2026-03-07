import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Reusable Run'n'Earn logo widget with image and tagline.
class LogoWidget extends StatelessWidget {
  final double logoWidth;

  const LogoWidget({super.key, this.logoWidth = 200});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/runnearn_logo.png',
          width: logoWidth, // Constrain width instead of height for wider logos
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const Icon(
            Icons.directions_run,
            size: 80,
            color: AppTheme.primaryOrange,
          ),
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
