import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lost_item_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_list_screen.dart';
import '../utils/storage_service.dart';

class LoginScreen extends StatefulWidget {
  final StorageService storageService;

  const LoginScreen({super.key, required this.storageService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> _pin = [];
  bool _isFirstTime = true;
  String _confirmPin = '';

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = !prefs.containsKey('pin');
    });
  }

  void _onPinEntered(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(digit);
      });

      if (_pin.length == 4) {
        if (_isFirstTime) {
          if (_confirmPin.isEmpty) {
            setState(() {
              _confirmPin = _pin.join();
              _pin.clear();
            });
          } else {
            if (_confirmPin == _pin.join()) {
              _savePin();
            } else {
              _showError(context.t.pinsDoNotMatch);
              setState(() {
                _confirmPin = '';
                _pin.clear();
              });
            }
          }
        } else {
          _verifyPin();
        }
      }
    }
  }

  void _onPinDeleted() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }

  Future<void> _savePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin', _pin.join());
    _navigateToHome();
  }

  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('pin') ?? '1111';

    if (savedPin == _pin.join()) {
      _navigateToHome();
    } else {
      _showError(context.t.incorrectPin);
      setState(() {
        _pin.clear();
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) => ItemListScreen(
          storageService: widget.storageService,
        ),
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Error"),
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
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.lock_shield,
                size: 64,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(height: 24),
              Text(
                _isFirstTime ? context.t.createPin : context.t.enterPin,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isFirstTime && _confirmPin.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  context.t.confirmPin,
                  style: const TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pin.length
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey5,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              Column(
                children: [
                  // First row (1-3)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () => _onPinEntered('${index + 1}'),
                        ),
                      );
                    }),
                  ),
                  // Second row (4-6)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 4}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () => _onPinEntered('${index + 4}'),
                        ),
                      );
                    }),
                  ),
                  // Third row (7-9)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 7}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () => _onPinEntered('${index + 7}'),
                        ),
                      );
                    }),
                  ),
                  // Bottom row (0 and delete)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Center(
                              child: Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () => _onPinEntered('0'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _onPinDeleted,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.delete,
                                size: 32,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
