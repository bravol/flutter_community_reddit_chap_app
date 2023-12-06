import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/community/screens/community_screen.dart';
import 'package:flutter_community_redit_chat_app/community/screens/create_community_screen.dart';
import 'package:flutter_community_redit_chat_app/features/posts/add_post_type_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/add_moderator.dart';
import 'package:flutter_community_redit_chat_app/screens/comments_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/edit_community_Screen.dart';
import 'package:flutter_community_redit_chat_app/screens/edit_profile_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/home_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/login_user_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/mod_tools_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/signup_user_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/user_profile_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/welcome_screen.dart';
import 'package:routemaster/routemaster.dart';

//loggedOut(routes accesssible when the user is logged)
final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: WelcomeScreen()),
  '/login_screen': (_) => const MaterialPage(child: LoginScreeen()),
  '/sign_up_screen': (_) => const MaterialPage(child: SignUpScreen()),
});

//loggedIn(routes accessible when the user is logged in)
final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create_community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  '/r/:id': (route) => MaterialPage(
          child: CommunityScreen(
        id: route.pathParameters['id']!,
      )),
  '/mod-tools/:id': (routeData) => MaterialPage(
          child: ModToolsScreen(
        id: routeData.pathParameters['id']!,
      )),
  '/edit-community/:id': (routeData) => MaterialPage(
          child: EditCommunityScreen(
        id: routeData.pathParameters['id']!,
      )),
  '/add-moderator/:id': (routeData) => MaterialPage(
          child: AddModeratorScreen(
        id: routeData.pathParameters['id']!,
      )),
  '/u/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/edit-profile/:uid': (routeData) => MaterialPage(
          child: EditUserProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/add-post-type/:type': (routeData) => MaterialPage(
          child: AddPostTypeScreen(
        type: routeData.pathParameters['type']!,
      )),
  '/post/:postId/comments': (routeData) => MaterialPage(
          child: CommentScreen(
        postId: routeData.pathParameters['postId']!,
      )),
});
