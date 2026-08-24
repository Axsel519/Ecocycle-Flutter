import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../core/app_colors.dart';
import '../core/api_service.dart';

class CustomHeader extends StatefulWidget {
  final bool showBackground;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUserDataChanged;

  const CustomHeader({
    super.key,
    this.showBackground = true,
    this.onProfilePressed,
    this.onUserDataChanged,
  });

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      setState(() {
        _user = jsonDecode(userStr);
      });
    } else {
      setState(() {
        _user = null;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    setState(() => _user = null);
    if (widget.onUserDataChanged != null) {
      widget.onUserDataChanged!();
    }
    if (widget.onProfilePressed != null) {
      widget.onProfilePressed!();
    }
  }

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || _user == null) return;

    final bytes = await picked.readAsBytes();
    final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';

    try {
      final url = Uri.parse('${ApiService.baseUrl}/auth/update-avatar');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _user!['id'] ?? _user!['_id'],
          'avatarUrl': base64Image,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        _user!['avatarUrl'] = base64Image;
        await prefs.setString('user', jsonEncode(_user));
        setState(() {});
        if (widget.onUserDataChanged != null) {
          widget.onUserDataChanged!();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating photo: $e')),
        );
      }
    }
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        final String fullName = _user!['firstName'] != null && _user!['lastName'] != null
            ? '${_user!['firstName'].toString().trim()} ${_user!['lastName'].toString().trim()}'
            : _user!['name'] ?? 'User';
        final String email = _user!['email'] ?? '';
        final String role = _user!['role'] ?? 'user';
        final String avatarUrl = _user!['avatarUrl'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? (avatarUrl.startsWith('data:')
                            ? MemoryImage(base64Decode(avatarUrl.split(',').last)) as ImageProvider
                            : NetworkImage(avatarUrl))
                        : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          email,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        if (role == 'admin')
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.badgeGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Change Profile Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _changePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = _user != null
        ? (_user!['firstName'] != null && _user!['lastName'] != null
            ? '${_user!['firstName'].toString().trim()} ${_user!['lastName'].toString().trim()}'
            : _user!['name'] ?? 'User')
        : '';
    final String avatarUrl = _user != null ? (_user!['avatarUrl'] ?? '') : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: widget.showBackground ? Colors.white.withOpacity(0.95) : Colors.transparent,
        boxShadow: widget.showBackground
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/Ecocycle.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.recycling, color: AppColors.primary, size: 30),
                  ),
                ),
                const SizedBox(width: 10),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 22, color: AppColors.textDark, letterSpacing: -0.5),
                    children: [
                      TextSpan(text: 'Eco', style: TextStyle(fontWeight: FontWeight.w500)),
                      TextSpan(text: 'Cycle', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            if (_user != null)
              InkWell(
                onTap: _showProfileModal,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        backgroundImage: avatarUrl.isNotEmpty
                            ? (avatarUrl.startsWith('data:')
                                ? MemoryImage(base64Decode(avatarUrl.split(',').last)) as ImageProvider
                                : NetworkImage(avatarUrl))
                            : null,
                        child: avatarUrl.isEmpty
                            ? Text(
                                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fullName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
              )
            else
              InkWell(
                onTap: widget.onProfilePressed,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.person_outline_rounded, size: 22, color: AppColors.textDark),
                ),
              ),
          ],
        ),
      ),
    );
  }
}