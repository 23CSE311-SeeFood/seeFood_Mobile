import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/store/auth/auth_api.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/store/cart/cart_controller.dart';
import 'package:seefood/themes/app_colors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _branchController = TextEditingController();
  final _rollController = TextEditingController();

  final _authApi = AuthApi();

  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _branchController.dispose();
    _rollController.dispose();
    _authApi.close();
    super.dispose();
  }

  String? _validateInputs() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final number = _numberController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    final nameOk = RegExp(r"^[a-zA-Z][a-zA-Z\s'.-]{1,}$").hasMatch(name);
    final emailOk =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!nameOk) {
      return 'Please enter a valid name';
    }
    if (!emailOk) {
      return 'Please enter a valid email';
    }
    if (number.length < 8) {
      return 'Please enter a valid phone number';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password != confirm) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    final validationError = _validateInputs();
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
      final result = await _authApi.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        number: _numberController.text.trim(),
        password: _passwordController.text,
        branch: _branchController.text.trim().isEmpty
            ? null
            : _branchController.text.trim(),
        rollNumber: _rollController.text.trim().isEmpty
            ? null
            : _rollController.text.trim(),
      );
      if (!mounted) return;
      final authRepository = context.read<AuthRepository>();
      await authRepository.saveToken(result.token);
      await authRepository.saveProfile(result.profile);

      final cart = context.read<CartController>();
      await cart.syncLocalToServerIfNeeded();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Create account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _InputLabel(label: 'Full Name'),
            _InputField(
              controller: _nameController,
              hintText: 'Enter your name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            const _InputLabel(label: 'Email'),
            _InputField(
              controller: _emailController,
              hintText: 'Enter your email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 14),
            const _InputLabel(label: 'Phone Number'),
            _InputField(
              controller: _numberController,
              hintText: 'Enter your number',
              icon: Icons.phone_outlined,
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
            const SizedBox(height: 14),
            const _InputLabel(label: 'Confirm Password'),
            _InputField(
              controller: _confirmController,
              hintText: 'Re-enter password',
              icon: Icons.lock_outline,
              suffixIcon: Icons.visibility_off_outlined,
              obscureText: true,
            ),
            const SizedBox(height: 14),
            const _InputLabel(label: 'Branch (optional)'),
            _InputField(
              controller: _branchController,
              hintText: 'Enter your branch',
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 14),
            const _InputLabel(label: 'Roll Number (optional)'),
            _InputField(
              controller: _rollController,
              hintText: 'Enter your roll number',
              icon: Icons.confirmation_number_outlined,
            ),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 6),
            _SignupButton(
              isLoading: _isSubmitting,
              onPressed: _register,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupButton extends StatelessWidget {
  const _SignupButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 16,
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
        fillColor: AppColors.foreground,
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
