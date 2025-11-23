import 'package:flutter/material.dart';

class PermissionService {
  /// Show privacy policy in a dialog or screen
  static Future<void> showPrivacyPolicy(BuildContext context) async {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const _PolicyScreen(
            title: 'Privacy Policy',
            content: _defaultPrivacyPolicy,
          ),
        ),
      );
    }
  }

  /// Show terms of service
  static Future<void> showTermsOfService(BuildContext context) async {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const _PolicyScreen(
            title: 'Terms of Service',
            content: _defaultTermsOfService,
          ),
        ),
      );
    }
  }

  static const String _defaultPrivacyPolicy = '''
# Privacy Policy for ClassHub

**Last Updated:** January 2025

## Introduction

ClassHub ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard information in our School Management application.

## Data Collection and Storage

### Local-Only Storage
ClassHub operates as an **offline-first application**. All data is stored locally on your device using SQLite database. We do not collect, transmit, or store any data on external servers.

### Types of Data Stored Locally
- **Student Information**: Names, student IDs, class assignments, parent contact information
- **Attendance Records**: Check-in/check-out times, attendance status, and notes
- **Class Information**: Class names, descriptions, and teacher assignments
- **Announcements**: Teacher announcements
- **Teacher Information**: Names, email addresses, and role assignments

## Data Security

- All data is encrypted at rest using Android's built-in encryption
- No network transmission of personal data
- No data sharing with third parties

## Your Rights

You have the right to:
- **Access**: View all data stored in the app
- **Delete**: Remove any data through the app's interface
- **Export**: Export all data for backup purposes

## Data Retention

Data is retained on your device until you:
- Delete it through the app interface
- Uninstall the app (which removes all local data)
- Export and then clear the database

**Note**: This is a local-only application. No data leaves your device unless you explicitly export it.
''';

  static const String _defaultTermsOfService = '''
# Terms of Service for ClassHub

**Last Updated:** January 2025

## Acceptance of Terms

By using ClassHub, you agree to be bound by these Terms of Service.

## Use of the Application

ClassHub is designed for educational purposes to help manage school-related information locally on your device.

## Data Responsibility

- You are responsible for maintaining the security of your device
- All data is stored locally on your device
- You are responsible for backing up your data using the export feature

## Limitation of Liability

ClassHub operates entirely offline and stores data locally. We are not responsible for data loss due to device failure, uninstallation, or other circumstances beyond our control.

## Changes to Terms

We may update these Terms of Service from time to time. Continued use of the app constitutes acceptance of any changes.
''';
}

class _PolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const _PolicyScreen({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
