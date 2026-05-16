import 'package:flutter/material.dart';
import 'dart:ui' as ui; // Needed for the blur effects
import '../screens/event_list_screen.dart';
import '../screens/register_screen.dart';
import '../data/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Color brandOrange = Color(0xFFFF6B35);
  static const Color accentTeal = Color(0xFF4ACFAC);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit(bool isAdmin) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final success = await ApiService.login(
          _emailController.text.trim(),
          _passwordController.text,
          isAdmin,
        );
        
        if (success && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => EventListScreen(isAdmin: isAdmin),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please check your credentials.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Warm Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE8E0), Colors.white],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),
          
          // 2. Floating "Fun" Blobs with Blur
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: LoginScreen.brandOrange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          Positioned(
            bottom: 50,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: LoginScreen.accentTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Dynamic Typography Header ---
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [LoginScreen.brandOrange, Color(0xFFFF9C71)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'EventFlow',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, 
                          letterSpacing: -2.0,
                        ),
                      ),
                    ),
                    const Text(
                      'Ready for an event? Sign in.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // --- Soft Tactile Form Card ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'hello@eventflow.com',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.password_rounded,
                              obscureText: true,
                            ),
                            const SizedBox(height: 32),

                            // Primary Action
                            ElevatedButton(
                              onPressed: _isLoading ? null : () => _submit(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LoginScreen.brandOrange,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(64),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Let\'s Go as User',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Secondary Action
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : () => _submit(true),
                              icon: const Icon(Icons.admin_panel_settings_rounded, size: 20, color: Colors.black45),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(64),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                foregroundColor: Colors.black87,
                              ),
                              label: const Text(
                                'Administrator Login',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Footer Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("First time here?", style: TextStyle(color: Colors.black45)),
                                TextButton(
                                  onPressed: _isLoading 
                                    ? null 
                                    : () => Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const RegisterScreen())
                                      ),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: LoginScreen.brandOrange,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: !_isLoading,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: hint,
            prefixIcon: Icon(icon, color: LoginScreen.brandOrange.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: LoginScreen.brandOrange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }
}