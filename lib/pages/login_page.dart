import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/pages/main_page.dart';
import 'package:seefood/store/auth/auth_api.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/store/cart/cart_controller.dart';
import 'package:seefood/themes/app_colors.dart';
import 'package:seefood/pages/signup_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authApi = AuthApi();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (err) {
        debugPrint('SSO link error: $err');
      },
    );
    _loadInitialLink();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authApi.close();
    _linkSub?.cancel();
    super.dispose();
  }

  String? _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailOk =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!emailOk) {
      return 'Please enter a valid email';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final result = await _authApi.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      final authRepository = context.read<AuthRepository>();
      await authRepository.saveToken(result.token);
      await authRepository.saveProfile(result.profile);

      await authRepository.saveProfile(result.profile);
      if (!mounted) return;

      final cart = context.read<CartController>();
      await cart.syncLocalToServerIfNeeded();

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _loadInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleIncomingLink(uri);
      }
    } catch (e) {
      debugPrint('SSO initial link error: $e');
    }
  }

  void _handleIncomingLink(Uri uri) {
    debugPrint('SSO redirect: $uri');

    String? token = uri.queryParameters['token'] ??
        uri.queryParameters['jwt'] ??
        uri.queryParameters['accessToken'] ??
        uri.queryParameters['access_token'];

    if ((token == null || token.isEmpty) && uri.fragment.isNotEmpty) {
      final fragParams = Uri.splitQueryString(uri.fragment);
      token = fragParams['token'] ??
          fragParams['jwt'] ??
          fragParams['accessToken'] ??
          fragParams['access_token'];
    }

    if (token != null && token.isNotEmpty) {
      debugPrint('SSO token: $token');
      _handleSsoToken(token);
    }
  }

  void _handleSsoToken(String token) {
    () async {
      final authRepository = context.read<AuthRepository>();
      await authRepository.saveTokenAndProfileFromJwt(token);
      final profile = authRepository.getProfileOrFromToken();
      debugPrint('SSO decoded profile: ${profile?.toJson()}');

      final cart = context.read<CartController>();
      await cart.syncLocalToServerIfNeeded();

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    }();
  }

  Future<void> _launchCollegeSso() async {
    final uri = Uri.parse('https://e3c8-103-5-112-80.ngrok-free.app/auth/microsoft/login?redirect=seefood://auth');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open College ID login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.grayground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              Container(
                height: size.height * 0.26,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.foreground.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.foreground.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Text(
                                'D',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'namelogo',
                            style: TextStyle(
                              color: AppColors.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                decoration: BoxDecoration(
                  color: AppColors.foreground,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign in to your account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    _AuthButton(
                      icon: Icons.school_outlined,
                      label: 'Sign in with College ID',
                      onPressed: _launchCollegeSso,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey.shade300),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _InputLabel(label: 'Email'),
                    _InputField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 14),
                    const _InputLabel(label: 'Password'),
                    _InputField(
                      controller: _passwordController,
                      hintText: 'Enter password',
                      icon: Icons.lock_outline,
                      suffixIcon: Icons.visibility_off_outlined,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const Text(
                      'By signing in you agree to our Terms of Service and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 12),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.grayground,
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.suffixIcon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final IconData? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        hintText: hintText,
        filled: true,
        fillColor: AppColors.grayground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
