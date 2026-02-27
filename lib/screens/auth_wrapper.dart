// lib/screens/auth_wrapper.dart
// Listens to Firebase auth state and routes to Login or FileManager.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/file_manager_provider.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'file_manager_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Signed in — make sure provider loads root
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<FileManagerProvider>().refresh();
          });
          return const FileManagerScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF97316),
          strokeWidth: 2,
        ),
      ),
    );
  }
}