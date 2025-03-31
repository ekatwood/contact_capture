// cc_appbar.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CCAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  const CCAppBar({super.key, required this.isLoggedIn});

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await _storage.delete(key: 'google_sign_in');  // Remove cookie
    await _storage.delete(key: 'cookie_expiration'); // Remove expiration
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFD11990), // Primary color
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      leading: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/home'),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
      ),
      actions: [
        if (!isLoggedIn)
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/log_in'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/login_button.png', fit: BoxFit.contain),
            ),
          ),
        if (isLoggedIn)
          GestureDetector(
            onTap: _signOut,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/signout_button.png', fit: BoxFit.contain),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
