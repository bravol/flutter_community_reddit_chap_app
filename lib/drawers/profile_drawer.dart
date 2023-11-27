import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/theme/pallete.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  //loging out
  void logout(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.profilePicture),
            radius: 70,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'u/${user.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          ListTile(
            title: const Text('my Profile'),
            leading: const Icon(
              Icons.person,
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Log out'),
            leading: Icon(
              Icons.logout,
              color: Pallete.redColor,
            ),
            onTap: () => logout(ref),
          ),
          //switch
          Switch.adaptive(value: true, onChanged: (val) {})
        ],
      )),
    );
  }
}
