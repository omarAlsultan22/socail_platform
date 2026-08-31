import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class MediaPickerService {

  static Future<File?> pickImage() async {
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

  static Future<File?> pickVideo() async {
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


  static Future<Map<String, dynamic>?> checkFile(File file) async {
    try {
      String filePath = file.path.toLowerCase();
      String extension = path.extension(filePath).replaceFirst('.', '');

      List<String> imageExtensions = ['jpg', 'png', 'jpeg', 'gif', 'webp'];
      List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv'];

      if (imageExtensions.contains(extension)) {
        return await _uploadFile(file, 'image');
      } else if (videoExtensions.contains(extension)) {
        return await _uploadFile(file, 'video');
      } else {
        print('Unsupported file type: $extension');
        return null;
      }
    } catch (e) {
      print('Error checking file: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _uploadFile(File file,
      String folderName) async {
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
}