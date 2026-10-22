import 'dart:io';


abstract class IMediaUploadService {
  Future<File?> pickImage();
  Future<File?> pickVideo();
  Future<Map<String, String>?> checkAndUploadFile(File file);
}