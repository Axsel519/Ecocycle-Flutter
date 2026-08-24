import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/api_service.dart';
import '../widgets/custom_header.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onHeaderProfilePressed;
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    this.onHeaderProfilePressed,
    this.onNavigateToRegister,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  void _handleSubmit() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 720;
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Loginbg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            CustomHeader(
              showBackground: true,
              onProfilePressed: widget.onHeaderProfilePressed,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 14 : 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWideScreen ? 880 : 460),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: isWideScreen
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      color: const Color(0xFFF1F5F9),
                                      height: 520,
                                      child: Image.asset(
                                        'assets/images/per.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.image, size: 64, color: AppColors.textMuted),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(36),
                                      child: _buildLoginForm(),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 18 : 26,
                                  vertical: 28,
                                ),
                                child: _buildLoginForm(),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Please enter your details to sign in.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null && (_errorMessage?.trim().length ?? 0) > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage ?? '',
                style: const TextStyle(
                  color: Color(0xFFE11D48),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value ?? '';
              if (text.trim().isEmpty) return 'Please enter your email';
              if (!text.contains('@')) return 'Enter a valid email address';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF006847), width: 1.5)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Password',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            validator: (value) {
              final text = value ?? '';
              if (text.isEmpty) return 'Please enter your password';
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF006847),
                  size: 20,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF006847), width: 1.5)),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006847),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 1,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? ", style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              GestureDetector(
                onTap: widget.onNavigateToRegister,
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF006847)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('or continue with', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
              ),
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                iconWidget: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDB4437))),
                onTap: () {},
              ),
              const SizedBox(width: 14),
              _buildSocialButton(
                iconWidget: const Icon(Icons.window_sharp, size: 18, color: Color(0xFF00A4EF)),
                onTap: () {},
              ),
              const SizedBox(width: 14),
              _buildSocialButton(
                iconWidget: const Icon(Icons.apple, size: 22, color: Colors.black),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required Widget iconWidget, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: iconWidget),
      ),
    );
  }
}