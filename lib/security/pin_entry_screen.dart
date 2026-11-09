import 'package:flutter/material.dart';

import '../../security/app_lock_controller.dart';

/// หน้าจอกรอกรหัส PIN 4–6 หลัก
class PinEntryScreen extends StatefulWidget {
  final AppLockController lockController;
  final String title;
  final String subtitle;
  final bool canCancel;
  final VoidCallback? onUnlocked;

  const PinEntryScreen({
    super.key,
    required this.lockController,
    this.title = 'กรอกรหัส PIN',
    this.subtitle = 'กรอก PIN 4–6 หลักเพื่อปลดล็อกแอป',
    this.canCancel = false,
    this.onUnlocked,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final List<String> _digits = [];
  String? _error;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inLockout = widget.lockController.isInLockout;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock_outline_rounded, size: 64, color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: index < _digits.length
                          ? Colors.amber
                          : (isDark ? const Color(0xFF1E293B) : Colors.grey[200]),
                      shape: BoxShape.circle,
                    ),
                    child: index < _digits.length
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 30),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (inLockout)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'กรอกผิดเกินกำหนด โปรดรอ ${widget.lockController.lockoutUntil?.difference(DateTime.now()).inSeconds ?? 0} วินาที',
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),

              // Numpad 3x4: 1-9, OK(check), 0, Backspace
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.25,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index < 9) {
                      final digit = (index + 1).toString();
                      return _buildKey(digit, onTap: () => _addDigit(digit));
                    }
                    if (index == 9) {
                      final canSubmit = _digits.length >= 4;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: canSubmit && !_processing && !inLockout ? _submit : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: canSubmit
                                  ? Colors.amber.withValues(alpha: 0.2)
                                  : (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 26,
                                color: canSubmit ? Colors.amber : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    if (index == 10) {
                      return _buildKey('0', onTap: () => _addDigit('0'));
                    }
                    // index == 11
                    return _buildKey('', icon: Icons.backspace_outlined, onTap: _delete);
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (widget.canCancel)
                TextButton(
                  onPressed: _processing ? null : () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('ยกเลิก'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String digit, {IconData? icon, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _processing || widget.lockController.isInLockout ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 26, color: Colors.grey[600])
                : Text(
                    digit,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  void _addDigit(String digit) {
    if (_processing) return;
    if (_digits.length >= 6) return;
    setState(() {
      _digits.add(digit);
      _error = null;
    });
    if (_digits.length == 6) _submit();
  }

  void _delete() {
    if (_processing) return;
    setState(() {
      if (_digits.isNotEmpty) _digits.removeLast();
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_digits.length < 4) {
      setState(() => _error = 'กรุณากรอกรหัส PIN อย่างน้อย 4 หลัก');
      return;
    }
    setState(() => _processing = true);
    final pin = _digits.join();
    final ok = await widget.lockController.verifyPin(pin);
    if (!mounted) return;
    setState(() => _processing = false);
    if (ok) {
      widget.onUnlocked?.call();
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _digits.clear();
        _error = 'รหัส PIN ไม่ถูกต้อง';
      });
    }
  }
}

/// Widget Wrapper ที่ล็อกแอปก่อนแสดงเนื้อหา
class AppLockWrapper extends StatefulWidget {
  final Widget child;
  final AppLockController lockController;

  const AppLockWrapper({
    super.key,
    required this.child,
    required this.lockController,
  });

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _initialized = false;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    widget.lockController.addListener(_onLockControllerChanged);
    _checkInitialLock();
  }

  @override
  void dispose() {
    widget.lockController.removeListener(_onLockControllerChanged);
    super.dispose();
  }

  void _onLockControllerChanged() {
    if (mounted) {
      setState(() {
        _isLocked = widget.lockController.isLocked;
      });
    }
  }

  Future<void> _checkInitialLock() async {
    final shouldLock = await widget.lockController.shouldLock();
    if (mounted) {
      setState(() {
        _isLocked = shouldLock;
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // หน้าจอโหลดชั่วครู่เพื่อไม่ให้กระพริบหน้า PIN ถ้าไม่มีการเปิดใช้งาน PIN
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const SizedBox.shrink(),
      );
    }

    if (_isLocked) {
      return PinEntryScreen(
        lockController: widget.lockController,
        onUnlocked: () {
          setState(() => _isLocked = false);
        },
      );
    }
    return widget.child;
  }
}
