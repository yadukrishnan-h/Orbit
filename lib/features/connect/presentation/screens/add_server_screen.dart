import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/dashboard/providers/dashboard_providers.dart';
import 'package:uuid/uuid.dart';

class AddServerScreen extends ConsumerStatefulWidget {
  /// When non-null the form operates in "edit" mode, pre-filling all fields
  /// and updating the existing record instead of creating a new one.
  final Server? existingServer;

  const AddServerScreen({super.key, this.existingServer});

  @override
  AddServerScreenState createState() => AddServerScreenState();
}

class AddServerScreenState extends ConsumerState<AddServerScreen> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers so we can pre-fill them from existingServer.
  late final TextEditingController _nameController;
  late final TextEditingController _hostnameController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _privateKeyController;
  late final TextEditingController _passphraseController;

  bool _obscurePassword = true;
  bool _obscurePassphrase = true;
  AuthType _authType = AuthType.password;

  bool get _isEditMode => widget.existingServer != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existingServer;
    _nameController = TextEditingController(text: s?.name ?? '');
    _hostnameController = TextEditingController(text: s?.hostname ?? '');
    _portController = TextEditingController(
      text: s != null ? '${s.port}' : '22',
    );
    _usernameController = TextEditingController(text: s?.username ?? '');
    _passwordController = TextEditingController(
      // In edit mode, pre-fill with the stored password (plain-text from model).
      text: (s?.authType == AuthType.password) ? (s?.password ?? '') : '',
    );
    _privateKeyController = TextEditingController(
      text: (s?.authType == AuthType.key) ? (s?.privateKey ?? '') : '',
    );
    _passphraseController = TextEditingController(
      text: (s?.authType == AuthType.key) ? (s?.password ?? '') : '',
    );
    if (s != null) {
      _authType = s.authType;
      if (s.password.isEmpty &&
          (s.privateKey == null || s.privateKey!.isEmpty)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadExistingCredentials(s.id);
        });
      }
    }
  }

  Future<void> _loadExistingCredentials(String serverId) async {
    try {
      final repository = await ref.read(serverRepositoryProvider.future);
      final serverWithCreds = await repository.getServerWithCredentials(
        serverId,
      );
      if (mounted) {
        setState(() {
          if (serverWithCreds.authType == AuthType.password) {
            _passwordController.text = serverWithCreds.password;
          } else {
            _privateKeyController.text = serverWithCreds.privateKey ?? '';
            _passphraseController.text = serverWithCreds.password;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostnameController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _privateKeyController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      hintStyle: const TextStyle(color: AppTheme.disabled, fontSize: 13),
      prefixIcon: Icon(prefixIcon, size: 18, color: AppTheme.textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF15181E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.terminalMint, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.critical, width: 0.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.critical, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Server' : 'Add Server',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Info Section
                Text('GENERAL INFORMATION', style: AppTheme.sectionTitleStyle),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'Server Name',
                          prefixIcon: LucideIcons.tag,
                          hintText: 'e.g. Production Web',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a server name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _hostnameController,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                              decoration: _buildInputDecoration(
                                labelText: 'Hostname / IP',
                                prefixIcon: LucideIcons.globe,
                                hintText: '192.168.1.100',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a hostname';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _portController,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                labelText: 'Port',
                                prefixIcon: LucideIcons.hash,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    int.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Authentication Section
                Text('AUTHENTICATION', style: AppTheme.sectionTitleStyle),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'Username',
                          prefixIcon: LucideIcons.user,
                          hintText: 'admin',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<AuthType>(
                        initialValue: _authType,
                        dropdownColor: const Color(0xFF15181E),
                        style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'Auth Type',
                          prefixIcon: LucideIcons.shieldCheck,
                        ),
                        items: AuthType.values.map((AuthType type) {
                          return DropdownMenuItem<AuthType>(
                            value: type,
                            child: Text(
                              type.name[0].toUpperCase() +
                                  type.name.substring(1),
                            ),
                          );
                        }).toList(),
                        onChanged: (AuthType? newValue) {
                          setState(() {
                            _authType = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_authType == AuthType.password)
                        TextFormField(
                          controller: _passwordController,
                          decoration: _buildInputDecoration(
                            labelText: 'Password',
                            prefixIcon: LucideIcons.key,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? LucideIcons.eye
                                    : LucideIcons.eyeOff,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          enableIMEPersonalizedLearning: false,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          validator: (value) {
                            if (_authType == AuthType.password &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        )
                      else ...[
                        TextFormField(
                          controller: _privateKeyController,
                          decoration: _buildInputDecoration(
                            labelText: 'Private Key',
                            prefixIcon: LucideIcons.scroll,
                            hintText: '-----BEGIN OPENSSH PRIVATE KEY-----',
                          ),
                          minLines: 5,
                          maxLines: null,
                          enableSuggestions: false,
                          autocorrect: false,
                          enableIMEPersonalizedLearning: false,
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                          validator: (value) {
                            if (_authType == AuthType.key &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter a private key';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passphraseController,
                          decoration: _buildInputDecoration(
                            labelText: 'Private Key Passphrase (Optional)',
                            prefixIcon: LucideIcons.lock,
                            hintText: 'Leave empty if key has no passphrase',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassphrase
                                    ? LucideIcons.eye
                                    : LucideIcons.eyeOff,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassphrase = !_obscurePassphrase;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassphrase,
                          enableSuggestions: false,
                          autocorrect: false,
                          enableIMEPersonalizedLearning: false,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.heroGreenGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.terminalMint.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: const Color(0xFF0A0A0C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _handleSubmit,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isEditMode
                              ? LucideIcons.save
                              : LucideIcons.plusCircle,
                          size: 20,
                          color: const Color(0xFF0A0A0C),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEditMode ? 'Save Changes' : 'Add Server',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A0A0C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isEditMode) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.warning,
                        side: BorderSide(
                          color: AppTheme.warning.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      icon: const Icon(LucideIcons.shieldAlert, size: 18),
                      label: Text(
                        'Reset Pinned Host Key',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () =>
                          _confirmResetHostKey(widget.existingServer!.id),
                    ),
                  ),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmResetHostKey(String serverId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E222B),
        title: Text(
          'Reset Host Key?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will clear the stored host key fingerprint for this server. On the next connection, the host key will be re-pinned via Trust-On-First-Use (TOFU). Use this if your server was re-imaged or rebuilt.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(secureStorageServiceProvider)
          .deleteHostKeyFingerprint(serverId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pinned host key cleared successfully.'),
            backgroundColor: AppTheme.surface,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);

    try {
      // Read and sanitize field values from controllers.
      final name = _nameController.text.trim();
      var hostname = _hostnameController.text.trim();
      final port = int.parse(_portController.text.trim());
      final username = _usernameController.text.trim();
      final password = _authType == AuthType.password
          ? _passwordController.text
          : _passphraseController.text;
      final privateKey = _authType == AuthType.key
          ? _privateKeyController.text.trim()
          : null;

      // Sanitize hostname (strip if user accidentally included a port).
      if (hostname.contains(':') && !hostname.contains(']')) {
        final parts = hostname.split(':');
        if (parts.length == 2 && int.tryParse(parts[1]) != null) {
          hostname = parts[0];
        }
      }

      if (_isEditMode) {
        // ── EDIT MODE ───────────────────────────────────────────────────
        final existing = widget.existingServer!;

        final hostOrPortChanged =
            existing.hostname.trim() != hostname.trim() ||
            existing.port != port;
        if (hostOrPortChanged) {
          await ref
              .read(secureStorageServiceProvider)
              .deleteHostKeyFingerprint(existing.id);
        }

        final updatedServer = existing.copyWith(
          name: name,
          hostname: hostname,
          port: port,
          username: username,
          authType: _authType,
          password: password,
          privateKey: privateKey,
        );

        // Persist changes to Hive/Secure Storage (updateServer preserves the internal ID).
        final repository = await ref.read(serverRepositoryProvider.future);
        await repository.updateServer(updatedServer);

        // Force SSH session teardown and reconnect with fresh credentials.
        final vm = ref.read(serverMonitorViewModelProvider.notifier);
        await vm.reinitializeServer(existing.id);
      } else {
        // ── ADD MODE ────────────────────────────────────────────────────
        final serverId = const Uuid().v4();

        final newServer = Server(
          id: serverId,
          name: name,
          hostname: hostname,
          port: port,
          username: username,
          authType: _authType,
          password: password,
          privateKey: privateKey,
        );

        final repository = await ref.read(serverRepositoryProvider.future);
        await repository.addServer(newServer);

        // Immediately kick off monitoring — don't wait for the stream listener
        // to fire. This ensures the dashboard card shows "Connecting..." right
        // away rather than appearing blank until the next stream emission.
        ref
            .read(serverMonitorViewModelProvider.notifier)
            .startMonitoring(serverId);
      }

      if (mounted) {
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Error saving server: $e'
                  : 'Error adding server: $e',
            ),
            backgroundColor: AppTheme.critical,
          ),
        );
      }
    }
  }
}
