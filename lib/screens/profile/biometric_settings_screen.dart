import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/services/biometric_service.dart';
import 'package:homechef/l10n/app_localizations.dart';

class BiometricSettingsScreen extends ConsumerStatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  ConsumerState<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends ConsumerState<BiometricSettingsScreen> {
  bool _biometricAvailable = false;
  bool _biometricLoginEnabled = false;
  bool _paymentProtectionEnabled = false;
  String _biometricType = 'Biometrisk';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final biometricAvailable = await BiometricService.instance.isBiometricAvailable();
    final biometricLoginEnabled = await BiometricService.instance.isBiometricLoginEnabled();
    final paymentProtectionEnabled = await BiometricService.instance.isPaymentProtectionEnabled();
    final biometricType = await BiometricService.instance.getAvailableBiometricString();
    
    if (mounted) {
      setState(() {
        _biometricAvailable = biometricAvailable;
        _biometricLoginEnabled = biometricLoginEnabled;
        _paymentProtectionEnabled = paymentProtectionEnabled;
        _biometricType = biometricType;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.biometricSettings ?? 'Biometriske indstillinger'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_biometricAvailable
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Biometrisk godkendelse ikke tilgængelig',
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Din enhed understøtter ikke Face ID eller Touch ID, eller det er ikke konfigureret i enhedens indstillinger.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Om biometrisk sikkerhed',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Din enhed understøtter $_biometricType. Du kan bruge det til at logge ind og sikre betalinger.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Login indstillinger',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: SwitchListTile(
                        secondary: const Icon(Icons.fingerprint),
                        title: Text('Brug $_biometricType til login'),
                        subtitle: Text(
                          'Log hurtigt ind med $_biometricType i stedet for adgangskode',
                          style: theme.textTheme.bodySmall,
                        ),
                        value: _biometricLoginEnabled,
                        onChanged: (value) async {
                          if (value) {
                            final authenticated = await BiometricService.instance.authenticate(
                              reason: 'Bekræft for at aktivere $_biometricType login',
                            );
                            
                            if (authenticated) {
                              await BiometricService.instance.setBiometricLoginEnabled(true);
                              setState(() {
                                _biometricLoginEnabled = true;
                              });
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$_biometricType login aktiveret'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } else {
                            await BiometricService.instance.setBiometricLoginEnabled(false);
                            setState(() {
                              _biometricLoginEnabled = false;
                            });
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$_biometricType login deaktiveret'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Betalingssikkerhed',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: SwitchListTile(
                        secondary: const Icon(Icons.lock_outline),
                        title: Text('Kræv $_biometricType for betalinger'),
                        subtitle: Text(
                          'Bekræft din identitet før hver betaling',
                          style: theme.textTheme.bodySmall,
                        ),
                        value: _paymentProtectionEnabled,
                        onChanged: (value) async {
                          if (value) {
                            final authenticated = await BiometricService.instance.authenticate(
                              reason: 'Bekræft for at aktivere betalingsbeskyttelse',
                            );
                            
                            if (authenticated) {
                              await BiometricService.instance.setPaymentProtectionEnabled(true);
                              setState(() {
                                _paymentProtectionEnabled = true;
                              });
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Betalingsbeskyttelse aktiveret'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } else {
                            await BiometricService.instance.setPaymentProtectionEnabled(false);
                            setState(() {
                              _paymentProtectionEnabled = false;
                            });
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Betalingsbeskyttelse deaktiveret'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    if (_biometricLoginEnabled) ...[
                      Card(
                        elevation: 0,
                        color: Colors.orange.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.orange.shade200,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sikkerhedsadvarsel',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Dine login-oplysninger gemmes sikkert på din enhed. De slettes automatisk efter 30 dage uden brug.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Ryd gemte oplysninger'),
                              content: Text(
                                'Dette vil fjerne dine gemte login-oplysninger. Du skal indtaste din adgangskode næste gang du logger ind.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Annuller'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Ryd',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            await BiometricService.instance.clearSavedCredentials();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gemte oplysninger ryddet'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text(
                          'Ryd gemte login-oplysninger',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}