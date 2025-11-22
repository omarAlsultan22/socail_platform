import 'dart:io';
import 'post_components.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../constants/user_details.dart';
import '../../../models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../modules/home_screen/cubit.dart';
import 'package:social_app/models/post_model.dart';
import '../../../modules/profile_screen/cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';


Future<Map<String, dynamic>> getUserAccount({
  required Map<String, dynamic> userAccount,
}) async {
  try {
    if (userAccount['userImage'] is DocumentReference) {
      final imageDocRef = userAccount['userImage'] as DocumentReference;
      final imageDoc = await imageDocRef.get();

      if (imageDoc.exists && imageDoc.data() != null) {
        final imageData = imageDoc.data() as Map<String, dynamic>;
        userAccount['userImage'] = imageData['userPost'] as String? ?? '';
      } else {
        userAccount['userImage'] = '';
      }
    }
    return userAccount;
  }
  catch (e) {
    print('Error in getAccount: $e');
    return {};
  }
}


Future<Map<String, dynamic>> getAccountMap({
  required DocumentSnapshot userDoc,
}) async {
  try {
    final userAccount = userDoc.data() as Map<String, dynamic>? ?? {};
    return await getUserAccount(userAccount: userAccount);
  } catch (e) {
    print('Error in getAccount: $e');
    return {};
  }
}

Future<UserModel> getUserModelData({
  required String id,
})async {
  UserModel userModel;
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('accounts').doc(id).get();
    final data = await getAccountMap(userDoc: userDoc);
    UserModel accountData = UserModel.fromJson(data);
    userModel = accountData;
  } catch (e) {
    rethrow;
  }
  return userModel;
}

Future<UserModel>getUserAccountData()async {
  final firestore = FirebaseFirestore.instance;
  final docData = await firestore.collection('accounts').doc(UserDetails.uId).get();
  final userAccount = await getAccountMap(userDoc: docData);
  UserModel userModel = UserModel.fromJson(userAccount);
  return userModel;
}


Future<File?> pickImage() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      return file;
    }
    return null;
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}

Future<File?> pickVideo() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      return file;
    }
    return null;
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}



Future<Map<String, dynamic>?> checkFile(File file) async {
  try {
    String filePath = file.path.toLowerCase();
    String extension = path.extension(filePath).replaceFirst('.', '');

    List<String> imageExtensions = ['jpg', 'png', 'jpeg', 'gif', 'webp'];
    List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv'];

    if (imageExtensions.contains(extension)) {
      return await uploadFile(file, 'image');
    } else if (videoExtensions.contains(extension)) {
      return await uploadFile(file, 'video');
    } else {
      print('Unsupported file type: $extension');
      return null;
    }
  } catch (e) {
    print('Error checking file: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> uploadFile(File file, String folderName) async {
  try {
    String fileName = path.basename(file.path);
    Reference storageReference =
    FirebaseStorage.instance.ref().child('$folderName/$fileName');

    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    if (snapshot.state == TaskState.success) {
      String downloadUrl = await storageReference.getDownloadURL();
      print('File uploaded to $folderName"s/$fileName');
      return {
        'url': downloadUrl,
        'type': folderName,
        'file': file
      };
    } else {
      print('Upload failed');
      return null;
    }
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}


Future navigator(BuildContext context, Widget link) =>
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => link));

class FriendButton extends StatefulWidget {
  final String buttonName;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  FriendButton({
    required this.buttonName,
    this.textColor,
    this.backgroundColor,
    required this.onPressed,
    super.key,
  });

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  late String currentButtonName;

  @override
  void initState() {
    super.initState();
    currentButtonName = widget.buttonName;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (currentButtonName == 'Unfriend') {
          setState(() => currentButtonName = 'Add Friend');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('The friendship has been successfully cancelled'),
            backgroundColor: Colors.green,));
        } else if (currentButtonName == 'Add Friend') {
          setState(() => currentButtonName = 'Send Request');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Your friend request has been sent successfully'),
            backgroundColor: Colors.green,));
        }
        else {
          setState(() => currentButtonName = 'Add Friend');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('The friend request has been successfully cancelled'),
            backgroundColor: Colors.green,));
        }
        widget.onPressed();
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
            widget.backgroundColor ?? Colors.black),
      ),
      child: Text(
        currentButtonName,
        style: TextStyle(
          color: widget.textColor ?? Colors.blue.shade700,
        ),
      ),
    );
  }
}


