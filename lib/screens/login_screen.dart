import 'package:chat_app/auth_service.dart';
import 'package:chat_app/core/auth_errors.dart';
import 'package:chat_app/screens/register_screen.dart';
import 'package:chat_app/themes/AppColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleAuthError(FirebaseAuthException e) {
    setState(() {
      _emailError = null;
      _passwordError = null;
      String message = getAuthErrorMessage(e);
      if (e.code == "user-not-found" || e.code == "invalid-email") {
        _emailError = message;
      } else if (e.code == "wrong-password") {
        _passwordError = message;
      } else {
        _emailError = message;
      }
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      await AuthService().signin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _handleAuthError(e);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      await AuthService().signinWithGoogle();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: AppColors.errorOrDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

                  const SizedBox(height: 48),
                  _AnimatedField(
                    delay: 0.1,
                    controller: _animController,
                    child: _InputField(
                      title: "Email address",
                      controller: _emailController,
                      errorText: _emailError,
                      icon: LucideIcons.mail,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _AnimatedField(
                    delay: 0.2,
                    controller: _animController,
                    child: _InputField(
                      title: "Password",
                      controller: _passwordController,
                      errorText: _passwordError,
                      isPassword: true,
                      icon: LucideIcons.lock,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _AnimatedField(
                    delay: 0.3,
                    controller: _animController,
                    child: _PrimaryButton(
                      text: "Sign In",
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _AnimatedField(
                    delay: 0.35,
                    controller: _animController,
                    child: _DividerWithText(text: "or continue with"),
                  ),
                  const SizedBox(height: 28),
                  _AnimatedField(
                    delay: 0.4,
                    controller: _animController,
                    child: _GoogleButton(
                      onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                      isLoading: _isGoogleLoading,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _AnimatedField(
                    delay: 0.45,
                    controller: _animController,
                    child: _buildRegisterRow(),
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
          const _Logo(),
          const SizedBox(height: 24),
          Text(
            "Welcome back",
            style: GoogleFonts.inter(
              fontSize: 28,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sign in to continue chatting",
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

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            "Register",
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
    final end = delay + 0.2;
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

// ---- Logo ----

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          LucideIcons.messageCircle,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---- Input Field ----

class _InputField extends StatefulWidget {
  const _InputField({
    required this.title,
    required this.controller,
    this.errorText,
    this.isPassword = false,
    this.icon,
  });
  final String title;
  final TextEditingController controller;
  final String? errorText;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.5)
                  : widget.errorText != null
                  ? AppColors.errorOrDanger.withOpacity(0.5)
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
                onPressed: () =>
                    setState(() => _isObscured = !_isObscured),
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
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.errorOrDanger,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.errorText!,
                  style: GoogleFonts.inter(
                    color: AppColors.errorOrDanger,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
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

// ---- Google Button ----

class _GoogleButton extends StatefulWidget {
  const _GoogleButton({
    required this.onPressed,
    this.isLoading = false,
  });
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton>
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
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.borderOrDivider.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary,
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Sign in with Google",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---- Divider ----

class _DividerWithText extends StatelessWidget {
  const _DividerWithText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.borderOrDivider.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: AppColors.textMuted.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.borderOrDivider.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}