import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/widgets/system_card.dart';
import 'package:orbit/features/dashboard/providers/dashboard_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  AuthType _authType = AuthType.password;

  bool get _isEditMode => widget.existingServer != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existingServer;
    _nameController = TextEditingController(text: s?.name ?? '');
    _hostnameController = TextEditingController(text: s?.hostname ?? '');
    _portController =
        TextEditingController(text: s != null ? '${s.port}' : '22');
    _usernameController = TextEditingController(text: s?.username ?? '');
    _passwordController = TextEditingController(
      // In edit mode, pre-fill with the stored password (plain-text from model).
      text: (s?.authType == AuthType.password) ? (s?.password ?? '') : '',
    );
    _privateKeyController = TextEditingController(
      text: (s?.authType == AuthType.key) ? (s?.password ?? '') : '',
    );
    if (s != null) {
      _authType = s.authType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostnameController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _privateKeyController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppTheme.disabled, fontSize: 13),
      prefixIcon: Icon(prefixIcon, size: 18, color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.critical),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.critical, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Icon / Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEditMode ? LucideIcons.edit : LucideIcons.server,
                        size: 40,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isEditMode
                          ? 'UPDATE SERVER CONFIGURATION'
                          : 'CONNECT TO A NEW SYSTEM',
                      style: AppTheme.sectionHeaderStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // General Info Section
              Text('GENERAL INFORMATION', style: AppTheme.sectionHeaderStyle),
              const SizedBox(height: 12),
              SystemCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
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
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _hostnameController,
                            style: const TextStyle(
                                color: AppTheme.textPrimary, fontSize: 14),
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
                                color: AppTheme.textPrimary, fontSize: 14),
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
              Text('AUTHENTICATION', style: AppTheme.sectionHeaderStyle),
              const SizedBox(height: 12),
              SystemCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AuthType>(
                      initialValue: _authType,
                      dropdownColor: AppTheme.surface,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary, fontSize: 14),
                      decoration: _buildInputDecoration(
                        labelText: 'Auth Type',
                        prefixIcon: LucideIcons.shieldCheck,
                      ),
                      items: AuthType.values.map((AuthType type) {
                        return DropdownMenuItem<AuthType>(
                          value: type,
                          child: Text(type.name[0].toUpperCase() +
                              type.name.substring(1)),
                        );
                      }).toList(),
                      onChanged: (AuthType? newValue) {
                        setState(() {
                          _authType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_authType == AuthType.password)
                      TextFormField(
                        controller: _passwordController,
                        decoration: _buildInputDecoration(
                          labelText: 'Password',
                          prefixIcon: LucideIcons.key,
                        ),
                        obscureText: true,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                        validator: (value) {
                          if (_authType == AuthType.password &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      )
                    else
                      TextFormField(
                        controller: _privateKeyController,
                        decoration: _buildInputDecoration(
                          labelText: 'Private Key',
                          prefixIcon: LucideIcons.scroll,
                          hintText: '-----BEGIN OPENSSH PRIVATE KEY-----',
                        ),
                        maxLines: 5,
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
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _handleSubmit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditMode ? LucideIcons.save : LucideIcons.plusCircle,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isEditMode ? 'Save Changes' : 'Add Server',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
          : _privateKeyController.text;

      // Sanitize hostname (strip if user accidentally included a port).
      if (hostname.contains(':') && !hostname.contains(']')) {
        final parts = hostname.split(':');
        if (parts.length == 2 && int.tryParse(parts[1]) != null) {
          hostname = parts[0];
        }
      }

      final secureStorage = const FlutterSecureStorage();

      if (_isEditMode) {
        // ── EDIT MODE ───────────────────────────────────────────────────
        final existing = widget.existingServer!;

        final updatedServer = existing.copyWith(
          name: name,
          hostname: hostname,
          port: port,
          username: username,
          authType: _authType,
          password: _authType == AuthType.password ? password : '',
        );

        // Persist changes to Isar (updateServer preserves the internal ID).
        final repository = await ref.read(serverRepositoryProvider.future);
        await repository.updateServer(updatedServer);

        // Update secure storage with the new credential.
        if (_authType == AuthType.password) {
          await secureStorage.write(
              key: 'server_${existing.id}_password', value: password);
        } else {
          await secureStorage.write(
              key: 'server_${existing.id}_privateKey', value: password);
        }

        // Force SSH session teardown and reconnect with fresh credentials.
        final vm = ref.read(serverMonitorViewModelProvider.notifier);
        vm.reinitializeServer(existing.id);
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
          password: _authType == AuthType.password ? password : '',
        );

        if (_authType == AuthType.password) {
          await secureStorage.write(
              key: 'server_${serverId}_password', value: password);
        } else {
          await secureStorage.write(
              key: 'server_${serverId}_privateKey', value: password);
        }

        final service = await ref.read(serverServiceProvider.future);
        await service.addServer(newServer);

        ref.invalidate(serverListProvider);
      }

      if (mounted) {
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditMode
                  ? 'Error saving server: $e'
                  : 'Error adding server: $e'),
              backgroundColor: AppTheme.critical),
        );
      }
    }
  }
}
