import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar, Colors;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _profileImagePath;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _emailController.text = prefs.getString('userEmail') ?? '';
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);
    if (_profileImagePath != null) {
      await prefs.setString('profileImagePath', _profileImagePath!);
    }
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPin = prefs.getString('pin') ?? '1111';
    String newPin = '';
    String confirmPin = '';

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          children: [
            const Text('Enter current PIN:'),
            CupertinoTextField(
              placeholder: 'Current PIN',
              keyboardType: TextInputType.number,
              maxLength: 4,
              onChanged: (value) {
                if (value == currentPin) {
                  Navigator.pop(context);
                  _showNewPinDialog();
                }
              },
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNewPinDialog() async {
    String newPin = '';
    String confirmPin = '';

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Enter New PIN'),
        content: Column(
          children: [
            CupertinoTextField(
              placeholder: 'New PIN',
              keyboardType: TextInputType.number,
              maxLength: 4,
              onChanged: (value) {
                newPin = value;
              },
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              placeholder: 'Confirm New PIN',
              keyboardType: TextInputType.number,
              maxLength: 4,
              onChanged: (value) {
                confirmPin = value;
              },
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              if (newPin.length == 4 && newPin == confirmPin) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('pin', newPin);
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccess('PIN changed successfully');
                }
              } else {
                _showError('PINs do not match or are invalid');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Profile'),
        trailing: _isEditing
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Save'),
                onPressed: _saveUserData,
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Edit'),
                onPressed: () => setState(() => _isEditing = true),
              ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: CupertinoColors.systemGrey6,
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                      child: _profileImagePath == null
                          ? const Icon(
                              CupertinoIcons.person_fill,
                              size: 60,
                              color: CupertinoColors.systemGrey,
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: CupertinoColors.activeBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.camera_fill,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Name',
                enabled: _isEditing,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                enabled: _isEditing,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                onPressed: _changePassword,
                child: const Text('Change PIN' , style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold

                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 