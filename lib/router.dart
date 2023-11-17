//loggedOut(routes accesssible when the user is logged)

//loggedIn(routes accessible when the user is logged in)

import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/community/screens/community_screen.dart';
import 'package:flutter_community_redit_chat_app/community/screens/create_community_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/home_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/login_user_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/signup_user_screen.dart';
import 'package:flutter_community_redit_chat_app/screens/welcome_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: WelcomeScreen()),
  '/login_screen': (_) => const MaterialPage(child: LoginScreeen()),
  '/sign_up_screen': (_) => const MaterialPage(child: SignUpScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create_community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      ))
});
