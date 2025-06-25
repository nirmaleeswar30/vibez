// lib/screens/edit_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vibe_together_app/providers/user_provider.dart';
import 'package:vibe_together_app/services/image_upload_service.dart';
import 'package:vibe_together_app/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  final ImageUploadService _imageUploadService = ImageUploadService();
  final UserService _userService = UserService();
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imageUploadService.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;
    
    setState(() { _isLoading = true; });

    String? newImageUrl;
    if (_selectedImage != null) {
      newImageUrl = await _imageUploadService.uploadImage(_selectedImage!);
    }
    
    await _userService.updateUserProfile(
      newName: _nameController.text.trim(),
      newPhotoUrl: newImageUrl,
    );
    
    // Refresh the user data in the provider
    await Provider.of<UserProvider>(context, listen: false).fetchUser();

    if (mounted) {
      setState(() { _isLoading = false; });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading ? const CircularProgressIndicator() : const Text("SAVE"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _selectedImage != null
                      ? FileImage(File(_selectedImage!.path))
                      : NetworkImage(user?.photoUrl ?? '') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
          ],
        ),
      ),
    );
  }
}