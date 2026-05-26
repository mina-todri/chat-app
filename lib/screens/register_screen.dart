import 'package:chat_app/auth_service.dart';
import 'package:chat_app/core/auth_errors.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/themes/AppColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Please fill all fields");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar("Passwords don't match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = getAuthErrorMessage(e);
      _showErrorSnackBar(message);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorOrDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _AnimatedField(
                    delay: 0.1,
                    controller: _animController,
                    child: _InputField(
                      title: "Full Name",
                      controller: _nameController,
                      icon: LucideIcons.user,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedField(
                    delay: 0.15,
                    controller: _animController,
                    child: _InputField(
                      title: "Email address",
                      controller: _emailController,
                      icon: LucideIcons.mail,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedField(
                    delay: 0.2,
                    controller: _animController,
                    child: _InputField(
                      title: "Password",
                      controller: _passwordController,
                      isPassword: true,
                      icon: LucideIcons.lock
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedField(
                    delay: 0.25,
                    controller: _animController,
                    child: _InputField(
                      title: "Confirm Password",
                      controller: _confirmPasswordController,
                      isPassword: true,
                        icon: LucideIcons.lock
                    ),
                  ),
                  const SizedBox(height: 32),
                  _AnimatedField(
                    delay: 0.3,
                    controller: _animController,
                    child: _PrimaryButton(
                      text: "Create Account",
                      onPressed: _isLoading ? null : _handleRegister,
                      isLoading: _isLoading,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _AnimatedField(
                    delay: 0.35,
                    controller: _animController,
                    child: _buildLoginRow(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                LucideIcons.userPlus,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Create account",
            style: GoogleFonts.inter(
              fontSize: 28,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Join the conversation today",
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            "Sign in",
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ---- Animated Field Wrapper ----

class _AnimatedField extends StatelessWidget {
  const _AnimatedField({
    required this.delay,
    required this.controller,
    required this.child,
  });
  final double delay;
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = delay;
    final end = delay + 0.15;
    final anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    final offsetAnim = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: offsetAnim,
        child: child,
      ),
    );
  }
}

// ---- Input Field ----

class _InputField extends StatefulWidget {
  const _InputField({
    required this.title,
    required this.controller,
    this.isPassword = false,
    this.icon,
  });
  final String title;
  final TextEditingController controller;
  final bool isPassword;
  final IconData? icon;

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _isObscured = true;
  bool _isFocused = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.borderOrDivider.withOpacity(0.5),
          width: 1.5,
        ),
        color: AppColors.surface.withOpacity(0.6),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword ? _isObscured : false,
        style: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.title,
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textMuted.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: widget.icon != null
              ? Icon(
            widget.icon,
            color: _isFocused
                ? AppColors.primary
                : AppColors.textMuted.withOpacity(0.6),
            size: 20,
          )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: widget.isPassword
              ? IconButton(
            onPressed: () => setState(() => _isObscured = !_isObscured),
            icon: Icon(
              _isObscured
                  ? LucideIcons.eyeOff
                  : LucideIcons.eye,
              color: AppColors.textMuted.withOpacity(0.6),
              size: 20,
            ),
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ---- Primary Button ----

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (_controller.value * 0.05),
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  widget.text,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}