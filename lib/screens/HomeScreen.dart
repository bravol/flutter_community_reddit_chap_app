import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  //logout
  void _logout() {
    ref.watch(authControllerProvider.notifier).signOutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text('This is chat community app'),
          ),
          TextButton(
              onPressed: _logout,
              child: const Text(
                'LOGOUT',
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }
}
