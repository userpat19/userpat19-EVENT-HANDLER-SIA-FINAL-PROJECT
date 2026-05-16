import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../data/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const Color brandOrange = Color(0xFFFF6B35);
  static const Color accentTeal = Color(0xFF4ACFAC);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final success = await ApiService.register(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful. You can now log in.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration failed. Please try again.')),
            );
          }
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

          // 2. Decorative Blobs
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: RegisterScreen.brandOrange.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [RegisterScreen.brandOrange, Color(0xFFFF9C71)],
                      ).createShader(bounds),
                      child: const Text(
                        'Join Us',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -2.0,
                        ),
                      ),
                    ),
                    const Text(
                      'Create an account to start exploring.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Form Card ---
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
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _firstNameController,
                                    label: 'First Name',
                                    hint: 'Jane',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _lastNameController,
                                    label: 'Last Name',
                                    hint: 'Doe',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'jane@example.com',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Required';
                                if (!value.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Required';
                                if (value.length < 6) return 'Min 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RegisterScreen.brandOrange,
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
                                      'Create Account',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Back to Login
                            TextButton(
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              child: Text(
                                'Already have an account? Sign in',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: !_isLoading,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: RegisterScreen.brandOrange.withOpacity(0.5), size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
              borderSide: const BorderSide(color: RegisterScreen.brandOrange, width: 2),
            ),
            errorStyle: const TextStyle(height: 0.8),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
          validator: validator ?? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }
}