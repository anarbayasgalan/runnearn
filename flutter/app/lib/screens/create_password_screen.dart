import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/mesh_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/logo_widget.dart';
import '../theme.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String companyName;
  final bool isNewUser;
  const CreatePasswordScreen({super.key, required this.companyName, this.isNewUser = false});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

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
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_passCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
      _snack('Please fill all fields');
      return;
    }

    if (_passCtrl.text != _confirmPassCtrl.text) {
      _snack('Passwords do not match');
      return;
    }
    
    if (_passCtrl.text.length < 6) {
      _snack('Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await apiService.post('/updateUserCred', {
        'userName': widget.companyName, 
        'userPass': _passCtrl.text,
      });

      if (response['responseCode'] == 0 || response['responseDesc'] != null) {
        if (mounted) {
           if (widget.isNewUser) {
             Navigator.pushReplacementNamed(context, '/setup');
           } else {
             Navigator.pushReplacementNamed(context, '/dashboard');
           }
        }
      } else {
         _snack(response['responseDesc'] ?? 'Failed to update credentials');
      }
    } catch (e) {
      _snack('Network error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

          // 2. Form Content
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
                        // Logo Image
                        const LogoWidget(logoHeight: 60),
                        const SizedBox(height: 32),
                        
                        Text(
                          'Secure Your Account',
                          style: GoogleFonts.lexend(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set a password so you can log in with your email next time.',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Password Field
                        _buildField(
                          ctrl: _passCtrl,
                          hint: 'New Password',
                          icon: Icons.lock_outline,
                          obscure: _obscurePass,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePass ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        _buildField(
                          ctrl: _confirmPassCtrl,
                          hint: 'Confirm Password',
                          icon: Icons.lock_clock_outlined,
                          obscure: _obscureConfirm,
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
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
                            onTap: _isLoading ? null : _submit,
                            child: GlassContainer(
                              height: 54,
                              borderRadius: 30,
                              color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                              borderColor: AppTheme.primaryOrange.withValues(alpha: 0.6),
                              child: Center(
                                child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: AppTheme.primaryDark))
                                  : Text('Save Password',
                                      style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          color: AppTheme.primaryDark,
                                          fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
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
