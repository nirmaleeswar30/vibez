// lib/screens/create_group_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_together_app/services/image_upload_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUploadService = ImageUploadService();
  XFile? _selectedImage;
  bool _isPublic = true;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final image = await _imageUploadService.pickImage();
    if (image != null) setState(() { _selectedImage = image; });
  }

  Future<void> _submitGroup() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() { _isLoading = true; });

    String imageUrl = 'https://i.imgur.com/sRg1g4D.png'; // Default image
    if (_selectedImage != null) {
      final uploadedUrl = await _imageUploadService.uploadImage(_selectedImage!);
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('groups').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'groupPhotoUrl': imageUrl,
        'isPublic': _isPublic,
        'creatorId': user.uid,
        'members': [user.uid], // Creator is the first member
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      print("Error creating group: $e");
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Group"),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitGroup,
            child: _isLoading ? const CircularProgressIndicator() : const Text("CREATE"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InkWell(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null ? FileImage(File(_selectedImage!.path)) : null as ImageProvider?,
                  child: _selectedImage == null ? const Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Group Name"),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Public Group"),
                subtitle: const Text("Anyone can find and join this group."),
                value: _isPublic,
                onChanged: (val) => setState(() => _isPublic = val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}