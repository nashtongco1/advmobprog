import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  final UserService _userService =
      UserService();

  bool _isLoggingOut = false;

  Future<void> _logout() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log Out',
          ),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Log Out',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _userService.logout();

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        '/signin',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.redAccent,
          content: Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final themeProvider =
        context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Settings',
          fontSize: 20,
          fontWeight:
              FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SwitchListTile(
                title: CustomText(
                  text:
                      themeProvider.isDark
                          ? 'Dark Mode'
                          : 'Light Mode',
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
                subtitle:
                    CustomText(
                  text:
                      themeProvider.isDark
                          ? 'Switch to light mode.'
                          : 'Switch to dark mode.',
                  fontSize: 13,
                ),
                secondary: Icon(
                  themeProvider.isDark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                value:
                    themeProvider.isDark,
                onChanged: (value) {
                  themeProvider
                      .toggleTheme();
                },
              ),
              const Divider(
                height: 1,
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color:
                      Colors.redAccent,
                ),
                title:
                    const CustomText(
                  text: 'Log Out',
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
                subtitle:
                    const CustomText(
                  text:
                      'Sign out of your account.',
                  fontSize: 13,
                ),
                trailing:
                    const Icon(
                  Icons.chevron_right,
                ),
                onTap:
                    _isLoggingOut
                        ? null
                        : _logout,
              ),
            ],
          ),
          if (_isLoggingOut)
            Positioned.fill(
              child: Container(
                color: Colors.black
                    .withValues(
                  alpha: 0.25,
                ),
                child:
                    const Center(
                  child:
                      CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}