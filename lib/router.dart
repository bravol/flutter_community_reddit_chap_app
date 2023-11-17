import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/screens/HomeScreen.dart';
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
});
