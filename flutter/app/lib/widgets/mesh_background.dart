import 'package:flutter/material.dart';
import 'dart:math';

import '../theme.dart';

class MeshBackground extends StatefulWidget {
  const MeshBackground({super.key});

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBlob(Color color, double size, double topOffset, double leftOffset, Animation<double> anim) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        // Very slow drifting motion
        final dx = sin(anim.value * 2 * pi + leftOffset) * 20;
        final dy = cos(anim.value * 2 * pi + topOffset) * 20;
        
        return Positioned(
          top: topOffset + dy,
          left: leftOffset + dx,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color,
                  blurRadius: size * 0.8,
                  spreadRadius: size * 0.3,
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width,
      height: size.height,
      color: const Color(0xFFF7F7F9), // Very light warm ash
      child: Stack(
        children: [
          // Dark Blob Top Right
          _buildBlob(
            const Color(0xFF2A2B30).withValues(alpha: 0.4), 
            400, 
            -150, 
            size.width - 200, 
            _controller
          ),
          
          // Large Orange Blob Center Left
          _buildBlob(
            AppTheme.primaryOrange.withValues(alpha: 0.35), 
            450, 
            size.height * 0.3, 
            -200, 
            _controller
          ),
          
          // Orange Blob Bottom Right
          _buildBlob(
            AppTheme.primaryOrange.withValues(alpha: 0.4), 
            400, 
            size.height - 200, 
            size.width - 250, 
            _controller
          ),
        ],
      ),
    );
  }
}
