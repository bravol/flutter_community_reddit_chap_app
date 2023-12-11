import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_community_redit_chat_app/core/failure.dart';
import 'package:flutter_community_redit_chat_app/core/providers/firebase_provider.dart';
import 'package:flutter_community_redit_chat_app/core/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

// a provider
final storageRepositoryProvider = Provider(
    (ref) => StorageRepository(firebaseStorage: ref.watch(storageProvider)));

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  //a function to store file FutureEither(it can either returen error or a String)
  FutureEither<String> storeFile(
      {required String path,
      required String id,
      required File? file,
      required Uint8List? webFile}) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(webFile!);
      } else {
        uploadTask = ref.putFile(file!);
      }

      //users/proflePic/123

      final snapshot = await uploadTask;

      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
