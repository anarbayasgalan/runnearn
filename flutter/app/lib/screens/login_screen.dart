import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mesh_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/logo_widget.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'create_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
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
    super.dispose();
  }

  Future<void> _login() async {
    if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _snack('Please fill all fields');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.login(_userCtrl.text, _passCtrl.text);
      if (!mounted) return;
      if (res['responseCode'] == 0) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        _snack(res['responseDesc'] ?? 'Login failed');
      }
    } catch (e) {
      _snack('Connection error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '620364552407-tvb4o5ecc14q5otrse5qneahbna0ntif.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        setState(() => _loading = true);
        
        final res = await ApiService.loginSocial(
          'GOOGLE', 
          googleAuth.idToken ?? '', // Android uses idToken, iOS might differ
          googleUser.email, 
          googleUser.displayName, 
          googleUser.photoUrl
        );

        if (!mounted) return;
        if (res['responseCode'] == 0) {
          if (res['missingPassword'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePasswordScreen(
                  companyName: googleUser.displayName ?? googleUser.email,
                  isNewUser: res['isNewUser'] == true || res['newUser'] == true,
                ),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          _snack(res['responseDesc'] ?? 'Login failed');
        }
      }
    } catch (e) {
      _snack('Google Sign In failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        
        // Get user data from Graph API if needed, or backend can fetch it
        final userData = await FacebookAuth.instance.getUserData();

        setState(() => _loading = true);
        
        final res = await ApiService.loginSocial(
          'FACEBOOK', 
          accessToken.token, 
          userData['email'], 
          userData['name'], 
          userData['picture']?['data']?['url']
        );

        if (!mounted) return;
        if (res['responseCode'] == 0) {
          if (res['missingPassword'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePasswordScreen(
                  companyName: userData['name'] ?? userData['email'] ?? 'User',
                  isNewUser: res['isNewUser'] == true || res['newUser'] == true,
                ),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          _snack(res['responseDesc'] ?? 'Login failed');
        }
      } else {
        _snack('Facebook Sign In failed: ${result.message}');
      }
    } catch (e) {
      _snack('Facebook error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _socialButton({
    required String icon,
    required IconData iconData, // Placeholder until assets are ready
    required Color color, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ],
        ),
        child: Center(
          child: Icon(iconData, color: color, size: 30),
          // child: Image.asset(icon, width: 24, height: 24), // Use this when assets exist
        ),
      ),
    );
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

          // 2. Login Form
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
                        const LogoWidget(logoWidth: 200),
                        const SizedBox(height: 48),

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
                        const SizedBox(height: 32),

                        // Login Button (Matches "Select Concept" style)
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
                            onTap: _loading ? null : _login,
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
                                  : Text('Sign In',
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
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text("OR", style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(
                              icon: 'assets/google.png',
                              iconData: Icons.g_mobiledata, // Placeholder
                              color: Colors.red,
                              onTap: _loginGoogle,
                            ),
                            const SizedBox(width: 24),
                            _socialButton(
                              icon: 'assets/facebook.png',
                              iconData: Icons.facebook,
                              color: Colors.blue,
                              onTap: _loginFacebook,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/register'),
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.lexend(
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
