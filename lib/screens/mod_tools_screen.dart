import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  const ModToolsScreen({super.key, required this.id});
  final String id;

  void naviateToEditCommunityScreen(BuildContext context) {
    Routemaster.of(context).push('/edit-community/$id');
  }

  // to add moderator screen
  void naviateToAddModeratorScreen(BuildContext context) {
    Routemaster.of(context).push('/add-moderator/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod tools'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text('Add Moderators'),
            onTap: () => naviateToAddModeratorScreen(context),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Community'),
            onTap: () => naviateToEditCommunityScreen(context),
          ),
        ],
      ),
    );
  }
}
