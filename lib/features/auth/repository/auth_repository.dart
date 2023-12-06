import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_community_redit_chat_app/core/constants/constants.dart';
import 'package:flutter_community_redit_chat_app/core/constants/firebase_constants.dart';
import 'package:flutter_community_redit_chat_app/core/failure.dart';
import 'package:flutter_community_redit_chat_app/core/providers/firebase_provider.dart';
import 'package:flutter_community_redit_chat_app/core/type_def.dart';
import 'package:flutter_community_redit_chat_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:firebase_auth/firebase_auth.dart';

//setting provider
final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: ref.watch(authProvider), firestore: ref.watch(firestoreProvider)));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  //creatiing a getter to store users in firestore
  CollectionReference get _storeUser =>
      _firestore.collection(FirebaseConstants.usersCollection);

  //stream of users that will aloww us if the user is changed or not, logged in or logged out
  Stream<User?> get authStateChange => _auth.authStateChanges();

  //sign up with email and password.
  FutureEither<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

//capturing users data and storing it in database

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: fullName,
          email: email,
          profilePicture: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: ['til', 'thankyou', 'gold', 'rocket'],
        );
        await _storeUser.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }

      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //sign in with email address and password
  FutureEither signInWithEmailAndPassword(String email, String password) async {
    try {
      var userDoc = await _storeUser.doc(email).get();

      if (userDoc.exists) {
        throw 'Email already in use';
      }
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return right(userCredential);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //logout the user
  FutureVoid signOut() async {
    try {
      final userOut = await _auth.signOut();
      return right(userOut);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //set new password
  FutureEither<bool> setNewPassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

//getting user data stream from the database
  Stream<UserModel> getUserData(String uid) {
    return _storeUser.doc(uid).snapshots().map(
          (snap) => UserModel.fromMap(snap.data() as Map<String, dynamic>),
        );
  }

  //logging out
  void logout() async {
    await _auth.signOut();
  }
}
