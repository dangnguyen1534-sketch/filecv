
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _sending = false;

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _checkVerification() async {
    setState(() => _checking = true);

    try {
      final verified =
      await AuthService().reloadAndCheckVerification();

      if (!mounted) return;

      if (verified) {
        _message('Xác minh thành công! Đang mở hồ sơ...');
        // userChanges() trong AuthGate sẽ cập nhật giao diện.
      } else {
        _message(
          'Email chưa được xác minh. Hãy mở liên kết trong hộp thư.',
        );
      }
    } on FirebaseAuthException catch (e) {
      _message(e.message ?? 'Không thể kiểm tra email.');
    } catch (_) {
      _message('Có lỗi xảy ra. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _sending = true);

    try {
      await AuthService().resendVerificationEmail();
      _message('Đã gửi email xác minh. Hãy kiểm tra hộp thư.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        _message('Bạn đã gửi quá nhiều lần. Hãy thử lại sau.');
      } else {
        _message(e.message ?? 'Không thể gửi email xác minh.');
      }
    } catch (_) {
      _message('Không thể gửi email. Hãy kiểm tra kết nối mạng.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 90,
                    color: Color(0xFF6558F5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Xác minh email của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ConnectAI đã gửi liên kết xác minh đến:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6558F5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mở email, bấm liên kết xác minh, sau đó quay lại '
                        'ứng dụng và nhấn nút bên dưới.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed:
                      _checking ? null : _checkVerification,
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(
                        _checking
                            ? 'Đang kiểm tra...'
                            : 'Tôi đã xác minh email',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _sending ? null : _resendEmail,
                    icon: const Icon(Icons.mark_email_unread_outlined),
                    label: Text(
                      _sending ? 'Đang gửi...' : 'Gửi lại email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      await AuthService().logout();
                    },
                    child: const Text('Đăng xuất / Đổi tài khoản'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
