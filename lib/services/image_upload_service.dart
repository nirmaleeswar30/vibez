// lib/services/image_upload_service.dart

import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  // --- THIS IS THE SECTION TO UPDATE ---
  // Replace these placeholder values with your actual Cloudinary details.
  // You can find these on your Cloudinary Dashboard.
  static const String _cloudName = "dr8g09icb";
  static const String _uploadPreset = "vibezz";
  // For unsigned uploads, you do NOT need the API Key or Secret here.
  // ------------------------------------

  final _picker = ImagePicker();

  // The cloudinary instance is now initialized with your specific credentials.
  final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image slightly for faster uploads
      );
      return image;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      // The CloudinaryPublic object now knows where to send the file.
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path,
            resourceType: CloudinaryResourceType.Image),
      );
      // The secureUrl is the public URL of the uploaded image.
      return response.secureUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}