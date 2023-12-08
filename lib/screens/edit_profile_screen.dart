import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/community_controller.dart';
import 'package:flutter_community_redit_chat_app/core/common/error_text.dart';
import 'package:flutter_community_redit_chat_app/core/constants/constants.dart';
import 'package:flutter_community_redit_chat_app/core/loader.dart';
import 'package:flutter_community_redit_chat_app/core/utils.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_community_redit_chat_app/features/auth/controller/user_profile_controller.dart';
import 'package:flutter_community_redit_chat_app/responsive/responsive.dart';
import 'package:flutter_community_redit_chat_app/theme/pallete.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditUserProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditUserProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends ConsumerState<EditUserProfileScreen> {
  File? bannerFile;
  File? profileFile;
  Uint8List? bannerWebfile;
  Uint8List? profileWebfile;
  late TextEditingController nameController;
  //select banner image
  void selectBannerImage() async {
    final res = await pickImage();
    if (kIsWeb) {
      setState(() {
        bannerWebfile = res!.files.first.bytes;
      });
    } else {
      setState(() {
        bannerFile = File(res!.files.first.path!);
      });
    }
  }

  //select profile image
  void selectProfileImage() async {
    final res = await pickImage();
    if (kIsWeb) {
      setState(() {
        profileWebfile = res!.files.first.bytes;
      });
    } else {
      setState(() {
        profileFile = File(res!.files.first.path!);
      });
    }
  }

  //save
  void save() {
    ref.read(userProfileControllerProvider.notifier).editUserprofile(
        profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        bannerWebFile: bannerWebfile,
        profileWebFile: profileWebfile,
        name: nameController.text.trim());
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) => Scaffold(
            backgroundColor: currentTheme.backgroundColor,
            appBar: AppBar(
              title: const Text('Edit Profile'),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: save,
                  child: const Text('Save'),
                )
              ],
            ),
            body: isLoading
                ? const Loader()
                : Responsive(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  strokeCap: StrokeCap.round,
                                  color:
                                      currentTheme.textTheme.bodyText2!.color!,
                                  child: GestureDetector(
                                    onTap: selectBannerImage,
                                    child: Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerWebfile != null
                                          ? Image.memory(bannerWebfile!)
                                          : bannerFile != null
                                              ? Image.file(bannerFile!)
                                              : user.banner.isEmpty ||
                                                      user.banner ==
                                                          Constants
                                                              .bannerDefault
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons
                                                            .camera_alt_outlined,
                                                        size: 40,
                                                      ),
                                                    )
                                                  : Image.network(user.banner),
                                    ),
                                  ),
                                ),
                                //positioning the avatar
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: selectProfileImage,
                                    child: profileWebfile != null
                                        ? CircleAvatar(
                                            backgroundImage: MemoryImage(
                                              profileWebfile!,
                                            ),
                                            radius: 32,
                                          )
                                        : profileFile != null
                                            ? CircleAvatar(
                                                backgroundImage: FileImage(
                                                  profileFile!,
                                                ),
                                                radius: 32,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  user.profilePicture,
                                                ),
                                                radius: 32,
                                              ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                                filled: true,
                                hintText: 'Name',
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(20)),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
        );
  }
}
