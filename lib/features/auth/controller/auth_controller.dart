import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/features/auth/repository/auth_repository.dart';
import 'package:flutter_community_redit_chat_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_community_redit_chat_app/core/utils.dart';

//auth controller provider. communicates btn UI and repository(middle Man)

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
    (ref) => AuthController(authRepository: ref.watch(authRepositoryProvider)));

//auth state change controller
final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

//stream provider to gt user data
final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(false);

//sign up the user for the first time
  void signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
    BuildContext context,
  ) async {
    state = true;
    final res = await _authRepository.signUpWithEmailAndPassword(
      email,
      password,
      fullName,
    );
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'Account created successfully');
      Routemaster.of(context).push('/');
    });
  }

  //getting auth state change
  Stream<User?> get authStateChange => _authRepository.authStateChange;

  //sign in with email and password
  void signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    state = true;
    final user =
        await _authRepository.signInWithEmailAndPassword(email, password);
    state = false;
    user.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'You are now signed in');
      Routemaster.of(context).push('/');
    });
  }

  //signout user
  void signOutUser(BuildContext context) async {
    state = true;
    final res = await _authRepository.signOut();
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'You have been logged out Successfully');
      Routemaster.of(context).push('/');
    });
  }

  //setNewPassword
  void setNewPassword(String newPassword, BuildContext context) async {
    state = true;
    final response = await _authRepository.setNewPassword(newPassword);
    state = false;
    response.fold((l) => showErrorSnackBar(context, l.message), (r) {
      showSuccessSnackBar(context, 'New Password has been set Successfully');
      Routemaster.of(context).push('/login_user_screen');
    });
  }

// a contoller to communicate with the auth repository to get users data
  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }
}
