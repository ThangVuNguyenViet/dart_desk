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
            ..authSessionManager = FlutterAuthSessionManager();

      // Save reference before wrapping (auth getter checks type of authKeyProvider)
      _sessionManager = _client.authSessionManager;

      // Wrap auth with API key provider so every RPC call includes the key
      _client.authKeyProvider = DartDeskAuthKeyProvider(
        apiKey: widget.apiKey,
        inner: _client.authKeyProvider,
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

  @override
  void dispose() {
    _auth.authInfoListenable.removeListener(_onAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
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
