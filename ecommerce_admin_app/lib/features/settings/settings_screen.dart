import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _darkModeMock = false;
  bool _emailAlertsMock = true;
  String _selectedCurrency = 'USD (\$)';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: auth.adminName);
    _emailController = TextEditingController(text: auth.adminEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() async {
    if (_profileFormKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.updateProfile(
        _nameController.text.trim(),
        _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin Profile Updated Successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildProfileCard(authProvider)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildAppSettingsCard()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildProfileCard(authProvider),
                    const SizedBox(height: 24),
                    _buildAppSettingsCard(),
                  ],
                ),
              
              const SizedBox(height: 24),
              
              // Dangerous Area / Logout Card
              _buildDangerousAreaCard(authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider auth) {
    return CustomCard(
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.person_outline, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'Admin Profile Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Profile Icon Avatar display
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      auth.adminName.isNotEmpty ? auth.adminName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('System Administrator Role', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomTextField(
              labelText: 'Administrator Name',
              hintText: 'e.g. Wade Warren',
              controller: _nameController,
              validator: (v) => v!.isEmpty ? 'Admin name cannot be blank' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              labelText: 'System Email Address',
              hintText: 'e.g. admin@cashew.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty) return 'Email cannot be blank';
                if (!v.contains('@')) return 'Invalid email address';
                return null;
              },
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Update Credentials',
                isLoading: auth.isLoading,
                onPressed: _handleSaveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune_outlined, color: Colors.blue, size: 24),
              SizedBox(width: 10),
              Text(
                'Global App Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dark Mode Switch
          SwitchListTile(
            title: const Text('Simulate Dark Mode (Dev)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            subtitle: const Text('Toggle local dark UI theme simulation', style: TextStyle(fontSize: 11)),
            value: _darkModeMock,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _darkModeMock = val;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark Theme simulator updated.')),
              );
            },
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 16),

          // Email Notification Alerts
          SwitchListTile(
            title: const Text('Email Stock Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            subtitle: const Text('Get email notifications when inventory is low', style: TextStyle(fontSize: 11)),
            value: _emailAlertsMock,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _emailAlertsMock = val;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 24),

          // Currency Dropdown Selector
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(labelText: 'Store Billing Currency'),
            items: const [
              DropdownMenuItem(value: 'USD (\$)', child: Text('US Dollars (USD)')),
              DropdownMenuItem(value: 'EUR (€)', child: Text('Euro (EUR)')),
              DropdownMenuItem(value: 'GBP (£)', child: Text('British Pound (GBP)')),
            ],
            onChanged: (val) {
              setState(() {
                _selectedCurrency = val!;
              });
            },
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Cashew Admin Dashboard Platform Version: v${AppConstants.appVersion}',
              style: TextStyle(color: AppColors.textLight, fontSize: 11),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDangerousAreaCard(AuthProvider auth) {
    return CustomCard(
      borderSide: const BorderSide(color: AppColors.error, width: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Session Logout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error),
                ),
                SizedBox(height: 4),
                Text(
                  'End your current admin portal session. You will be redirected back to the login screen.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CustomButton(
            text: 'Sign Out',
            customColor: AppColors.error,
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
