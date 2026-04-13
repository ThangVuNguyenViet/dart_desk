import 'dart:developer' as developer;

import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A widget that provides authentication guard functionality using Serverpod's
/// IDP authentication system with Google Sign-In and email/password support.
///
/// The sign-in screen shows both Google Sign-In and email/password options.
///
/// Example usage:
/// ```dart
/// DartDeskAuth(
///   serverUrl: 'http://localhost:8080/',
///   builder: (context, client, signOut) => MyAuthenticatedApp(
///     client: client,
///     onSignOut: signOut,
///   ),
/// )
/// ```
class DartDeskAuth extends StatefulWidget {
  final String serverUrl;
  final Widget Function(
    BuildContext context,
    Client client,
    VoidCallback signOut,
  )
  builder;
  final String apiKey;
  final String title;
  final String? subtitle;
  final Widget? logo;
  final ShadThemeData? theme;

  const DartDeskAuth({
    super.key,
    required this.serverUrl,
    required this.builder,
    required this.apiKey,
    this.title = 'Welcome to Dart Desk',
    this.subtitle,
    this.logo,
    this.theme,
  });

  @override
  State<DartDeskAuth> createState() => _DartDeskAuthState();
}

class _DartDeskAuthState extends State<DartDeskAuth> {
  late final Client _client;
  late final FlutterAuthSessionManager _sessionManager;
  bool _isLoading = true;
  bool _isEnsuringUser = false;
  bool _isEmailSigningIn = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Forgot password state
  bool _showForgotPassword = false;
  int _forgotStep = 0; // 0=email, 1=code, 2=new password
  bool _isForgotLoading = false;
  String? _forgotError;
  UuidValue? _resetRequestId;
  String? _finishResetToken;
  final _forgotEmailController = TextEditingController();
  final _forgotCodeController = TextEditingController();
  final _forgotPasswordController = TextEditingController();
  final _forgotConfirmPasswordController = TextEditingController();
  bool _obscureForgotPassword = true;
  bool _obscureForgotConfirmPassword = true;

  FlutterAuthSessionManager get _auth => _sessionManager;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _sessionManager = FlutterAuthSessionManager();

      _client =
          Client(
              widget.serverUrl,
              onFailedCall: (context, error, stackTrace) {
                developer.log(
                  'API call failed: ${context.endpointName}.${context.methodName}',
                  name: 'ServerpodClient',
                  error: error,
                  stackTrace: stackTrace,
                );
              },
              onSucceededCall: (context) {
                developer.log(
                  'API call succeeded: ${context.endpointName}.${context.methodName}',
                  name: 'ServerpodClient',
                );
              },
            )
            ..connectivityMonitor = FlutterConnectivityMonitor()
            ..authSessionManager = _sessionManager
            ..authKeyProvider = DartDeskAuthKeyProvider(
              apiKey: widget.apiKey,
              inner: _sessionManager,
            );

      await _sessionManager.initialize();
      await _sessionManager.initializeGoogleSignIn();

      _auth.authInfoListenable.addListener(_onAuthChanged);

