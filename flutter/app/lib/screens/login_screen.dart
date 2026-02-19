import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/interactive_background.dart';
import '../services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


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
  }

  Future<void> _loginGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // clientId: 'YOUR_IOS_CLIENT_ID', // Only needed for iOS
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
          Navigator.pushReplacementNamed(context, '/dashboard');
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
          accessToken.tokenString, 
          userData['email'], 
          userData['name'], 
          userData['picture']?['data']?['url']
        );

        if (!mounted) return;
        if (res['responseCode'] == 0) {
          Navigator.pushReplacementNamed(context, '/dashboard');
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
          const Positioned.fill(child: InteractiveBackground()),

          // 2. Gradient Overlay (to make text readable)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          // 3. Login Form
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  // Logo
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.directions_run,
                        size: 44, color: Color(0xFFFF6B00)),
                  ),
                  const SizedBox(height: 24),
                  Text('RunEarn',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      )),
                  const SizedBox(height: 8),
                  Text('Track. Challenge. Earn.',
                      style: GoogleFonts.outfit(
                          fontSize: 15, color: const Color(0xFF6B7280))),
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

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4, // Subtle shadow for depth
                        shadowColor: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text('Sign In',
                              style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                       const Expanded(child: Divider()),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 16),
                         child: Text("OR", style: GoogleFonts.outfit(color: Colors.grey)),
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
                        icon: 'assets/google.png', // Fallback to Icon if image missing? passing icon data for now
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
                          style: GoogleFonts.outfit(color: const Color(0xFF6B7280))),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: Text('Sign Up',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF2E86DE),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: GoogleFonts.outfit(color: const Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: const Color(0xFF9CA3AF)),
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}
