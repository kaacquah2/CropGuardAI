import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../components/cropguard_text_field.dart';
import '../../components/primary_button.dart';
import 'register_provider.dart';

/// Equivalent of RegisterScreen.kt — name/email/password, strength bar, terms
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RegisterBody();
  }
}

class _RegisterBody extends StatelessWidget {
  const _RegisterBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    final colors = context.colors;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Text('Create Account',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Join CropGuard AI today',
                        style: TextStyle(color: colors.muted)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name
              CropGuardTextField(
                value: provider.name,
                onChanged: provider.setName,
                label: 'Full Name',
                placeholder: 'John Mensah',
              ),
              const SizedBox(height: 16),

              // Email
              CropGuardTextField(
                value: provider.email,
                onChanged: provider.setEmail,
                label: 'Email',
                placeholder: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password
              CropGuardTextField(
                value: provider.password,
                onChanged: provider.setPassword,
                label: 'Password',
                placeholder: '••••••••',
                obscureText: provider.obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(provider.obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: provider.togglePasswordVisibility,
                  color: colors.muted,
                ),
              ),
              const SizedBox(height: 16),
              CropGuardTextField(
                value: provider.confirmPassword,
                onChanged: provider.setConfirmPassword,
                label: 'Confirm Password',
                placeholder: '••••••••',
                obscureText: provider.obscurePassword,
              ),
              const SizedBox(height: 8),

              // Strength bar
              _PasswordStrengthBar(strength: provider.passwordStrength),
              const SizedBox(height: 16),

              // Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: provider.termsAccepted,
                    onChanged: (v) => provider.setTermsAccepted(v ?? false),
                    activeColor: colors.primaryLight,
                    side: BorderSide(color: colors.border),
                  ),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('I agree to the ',
                            style: TextStyle(
                                color: colors.muted, fontSize: 12)),
                        GestureDetector(
                          onTap: () => context.push('/terms_of_service'),
                          child: Text('Terms of Service',
                              style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        Text(' and ',
                            style: TextStyle(
                                color: colors.muted, fontSize: 12)),
                        GestureDetector(
                          onTap: () => context.push('/privacy_policy'),
                          child: Text('Privacy Policy',
                              style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Error
              if (provider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colors.diseaseBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(provider.errorMessage!,
                      style: TextStyle(color: colors.error, fontSize: 13)),
                ),

              // Register button
              PrimaryButton(
                text: 'Create Account',
                isLoading: provider.status == RegisterStatus.loading,
                onPressed: () =>
                    provider.register(() => context.go('/home')),
              ),
              const SizedBox(height: 24),

              // Sign in link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style:
                            TextStyle(color: colors.muted, fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Sign In',
                          style: TextStyle(
                              color: colors.greenXL,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

/// Password strength bar — matches PasswordStrengthBar composable in RegisterScreen.kt
class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0–4

  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labels = ['', 'Weak', 'Fair', 'Strong', 'Very Strong'];
    final segColors = [colors.error, colors.warning, colors.healthy, colors.primary];

    if (strength == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < strength;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 3,
                decoration: BoxDecoration(
                  color: filled
                      ? segColors[i < segColors.length ? i : segColors.length - 1]
                      : colors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          'Strength: ${labels[strength.clamp(0, labels.length - 1)]}',
          style: TextStyle(color: colors.muted, fontSize: 11),
        ),
      ],
    );
  }
}