      // If already authenticated, ensure user exists
      if (_auth.isAuthenticated) {
        await _ensureUser();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onAuthChanged() {
    if (mounted) {
      if (_auth.isAuthenticated && !_isEnsuringUser) {
        _ensureUser();
      }
      setState(() {});
    }
  }

  Future<void> _ensureUser() async {
    _isEnsuringUser = true;
    try {
      await _client.user.getCurrentUser();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize user: ${e.toString()}';
        });
      }
    } finally {
      _isEnsuringUser = false;
    }
  }

  Future<void> _signInWithEmail(String email, String password) async {
    setState(() {
      _isEmailSigningIn = true;
      _errorMessage = null;
    });

    try {
      final authSuccess = await _client.emailIdp.login(
        email: email,
        password: password,
      );
      await _auth.updateSignedInUser(authSuccess);
      // _onAuthChanged will handle ensureUser
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Email sign-in failed. Error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEmailSigningIn = false;
        });
      }
    }
  }

  Future<void> _handleEmailSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }
    await _signInWithEmail(email, password);
  }

  Future<void> _handleSignOut() async {
    try {
      await _auth.signOutDevice();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to sign out: ${e.toString()}';
        });
      }
    }
  }

  void _showForgotPasswordFlow() {
    setState(() {
      _showForgotPassword = true;
      _forgotStep = 0;
      _forgotError = null;
      _forgotEmailController.clear();
      _forgotCodeController.clear();
      _forgotPasswordController.clear();
      _forgotConfirmPasswordController.clear();
    });
  }

  void _hideForgotPasswordFlow() {
    setState(() {
      _showForgotPassword = false;
      _forgotStep = 0;
      _forgotError = null;
    });
  }

  Future<void> _handleStartReset() async {
    final email = _forgotEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _forgotError = 'Please enter a valid email address.');
      return;
    }
    setState(() {
      _isForgotLoading = true;
      _forgotError = null;
    });
    try {
      _resetRequestId =
          await _client.emailIdp.startPasswordReset(email: email);
      if (mounted) setState(() => _forgotStep = 1);
    } catch (e) {
      if (mounted) {
        setState(
            () => _forgotError = 'Failed to send reset code. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isForgotLoading = false);
    }
  }

  Future<void> _handleVerifyResetCode() async {
    final code = _forgotCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _forgotError = 'Please enter the verification code.');
      return;
    }
    setState(() {
      _isForgotLoading = true;
      _forgotError = null;
    });
    try {
      _finishResetToken = await _client.emailIdp.verifyPasswordResetCode(
        passwordResetRequestId: _resetRequestId!,
        verificationCode: code,
      );
      if (mounted) setState(() => _forgotStep = 2);
    } catch (e) {
      if (mounted) {
        setState(() => _forgotError =
            'Invalid or expired verification code. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isForgotLoading = false);
    }
  }

  Future<void> _handleFinishReset() async {
    final password = _forgotPasswordController.text;
    final confirm = _forgotConfirmPasswordController.text;
    if (password.length < 8) {
      setState(() => _forgotError = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _forgotError = 'Passwords do not match.');
      return;
    }
    setState(() {
      _isForgotLoading = true;
      _forgotError = null;
    });
    try {
      await _client.emailIdp.finishPasswordReset(
        finishPasswordResetToken: _finishResetToken!,
        newPassword: password,
      );
      if (mounted) {
        _hideForgotPasswordFlow();
        setState(() => _errorMessage = null);
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _forgotError = 'Failed to reset password. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isForgotLoading = false);
    }
  }

  void _forgotGoBack() {
    setState(() {
      _forgotError = null;
      if (_forgotStep == 1) {
        _forgotCodeController.clear();
        _forgotStep = 0;
      } else if (_forgotStep == 2) {
        _forgotPasswordController.clear();
        _forgotConfirmPasswordController.clear();
        _forgotStep = 1;
      }
    });
  }

  Widget _buildForgotPasswordFlow() {
    return ShadApp(
      theme: widget.theme,
      home: Builder(
        builder: (context) {
          final theme = ShadTheme.of(context);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.logo != null) ...[
                      Center(child: widget.logo!),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Reset Password',
                      style: theme.textTheme.h1Large,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ShadCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _forgotStepDescription(),
                            style: theme.textTheme.muted,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_forgotError != null) ...[
                            ShadAlert.destructive(
                              icon: Icon(LucideIcons.circleAlert),
                              title: const Text('Error'),
                              description: Text(_forgotError!),
                            ),
                            const SizedBox(height: 16),
                          ],
                          ..._buildForgotStepContent(theme),
                        ],
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

  String _forgotStepDescription() => switch (_forgotStep) {
        0 => 'Enter your email to receive a reset code',
        1 => 'We sent a code to ${_forgotEmailController.text.trim()}',
        2 => 'Set your new password',
        _ => '',
      };

  List<Widget> _buildForgotStepContent(ShadThemeData theme) =>
      switch (_forgotStep) {
        0 => _buildForgotEmailStep(theme),
        1 => _buildForgotCodeStep(theme),
        2 => _buildForgotNewPasswordStep(theme),
        _ => [],
      };

  List<Widget> _buildForgotEmailStep(ShadThemeData theme) => [
        ShadInput(
          controller: _forgotEmailController,
          placeholder: const Text('Email'),
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => _handleStartReset(),
        ),
        const SizedBox(height: 16),
        ShadButton(
          onPressed: _isForgotLoading ? null : _handleStartReset,
          child: _isForgotLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send reset code'),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _hideForgotPasswordFlow,
            child: Text(
              'Back to sign in',
              style: theme.textTheme.muted.copyWith(
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ];

  List<Widget> _buildForgotCodeStep(ShadThemeData theme) => [
        ShadInput(
          controller: _forgotCodeController,
          placeholder: const Text('Verification code'),
          onSubmitted: (_) => _handleVerifyResetCode(),
        ),
        const SizedBox(height: 16),
        ShadButton(
          onPressed: _isForgotLoading ? null : _handleVerifyResetCode,
          child: _isForgotLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify code'),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _isForgotLoading ? null : _handleStartReset,
            child: Text(
              'Resend code',
              style: theme.textTheme.muted.copyWith(
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _forgotGoBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.arrowLeft,
                    size: 14, color: theme.colorScheme.mutedForeground),
                const SizedBox(width: 4),
                Text('Back', style: theme.textTheme.muted.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ),
      ];

  List<Widget> _buildForgotNewPasswordStep(ShadThemeData theme) => [
        ShadInput(
          controller: _forgotPasswordController,
          placeholder: const Text('New password'),
          obscureText: _obscureForgotPassword,
          trailing: GestureDetector(
            onTap: () =>
                setState(() => _obscureForgotPassword = !_obscureForgotPassword),
            child: Icon(
              _obscureForgotPassword ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ShadInput(
          controller: _forgotConfirmPasswordController,
          placeholder: const Text('Confirm new password'),
          obscureText: _obscureForgotConfirmPassword,
          onSubmitted: (_) => _handleFinishReset(),
          trailing: GestureDetector(
            onTap: () => setState(() =>
                _obscureForgotConfirmPassword = !_obscureForgotConfirmPassword),
            child: Icon(
              _obscureForgotConfirmPassword
                  ? LucideIcons.eyeOff
                  : LucideIcons.eye,
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShadButton(
          onPressed: _isForgotLoading ? null : _handleFinishReset,
          child: _isForgotLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Reset password'),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _forgotGoBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.arrowLeft,
                    size: 14, color: theme.colorScheme.mutedForeground),
                const SizedBox(width: 4),
                Text('Back', style: theme.textTheme.muted.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ),
      ];

  @override
  void dispose() {
    _auth.authInfoListenable.removeListener(_onAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    _forgotCodeController.dispose();
    _forgotPasswordController.dispose();
    _forgotConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_auth.isAuthenticated) {
      return widget.builder(context, _client, _handleSignOut);
    }

    if (_showForgotPassword) {
      return _buildForgotPasswordFlow();
    }

    return _buildSignInScreen();
  }

  Widget _buildLoadingScreen() {
    return ShadApp(
      theme: widget.theme,
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInScreen() {
    return ShadApp(
      theme: widget.theme,
      home: Builder(
        builder: (context) {
          final theme = ShadTheme.of(context);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.logo != null) ...[
                      Center(child: widget.logo!),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      widget.title,
                      style: theme.textTheme.h1Large,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (widget.subtitle != null) ...[
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.muted,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      const SizedBox(height: 32),
                    ],
                    ShadCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign in to continue',
                            style: theme.textTheme.h4,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_errorMessage != null) ...[
                            ShadAlert.destructive(
                              icon: Icon(LucideIcons.circleAlert),
                              title: const Text('Error'),
                              description: Text(_errorMessage!),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Google Sign-In
                          GoogleSignInWidget(
                            client: _client,
                            scopes: const [],
                            onAuthenticated: () {
                              if (mounted) setState(() {});
                            },
                            onError: (error) {
                              debugPrint('Google Sign-In error: $error');
                              setState(() {
                                _errorMessage =
                                    'Google Sign-In failed. Please try again.';
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text('or', style: theme.textTheme.muted),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Email field
                          ShadInput(
                            controller: _emailController,
                            placeholder: const Text('Email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          // Password field
                          ShadInput(
                            controller: _passwordController,
                            placeholder: const Text('Password'),
                            obscureText: _obscurePassword,
                            trailing: GestureDetector(
                              onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              child: Icon(
                                _obscurePassword
                                    ? LucideIcons.eyeOff
                                    : LucideIcons.eye,
                                size: 16,
                              ),
                            ),
                            onSubmitted: (_) => _handleEmailSubmit(),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _showForgotPasswordFlow,
                              child: Text(
                                'Forgot password?',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Sign-in button
                          ShadButton(
                            onPressed: _isEmailSigningIn
                                ? null
                                : _handleEmailSubmit,
                            child: _isEmailSigningIn
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Sign in with email'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'By signing in, you agree to our Terms of Service and Privacy Policy.',
                      style: theme.textTheme.muted.copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
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
