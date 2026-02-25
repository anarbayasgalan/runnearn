import 'dart:io';

void main() {
  final file = File('/Users/tsolmonmyagmarjav/Desktop/run/flutter/app/lib/screens/login_screen.dart');
  String content = file.readAsStringSync();
  
  String correctBuildMethod = '''
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
                        // Logo Text (Run'N Earn style)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Run', style: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
                            const Text('\\'', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text('N', style: GoogleFonts.lexend(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primaryOrange)),
                                Text('N', style: GoogleFonts.lexend(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primaryDark.withValues(alpha: 0.5))),
                              ],
                            ),
                            Text('Earn', style: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('TRACK • CHALLENGE • EARN',
                            style: GoogleFonts.lexend(
                                fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600, letterSpacing: 1.5)),
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
''';

  final buildMethodRegex = RegExp(r'@override\s+Widget build\(BuildContext context\) \{[\s\S]*?Widget _buildField', multiLine: true);
  if (buildMethodRegex.hasMatch(content)) {
    String newContent = content.replaceFirst(buildMethodRegex, correctBuildMethod + '\n\n  Widget _buildField');
    file.writeAsStringSync(newContent);
    print('Fixed gracefully');
  } else {
    print('Failed to find build method');
  }
}
