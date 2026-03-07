import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';
import '../widgets/logo_widget.dart';
import '../theme.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _snack('Please fill all fields');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _snack('Passwords do not match');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.register(_userCtrl.text, _passCtrl.text);
      if (!mounted) return;
      if (res['responseCode'] == 0) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        _snack(res['responseDesc'] ?? 'Registration failed');
      }
    } catch (e) {
      _snack('Connection error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Interactive Background
          const Positioned.fill(child: MeshBackground()),

          // 2. Register Form
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios,
                                color: AppTheme.primaryDark.withValues(alpha: 0.6), size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Logo Image
                        const LogoWidget(logoWidth: 200),
                        const SizedBox(height: 32),

                        // Username
                        _buildField(
                          ctrl: _userCtrl,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildField(
                          ctrl: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        _buildField(
                          ctrl: _confirmCtrl,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscure: _obscure,
                        ),
                        const SizedBox(height: 32),

                        // Register Button (Matches "Select Concept" style)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: _loading ? null : _register,
                            child: GlassContainer(
                              height: 54,
                              borderRadius: 30,
                              color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                              borderColor: AppTheme.primaryOrange.withValues(alpha: 0.6),
                              child: Center(
                                child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: AppTheme.primaryDark))
                                  : Text('Create Account',
                                      style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          color: AppTheme.primaryDark,
                                          fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ',
                                style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text('Sign In',
                                  style: GoogleFonts.lexend(
                                    color: AppTheme.primaryOrange,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return GlassContainer(
      height: 56,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.4),
      borderColor: Colors.white.withValues(alpha: 0.6),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: GoogleFonts.lexend(color: AppTheme.primaryDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lexend(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: Colors.grey.shade700, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
