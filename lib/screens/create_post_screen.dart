// lib/screens/create_post_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_together_app/services/image_upload_service.dart';

class CreatePostScreen extends StatefulWidget {
  // Optional params to specify if the post is for a group
  final String? groupId;
  final String? groupName;

  const CreatePostScreen({super.key, this.groupId, this.groupName});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImageUploadService _imageUploadService = ImageUploadService();
  XFile? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final image = await _imageUploadService.pickImage();
    if (image != null) setState(() { _selectedImage = image; });
  }

  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || (_textController.text.trim().isEmpty && _selectedImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something or add an image.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _imageUploadService.uploadImage(_selectedImage!);
    }

    try {
      // Create the post data map
      Map<String, dynamic> postData = {
        'text': _textController.text.trim(),
        'imageUrl': imageUrl,
        'authorId': user.uid,
        'authorName': user.displayName,
        'authorPhotoUrl': user.photoURL,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'commentCount': 0,
      };

      // Add groupId if it exists
      if (widget.groupId != null) {
        postData['groupId'] = widget.groupId;
      }

      await FirebaseFirestore.instance.collection('posts').add(postData);

      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      print("Error creating post: $e");
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName == null ? 'Create a Vibe Post' : 'Post in ${widget.groupName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isLoading ? null : _submitPost,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 8,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "What's on your mind...",
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            if (_selectedImage != null)
              Image.file(File(_selectedImage!.path), height: 200),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.photo_library_outlined, size: 30),
              onPressed: _pickImage,
              tooltip: "Add Image",
            ),
          ],
        ),
      ),
    );
  }
}