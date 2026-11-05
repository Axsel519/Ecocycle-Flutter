import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/api_service.dart';
import '../widgets/custom_header.dart';

enum UserRole { user, driver, admin }

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onHeaderProfilePressed;
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onRegisterSuccess;

  const RegisterScreen({
    super.key,
    this.onHeaderProfilePressed,
    this.onNavigateToLogin,
    this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _base64Image;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Role selection
  UserRole _selectedRole = UserRole.user; // default = User

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    }
  }

  void _handleSubmit() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords do not match!");
      return;
    }

    if (_nationalIdController.text.trim().length != 14) {
      setState(() => _errorMessage = "National ID number must be exactly 14 digits.");
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.register(
      String: _selectedRole.name,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      avatarUrl: _base64Image,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (widget.onRegisterSuccess != null) {
        widget.onRegisterSuccess!();
      }
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 18 : 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'CREATE YOUR ACCOUNT',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0D5C46),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          if (_errorMessage != null && (_errorMessage?.trim().length ?? 0) > 0)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
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
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFE6F4EA),
                                          border: Border.all(color: const Color(0xFF0D5C46), width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.06),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _base64Image != null
                                              ? Image.memory(
                                                  base64Decode(_base64Image!.split(',').last),
                                                  fit: BoxFit.cover,
                                                )
                                              : const Icon(
                                                  Icons.person_rounded,
                                                  size: 52,
                                                  color: Color(0xFF0D5C46),
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D5C46),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Upload Photo',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0D5C46)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 380) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        label: 'FIRST NAME',
                                        controller: _firstNameController,
                                        hintText: 'First Name',
                                        prefixIcon: Icons.person_outline,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildInputField(
                                        label: 'LAST NAME',
                                        controller: _lastNameController,
                                        hintText: 'Last Name',
                                        prefixIcon: Icons.person_outline,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  _buildInputField(
                                    label: 'FIRST NAME',
                                    controller: _firstNameController,
                                    hintText: 'First Name',
                                    prefixIcon: Icons.person_outline,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInputField(
                                    label: 'LAST NAME',
                                    controller: _lastNameController,
                                    hintText: 'Last Name',
                                    prefixIcon: Icons.person_outline,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            label: 'NATIONAL ID NUMBER',
                            controller: _nationalIdController,
                            hintText: 'Your 14-digit ID Number',
                            prefixIcon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 14,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            label: 'ADDRESS',
                            controller: _addressController,
                            hintText: 'Street Address, City, State',
                            prefixIcon: Icons.home_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            label: 'PHONE NUMBER',
                            controller: _phoneController,
                            hintText: '+20 100 000 0000',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            label: 'EMAIL ADDRESS',
                            controller: _emailController,
                            hintText: 'example@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              final text = val ?? '';
                              if (text.isEmpty) return 'Email is required';
                              if (!text.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            label: 'PASSWORD',
                            controller: _passwordController,
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            showPassword: _showPassword,
                            onTogglePassword: () => setState(() => _showPassword = !_showPassword),
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            label: 'CONFIRM PASSWORD',
                            controller: _confirmPasswordController,
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            showPassword: _showConfirmPassword,
                            onTogglePassword: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                          ),

                          // Role selection
                          const SizedBox(height: 24),
                          const Text(
                            'ACCOUNT TYPE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _buildRoleOption(UserRole.user, 'User')),
                                Expanded(child: _buildRoleOption(UserRole.driver, 'Driver')),
                                Expanded(child: _buildRoleOption(UserRole.admin, 'Admin')),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D5C46),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Create Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? ", style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                              GestureDetector(
                                onTap: widget.onNavigateToLogin,
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0D5C46)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(UserRole role, String label) {
    final bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D5C46) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !showPassword,
          maxLength: maxLength,
          validator: validator ??
              (value) {
                if (value == null || value.trim().isEmpty) return 'This field is required';
                return null;
              },
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF0D5C46), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF0D5C46),
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}