class ListBuilder<T> extends StatelessWidget {
  Widget Function(T) object;
  final List<T> list;
  final Widget fallback;

  ListBuilder({
    required this.list,
    required this.object,
    required this.fallback,
    super.key});


  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: list.isNotEmpty,
      builder: (context) =>
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => object(list[index]),
              itemCount: list.length,
            ),
          ),
      fallback: (context) => Center(child: fallback),
    );
  }
}

class CommentForm extends StatelessWidget {
  final void Function(String) onPressed;

  const CommentForm({
    required this.onPressed,
    super.key});

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: buildInputField(
                  controller: commentController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      return value;
                    }
                    return null;
                  },
                  hint: 'Let a comment here',
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  onPressed(commentController.text);
                  commentController.text = '';
                },
                icon: Icon(Icons.send, color: Colors.blue.shade900,))
          ],
        )
    );
  }
}


Container container() =>
    Container(
      height: 1.0,
      color: Colors.grey,
    );


Widget iconButton({
  required VoidCallback onPressed,
  required Icon icon,
  required String tooltip,
}) {
  return Expanded(
    child: Container(
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
      ),
    ),
  );
}


Future<void> insertLikeModel(PostModel postModel)async {
  FirebaseFirestore.instance.collection('users').doc(UserDetails.uId).collection(
      'postsModel').doc(postModel.docId).update(postModel.toMap());
}


Future<void> showExitDialog({
  required String type,
  required BuildContext context,
  required void Function(bool) onPressed,
}) async {
  return await showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
          content: Text('Are you sure you want to delete this $type?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                onPressed(true);
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Deleted Successfully'),
                  backgroundColor: Colors.green.shade700,));
              },
              child: Text('Yes',
                style: TextStyle(
                    color: Theme
                        .of(context)
                        .brightness == Brightness.light ?
                    Colors.black : Colors.white
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onPressed(false);
                Navigator.pop(context);
              },
              child: Text('No',
                style: TextStyle(
                    color: Theme
                        .of(context)
                        .brightness == Brightness.light ?
                    Colors.black : Colors.white
                ),
              ),
            )
          ],
        ),
  );
}


Widget postInput({
  required BuildContext context,
}) =>
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<
              RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
              Colors.transparent),
          overlayColor: MaterialStateProperty.all(
              Colors.black12),
          padding: MaterialStateProperty.all(
              EdgeInsets.zero), // Remove default padding
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(
              builder: (context) =>
                  CreatePost(
                      titleName: 'Create Post',
                      buttonName: 'Post',
                      onPressed: (postModel) {
                        HomeCubit
                            .get(context).insertAndUpdatePosts(postModel: postModel);
                        ProfileCubit.get(context)
                            .insertAndUpdatePosts(postModel:
                        postModel);
                      }
                  )
              )
          );
        },
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(color: Colors.grey) // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child:  UserDetails.image.isNotEmpty?
                          Image.network(
                            UserDetails.image,
                            fit: BoxFit.cover,
                          ) : Icon(Icons.person),
                        ),
                      ),
                    ),
                    // Text Prompt
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Do you want to write anything?',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ClipOval(
                      child: Material(
                        color: Colors.grey.shade700,
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: Icon(
                            Icons.image,
                            size: 30.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            )
        )
    ),
  );


SizedBox sizedBox () =>
    SizedBox(
      height: 20.0,
    );

String? validator(String? value, String? item) {
  if (value!.isEmpty) {
    return 'Please Enter Your $item';
  }
  return null;
}


Widget buildInputField({
  required TextEditingController controller,
  String? hint,
  String? label,
  IconData? icon,
  TextInputType? keyboardType,
  bool obscureText = false,
  bool isPassword = false,
  Widget? suffixIcon,
  InputDecoration? decoration,
  String? Function(String?)? validator,
  double borderRadius = 12.0,
  Color? publicColor,
  Color? fillColor,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    cursorColor:  Colors.amber[700],
    validator: validator,
    style: const TextStyle(color: Colors.white),
    decoration: decoration ?? InputDecoration(
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:  Colors.amber.shade700,
          width: 1.8,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:  Colors.amber.shade700,
          width: 2.2,
        ),
      ),
      hintText: hint,
      hintStyle: TextStyle(color:  Colors.amber[700]),
      labelText: label,
      labelStyle: TextStyle(color:  Colors.amber[700]),
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.amber[700])
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[700]!.withOpacity(0.5),
    ),
  );
}
