import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar, Colors;
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomText extends Text {
  const CustomText(super.data, {super.key});

  @override 
  TextStyle? get style => GoogleFonts.tajawal();
}


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
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.changePin),
        content: Column(
          children: [
            Text(AppLocalizations.of(context)!.enterCurrentPin),
            CupertinoTextField(
              placeholder: AppLocalizations.of(context)!.newPin,
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
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
      context: context,
    );
  }

  Future<void> _showNewPinDialog() async {
    String newPin = '';
    String confirmPin = '';

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.changePin),
        content: Column(
          children: [
            CupertinoTextField(
              placeholder: AppLocalizations.of(context)!.newPin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              onChanged: (value) {
                newPin = value;
              },
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              placeholder: AppLocalizations.of(context)!.confirmNewPin,
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
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              if (newPin.length == 4 && newPin == confirmPin) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('pin', newPin);
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccess(AppLocalizations.of(context)!.pinChanged);
                }
              } else {
                _showError(AppLocalizations.of(context)!.pinsDoNotMatch);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.save),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.profile),
        trailing: _isEditing
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(l10n.save),
                onPressed: _saveUserData,
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(l10n.edit),
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
                placeholder: l10n.name,
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
                placeholder: l10n.email,
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
                child: Text(
                  l10n.changePin,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: languageProvider.isEnglish
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.systemGrey5,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.english,
                                style: TextStyle(
                                  color: languageProvider.isEnglish
                                      ? CupertinoColors.white
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                            onPressed: () {
                              languageProvider.setLanguage('en');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: !languageProvider.isEnglish
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.systemGrey5,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.arabic,
                                style: TextStyle(
                                  color: !languageProvider.isEnglish
                                      ? CupertinoColors.white
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                            onPressed: () {
                              languageProvider.setLanguage('ar');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 